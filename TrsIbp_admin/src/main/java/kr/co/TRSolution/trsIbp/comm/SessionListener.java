package kr.co.TRSolution.trsIbp.comm;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import kr.co.TRSolution.trsIbp.user.vo.UserVO;

public class SessionListener implements HttpSessionBindingListener {

	// 싱글톤 객체를 담을 변수
	private static SessionListener sessionListener = null;

	public static final Logger logger = LoggerFactory.getLogger(SessionListener.class);
	
	
	// 로그인한 접속자를 저장한 HashTable 
	//(데이터를 해시하여 테이블 내의 주소를 계산하고 데이터를 담는 것 , 
	//해시함수 알고리즘은 나눗셈 법. 자릿수 접기 등등)
	private static Hashtable loginUsers = new Hashtable();

	/**
	 * was 상에서 현존하는 모든 세션 확인
	 * */
	public boolean chkSessionNow(HttpServletRequest request,HttpSession hs) {
		boolean flg = false;
		HttpSession session = request.getSession(true);

		Enumeration se = session.getAttributeNames();
		while(se.hasMoreElements()){
			String getse = se.nextElement()+"";
			System.out.println("@@@@@@@ session : "+getse+" : " + session.getValue(getse).toString());
			System.out.println("@@@@@@@ 겟벨류 : "+getse+" : " + session.getValue(getse).toString());
		}
		return true;
		
	}
	
	// 싱글톤 처리
	public static synchronized SessionListener getInstance() {
		logger.debug("인스턴스 생성 세션리스너 : "+sessionListener);
		if (sessionListener == null) {
			logger.debug("인스턴스 생성  N U L L");
			sessionListener = new SessionListener();
		}
		return sessionListener;
	}

	// 세션이 연결시 호출 (해시테이블에 접속자 저장)
	@SuppressWarnings("unchecked")
	@Override
	public void valueBound(HttpSessionBindingEvent event) {
		//맵에다 키 밸류를 집어넣음
		loginUsers.put(event.getSession(), event.getName());
		logger.debug("▷▷▷▷▷▷▷▷▷▷. "+event.getName() + " 로그인 완료");
		logger.debug("▷▷▷▷▷▷▷▷▷▷. "+"현재 접속자 수 : " + getUserCount());
		printloginUsers();
	}

	// 세션이 끊겼을시 호출
	@Override
	public void valueUnbound(HttpSessionBindingEvent event) {
		
		loginUsers.remove(event.getSession());
		logger.debug("▷▷▷▷▷▷▷▷▷▷. "+event.getName() + " 로그아웃 완료");
		logger.debug("▷▷▷▷▷▷▷▷▷▷. "+"현재 접속자 수 : " + getUserCount());
		printloginUsers();
	}

	// 입력받은 세션아이디를 해시테이블에서 삭제
	public void removeSession(HttpSession rqSession) {
		logger.debug("▷▷@▷▷.!!!!!!!.▷▷▷@▷▷▷.  세션 삭제 메소드 진입");
		Enumeration e = loginUsers.keys();
		HttpSession session = null;
		while (e.hasMoreElements()) {
			session = (HttpSession) e.nextElement();
			if ((session).equals(rqSession)) {
				// 세션이 invalidate될때 HttpSessionBindingListener를
				// 구현하는 클레스의 valueUnbound()함수가 호출된다.
				session.invalidate();
				//기존의 로그인 정보 제거
				/*if(session.getAttribute("login")!=null) {
					logger.debug("▶▶▶▶▶▶▶.clear login data before");
					//접속정보 1->0
					session.removeAttribute("login");
					SessionListener.getInstance().removeSession(session);
				}*/
				//해쉬테이블에서 로그인 사용자 제거
				loginUsers.remove(session);
			}
		}
		
	}

	/*
	 * 해당 아이디의 동시 사용을 막기위해서 이미 사용중인 아이디인지를 확인한다.
	 */
	public boolean isUsing(String userId) {
		logger.debug("▶▶▶▶▶▶▶.isUsing 메소드의 userId : "+userId);
		return loginUsers.containsValue(userId);
	}

	/*
	 * 로그인을 완료한 사용자의 아이디를 세션에 저장하는 메소드
	 */
	public void setSession(HttpSession session, String userId) {
		// 이순간에 Session Binding이벤트가 일어나는 시점
		// name값으로 userId, value값으로 자기자신(HttpSessionBindingListener를 구현하는 Object)
		logger.debug("▶▶▶▶▶▶▶.setSession 메소드의 세션값 : "+session);
		session.setAttribute(userId, this);// login에 자기자신을 집어넣는다.
		logger.debug("▶▶▶▶▶▶▶ 세션매핑 세팅 진입 : "+session.getAttribute(userId));
	}

	/*
	 * 입력받은 세션Object로 아이디를 리턴한다.
	 * @param session : 접속한 사용자의 session Object
	 * @return String : 접속자 아이디
	 */
	public String getUserID(HttpSession session) {
		logger.debug("▶▶▶▶▶▶▶.getUserID 메소드의 session : "+session);
		return (String) loginUsers.get(session);
	}

	/*
	 * 현재 접속한 총 사용자 수
	 * @return int 현재 접속자 수
	 */
	public int getUserCount() {
		return loginUsers.size();
	}

	/*
	 * 현재 접속중인 모든 사용자 아이디를 출력
	 * @return void
	 */
	public void printloginUsers() {
		Enumeration e = loginUsers.keys();//키값들 추출
		logger.debug("$$$$$$$$ loginUsers.size() : "+loginUsers.size());
		logger.debug("$$$$$$$$ loginUsers.keys() : "+loginUsers.keys());
		logger.debug("$$$$$$$$ e : "+e);
		HttpSession session = null;
		logger.debug("==================현 접속 사용자 조회=========================");
		int i = 0;
		while (e.hasMoreElements()) {
			session = (HttpSession) e.nextElement();//다음것의 키에대한 value 추출
			logger.debug((++i) + ". 접속자 : " + loginUsers.get(session));
			session.getAttribute("login");
		}
		logger.debug("===========================================");
	}


	/*
	 * 현재 로그인한 모든 uservo 객체 리턴
	 * @return void
	 */
	public List<UserVO> getNowVOList() {
		Enumeration e = loginUsers.keys();//키값들 추출
		HttpSession session = null;
		List<UserVO> itList = new ArrayList<>();
		int i = 0;
		while (e.hasMoreElements()) {
			session = (HttpSession) e.nextElement();//다음것의 키에대한 value 추출
			itList.add((UserVO)session.getAttribute("login"));
		}
		return itList;
	}
	
	/*
	 * 현재 접속중인 모든 사용자리스트를 리턴
	 * @return list
	 */
	public Collection getUsers() {
		Collection<UserVO> collection = loginUsers.values();
		return collection;
	}
	
	

	// request된 세션이 현재 로그인 된 세션인지 판별
	// 세션값이 바뀌어 들어오거나 웹 장애등으로 유효하지 않은 경우의 세션이 들어올경우 판별
	public String nowValSes(HttpSession rqSession) {
		logger.debug("▷▷@▷▷.!!!!!!!.▷▷▷@▷▷▷.  세션 체크 메소드 진입");
		String unSes=null;
		Enumeration e = loginUsers.keys();
		HttpSession session = null;
		while (e.hasMoreElements()) {
			session = (HttpSession) e.nextElement();
			if ((session).equals(rqSession)) {
				// 세션이 invalidate될때 HttpSessionBindingListener를
				// 구현하는 클레스의 valueUnbound()함수가 호출된다.
				unSes=rqSession.toString();
			}
		}
		return unSes;
	}
	
	public boolean dbChk(String dbSes){
		//String res = null;
		Enumeration e = loginUsers.keys();
		HttpSession session = null;
		while (e.hasMoreElements()) {
			session = (HttpSession) e.nextElement();//다음것의 키값 추출
			//db값과 서버의 세션값이 같지않은 것 추출
			//같은거 있으면 true 리턴
			if(dbSes.equals(session.getId())) {
				return true;
			}
		}
		//다 돌고 없으면 false 리턴
		return false;
	}

	

	// 로그인 사용자 id로 세션 삭제
	public void removeSessionById(String logId) {
		logger.debug("▷▷@▷▷.!!!!!!!.▷▷▷@▷▷▷.  기 접속중인 사용자 세션 삭제 : "+logId);
		
		Enumeration e = loginUsers.keys();
		HttpSession session = null;
		while (e.hasMoreElements()) {
			session =(HttpSession) e.nextElement();
			if(loginUsers.get(session).equals(logId)) {
					// 세션이 invalidate될때 HttpSessionBindingListener를
					// 구현하는 클레스의 valueUnbound()함수가 호출된다.
					session.invalidate();
					//기존의 로그인 정보 제거
					/*if(session.getAttribute("login")!=null) {
						logger.debug("▶▶▶▶▶▶▶.clear login data before");
						//접속정보 1->0
						session.removeAttribute("login");
						SessionListener.getInstance().removeSession(session);
					}*/
					//해쉬테이블에서 로그인 사용자 제거
					loginUsers.remove(session);
			}
		}
	}
}
