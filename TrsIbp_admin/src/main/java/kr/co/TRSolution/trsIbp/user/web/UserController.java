package kr.co.TRSolution.trsIbp.user.web;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.annotation.Resource;
import org.springframework.ui.Model;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import kr.co.TRSolution.trsIbp.comm.file.service.CommonFileService;
import kr.co.TRSolution.trsIbp.comm.file.vo.CommonFileVO;
import kr.co.TRSolution.trsIbp.comm.file.web.CommonFileController;
import kr.co.TRSolution.trsIbp.user.service.UserService;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

/**
 * 사용자 컨트롤러 클래스
 * @author 솔루션사업팀 정다빈
 * @since 2021.07.23
 * @version 1.0
 * @see
 *
 * << 개정이력(Modification Information) >>
 *
 *   수정일            수정자              수정내용
 *  -------    -------- ---------------------------
 *  2021.07.23  정다빈           최초 생성
 */

@Controller
public class UserController {

    private static final String EMP_UPDATE_TARGETS_SESSION_KEY = "empUpdateTargets";
    private static final int MAX_EMP_UPDATE_TARGETS = 20;
	
	public static final Logger logger = LoggerFactory.getLogger(UserController.class);
	
	@Resource(name="userService")
	private UserService userService;

    @Resource(name = "commonFileService")
    private CommonFileService commonFileService;

	public String url="";
	public boolean isClose = false;
	
	
	//주소에 맞게 매핑
	@RequestMapping(value="/user/*.do")
	public String userUrlMapping(HttpSession httpSession, HttpServletRequest request,Model model) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.user 최초 컨트롤러 진입 httpSession : "+httpSession);
		logger.debug("▶▶▶▶▶▶▶.request.getRequestURL() : "+request.getRequestURL());
		logger.debug("▶▶▶▶▶▶▶.request.getRequestURI() : "+request.getRequestURI());
		logger.debug("▶▶▶▶▶▶▶.request.getContextPath() : "+request.getContextPath());
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		logger.debug("▶▶▶▶▶▶▶.보내려는 url : "+url);
		return url;
	}
	
	//22.03.16 긴급생성
	//1.  소메뉴 존재 항목에 관하여 권한 별 분기처리
	@RequestMapping(value="/user/first.do")
	public ModelAndView first(HttpSession httpSession, HttpServletRequest request,Model model) throws Exception{
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		ModelAndView mav = new ModelAndView("jsonView");
		
		// 현재 세션에 대해 로그인한 사용자 정보를 가져옴
		UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
		
		return mav;
	}
	
	//초기 검색버튼 활성화
	@RequestMapping(value= {"/user/userMain.do"})
	public ModelAndView userMain(HttpServletRequest request) throws Exception {
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		ModelAndView mav = new ModelAndView(url);
		// 현재 세션에 대해 로그인한 사용자 정보를 가져옴
		UserVO nlVo = (UserVO) request.getSession().getAttribute("login");
		return mav;
	}
	
	
	//사용자 목록 조회
	@RequestMapping(value="/user/userList.do")
	public @ResponseBody ModelAndView userList( @ModelAttribute("userVO") UserVO userVO,HttpServletRequest request) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.회원정보 조회 목록!!!!!!!!!!!!!!!!");
		
		UserVO uvo = new UserVO();
		//url로 h,g 판별하여 해당하는 값만 조회
		ModelAndView mav = new ModelAndView("jsonView");
		List<UserVO> userList= null;
		try {
			// 현재 세션에 대해 로그인한 사용자 정보를 가져옴
			UserVO nlVo = (UserVO) request.getSession().getAttribute("login");
			if(userVO.getSearchValue()!=null) {
				uvo=userVO;
			}
			if(!(nlVo.getAuthrtId().equals("999"))) {//999 관리자 권한
				//관리자 권한이 아닐경우 관리자는 목록조회 안되도록
				uvo.setAuthrtId("998");
			}
			userList = userService.selectUserList(uvo);
			mav.setViewName("/user/userList");
			mav.addObject("userList", userList);
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
		}
		return mav;
	}

	/**
	 * 사용자 등록, 상세 페이지 이동 분기
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/user/editUser.do")
	public ModelAndView editUser(HttpServletRequest request, @ModelAttribute UserVO userVO, RedirectAttributes redirectAttributes) throws Exception {
		ModelAndView mv = new ModelAndView("/user/userEdit");
		UserVO uvo = new UserVO();
		UserVO nlVo = (UserVO) request.getSession().getAttribute("login");
		
		if (request.getParameter("pr1")!=null&&!(request.getParameter("pr1").equals(""))) {
			uvo.setUserId(request.getParameter("pr1"));
			uvo=userService.selectUser(uvo);
			mv.addObject("editDiv", "update");
			mv.setViewName("/user/userDetail");
		} else {
			mv.setViewName("/user/userInsert");
			mv.addObject("editDiv", "new");
		}
		mv.addObject("userInfo", uvo);
		return mv;
	}
	
	//사용자 등록
	@RequestMapping(value="/user/insertUser.ajax", method=RequestMethod.POST)
	public ModelAndView insertUser(HttpServletRequest request, @ModelAttribute UserVO userVO, RedirectAttributes redirectAttributes) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.request.getRequestURL() : "+request.getRequestURL());
		logger.debug("▶▶▶▶▶▶▶.request.getRequestURI() : "+request.getRequestURI());
		logger.debug("▶▶▶▶▶▶▶.request.getContextPath() : "+request.getContextPath());
		ModelAndView mav = new ModelAndView("jsonView");
		int cnt = 0;
		try {
			String authUrl = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
			//패스워드 암호화 처리
			logger.debug("변환전 uservo: "+userVO.toString());
			String hashedPw = BCrypt.hashpw(userVO.getUserEnpswd(), BCrypt.gensalt());
			userVO.setUserEnpswd(hashedPw);
			logger.debug("변환후 uservo: "+userVO.toString());
			userService.insertUser(userVO);
			cnt=1;
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
		}
		mav.addObject("cnt", cnt);
		return mav;
	}

	//검색한 id 조회
	@RequestMapping(value="/user/findUserId.do")
	public @ResponseBody ModelAndView findUserId( @ModelAttribute("userVO") UserVO userVO,HttpServletRequest request) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.회원정보 조회 목록!!!!!!!!!!!!!!!!");
		
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		
		ModelAndView mav = new ModelAndView("jsonView");
		UserVO disUser= null;
		try {
			disUser = userService.selectUser(userVO);
			mav.addObject("data", disUser.getUserId());
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
			mav.addObject("msg","search_not");
		}
		return mav;
	}

	//사용자 수정 페이지 진입
	@RequestMapping(value="/user/userUpdate.do")
	public @ResponseBody ModelAndView userUpdate( @ModelAttribute("userVO") UserVO userVO,HttpServletRequest request) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.회원정보 조회 목록!!!!!!!!!!!!!!!!");
		
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		
		ModelAndView mav = new ModelAndView("jsonView");
		UserVO disUser= null;
		try {
			disUser = userService.selectUser(userVO);
			logger.debug("▶▶▶▶▶▶▶.시험코드 결과값들:"+disUser);
			
			mav.addObject("data", disUser);
			mav.setViewName(url);
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
		}
		return mav;
	}
	
	//사용자 수정 반영
	@RequestMapping(value="/user/userUpdate.ajax")
	public @ResponseBody ModelAndView userUpdateForm( @ModelAttribute("userVO") UserVO userVO,HttpServletRequest request) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.회원정보 수정!!!!!!!!!!!!!!!!");
		
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		//비밀번호 암호화
		if(userVO.getUserEnpswd() != null && !"".equals(userVO.getUserEnpswd())) {
			String hashedPw = BCrypt.hashpw(userVO.getUserEnpswd(), BCrypt.gensalt());
			userVO.setUserEnpswd(hashedPw);
		}
		
		ModelAndView mav = new ModelAndView("jsonView");
		try {
			userService.updateUser(userVO);
			
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
			mav.addObject("msg","에러가 발생하였습니다");
		}
		return mav;
	}

	//사용자 삭제
	@RequestMapping(value="/user/userDelete.ajax")
	public @ResponseBody ModelAndView userDelete(  @ModelAttribute("userVO") UserVO userVO,HttpServletRequest request) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.회원정보 삭제!!!!!!!!!!!!!!!!");
		int cnt = 0;
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		
		ModelAndView mav = new ModelAndView("jsonView");
		try {
			userService.deleteUser(userVO);
			cnt=1;
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
			mav.addObject("msg","에러가 발생했습니다.");
		}
		mav.addObject("msg","현재 접속중인 사용자는 삭제할 수 없습니다!");
		mav.addObject("cnt", cnt);
		return mav;
	}
	
	/**
	 * 사용자 권한 등급 설정
	 * @param model
	 * @return
	 * @throws Exception
	 */
	@RequestMapping("/user/authorityMgmt.do")
	public ModelAndView authorityMgmt(@ModelAttribute("userVO") UserVO userVO,HttpServletRequest request) throws Exception {
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		ModelAndView mav = new ModelAndView("jsonView");
		UserVO disUser= null;
		try {
			disUser = userService.selectUser(userVO);
			logger.debug("▶▶▶▶▶▶▶.시험코드 결과값들:"+disUser);
			
			List<UserVO> userList= null;
			
			mav.addObject("authList", userList);
			mav.setViewName(url);
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
			mav.addObject("msg","에러가 발생했습니다.");
		}
		return mav;
	}
	
	
	//사용자 로그인이력 조회
	@RequestMapping(value="/user/loginHistoryList.do")
	public @ResponseBody ModelAndView loginHistory( @ModelAttribute("userVO") UserVO userVO,HttpServletRequest request) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.회원정보 조회 목록!!!!!!!!!!!!!!!!");
		
		UserVO uvo = new UserVO();
		//url로 h,g 판별하여 해당하는 값만 조회
		ModelAndView mav = new ModelAndView("jsonView");
		List<UserVO> userList= null;
		try {
			// 현재 세션에 대해 로그인한 사용자 정보를 가져옴
			UserVO nlVo = (UserVO) request.getSession().getAttribute("login");
			if(userVO.getSearchValue()!=null) {
				uvo=userVO;
			}
			mav.setViewName("/user/loginHistoryList");
			mav.addObject("userList", userList);
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
		}
		return mav;
	}
	
	//사용자 사용이력 조회
	@RequestMapping(value="/user/useHistoryList.do")
	public @ResponseBody ModelAndView useHistoryList( @ModelAttribute("userVO") UserVO userVO,HttpServletRequest request) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.회원정보 조회 목록!!!!!!!!!!!!!!!!");
		
		UserVO uvo = new UserVO();
		//url로 h,g 판별하여 해당하는 값만 조회
		ModelAndView mav = new ModelAndView("jsonView");
		List<UserVO> userList= null;
		try {
			// 현재 세션에 대해 로그인한 사용자 정보를 가져옴
			UserVO nlVo = (UserVO) request.getSession().getAttribute("login");
			if(userVO.getSearchValue()!=null) {
				uvo=userVO;
			}
			mav.setViewName("/user/useHistoryList");
			mav.addObject("userList", userList);
		} catch (Exception e) {
			logger.debug("에러메시지 : "+e.toString());
		}
		return mav;
	}
	
    /**
     * 사용자(직원) 관리 목록 화면으로 이동한다.
     * @param request 현재 요청 객체
     * @return 사용자 목록 JSP 경로
     * @throws Exception 화면 이동 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empList.do")
    public ModelAndView empListPage(HttpServletRequest request) throws Exception {
        return new ModelAndView("/user/empList");
    }

    /**
     * 사용자(직원) 등록 화면으로 이동한다.
     * @param request 현재 요청 객체
     * @return 사용자 등록 JSP 경로
     * @throws Exception 화면 이동 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empInsert.do")
    public ModelAndView empInsertPage(HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("/user/empInsert");
        mav.addObject("mode", "insert");
        return mav;
    }

    /**
     * 사용자(직원) 상세 화면으로 이동한다.
     * @param request 현재 요청 객체
     * @param userVO userId를 포함한 사용자 조회 조건
     * @return 사용자 상세 JSP 경로
     * @throws Exception 화면 이동 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empDetail.do")
    public ModelAndView empDetailPage(HttpServletRequest request, @ModelAttribute("userVO") UserVO userVO) throws Exception {
        ModelAndView mav = new ModelAndView("/user/empDetail");
        mav.addObject("userId", userVO.getUserId());
        mav.addObject("mode", "detail");
        return mav;
    }

    /**
     * 사용자(직원) 수정 화면으로 이동한다.
     * @param request 현재 요청 객체
     * @param userVO userId를 포함한 사용자 조회 조건
     * @return 사용자 수정 JSP 경로
     * @throws Exception 화면 이동 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empUpdate.do")
    public ModelAndView empUpdatePage(HttpServletRequest request, @ModelAttribute("userVO") UserVO userVO) throws Exception {
        ModelAndView mav = new ModelAndView("/user/empUpdate");
        mav.addObject("userId", userVO.getUserId());
        mav.addObject("updateToken", createEmpUpdateToken(request, userVO.getUserId()));
        mav.addObject("mode", "update");
        return mav;
    }

    /**
     * 로그인 사용자 회사 기준 사용자(직원) 목록을 조회한다.
     * @param userVO 검색어, 부서, 권한, 사용여부 등 조회 조건
     * @param request 현재 요청 객체
     * @return 사용자 목록 JSON
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empList.ajax")
    public ModelAndView selectEmpList(@ModelAttribute("userVO") UserVO userVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
        userVO.setCoId(reqLoginVo.getCoId());
        List<UserVO> userList = userService.selectUserManageList(userVO);
        mav.addObject("userList", userList);
        return mav;
    }

    /**
     * 사용자(직원) 등록/수정/상세 화면에서 사용할 부서, 권한 목록을 조회한다.
     * @param userVO 조회 조건 VO
     * @param request 현재 요청 객체
     * @return 부서 목록, 권한 목록 JSON
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empMeta.ajax")
    public ModelAndView selectEmpMeta(@ModelAttribute("userVO") UserVO userVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
        userVO.setCoId(reqLoginVo.getCoId());
        mav.addObject("deptList", userService.selectDeptListByCoId(userVO));
        mav.addObject("authList", userService.selectAuthList());
        return mav;
    }

    /**
     * 로그인 사용자 회사 기준 사용자(직원) 단건을 조회한다.
     * @param userVO userId를 포함한 사용자 조회 조건
     * @param request 현재 요청 객체
     * @return 사용자 단건 JSON
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empDetail.ajax")
    public ModelAndView selectEmpDetail(@ModelAttribute("userVO") UserVO userVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
        userVO.setCoId(reqLoginVo.getCoId());
        UserVO user = userService.selectUserManage(userVO);
        mav.addObject("user", user);
        if (user != null) {
            CommonFileVO profileFile = commonFileService.selectUserProfileFile(reqLoginVo.getCoId(), user.getUserId());
            mav.addObject("profileFile", CommonFileController.toClientFile(profileFile));
            List<Map<String, Object>> clientFiles = new java.util.ArrayList<Map<String, Object>>();
            if (canManageUserFile(reqLoginVo, user.getUserId())) {
                List<CommonFileVO> documentFiles = commonFileService.selectUserDocumentFileList(
                        reqLoginVo.getCoId(), user.getUserId());
                for (CommonFileVO file : documentFiles) {
                    clientFiles.add(CommonFileController.toClientFile(file));
                }
            }
            mav.addObject("attachmentList", clientFiles);
        }
        return mav;
    }

    /**
     * 사용자ID 중복 여부를 조회한다.
     * @param userVO userId를 포함한 조회 조건
     * @param request 현재 요청 객체
     * @return 중복 건수 JSON
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empIdCheck.ajax")
    public ModelAndView checkEmpId(@ModelAttribute("userVO") UserVO userVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        if (!isValidUserId(userVO.getUserId())) {
            mav.addObject("result", "FAIL");
            mav.addObject("msg", "사용자ID는 영문 소문자와 숫자 6~20자로 입력하고 영문 소문자를 포함해야 합니다.");
            return mav;
        }
        mav.addObject("result", "OK");
        mav.addObject("cnt", userService.selectUserIdCount(userVO));
        return mav;
    }

    /**
     * 사용자(직원)를 등록하거나 수정한다.
     * @param userVO 저장할 사용자 정보
     * @param request 현재 요청 객체
     * @return 저장 결과 JSON
     * @throws Exception 저장 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empSave.ajax", method=RequestMethod.POST)
    public ModelAndView saveEmp(@ModelAttribute("userVO") UserVO userVO,
            @RequestParam(value = "profileFile", required = false) MultipartFile profileFile,
            @RequestParam(value = "userFiles", required = false) MultipartFile[] userFiles,
            HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
        userVO.setCoId(reqLoginVo.getCoId());
        if (userVO.getDeptId() == null || userVO.getDeptId().trim().isEmpty()) {
            userVO.setDeptId(null);
        }

        try {
            logger.info("사용자 저장 요청: mode=" + userVO.getSaveMode()
                    + ", requestedUserId=" + userVO.getUserId()
                    + ", loginUserId=" + reqLoginVo.getUserId()
                    + ", coId=" + userVO.getCoId());
            if (userVO.getUseYn() == null || "".equals(userVO.getUseYn())) {
                userVO.setUseYn("Y");
            }
            if (userVO.getUserId() == null || "".equals(userVO.getUserId().trim())) {
                logger.warn("사용자 저장 검증 실패: 사용자ID 미입력, mode=" + userVO.getSaveMode()
                        + ", loginUserId=" + reqLoginVo.getUserId()
                        + ", coId=" + userVO.getCoId());
                mav.addObject("result", "FAIL");
                mav.addObject("msg", "사용자ID를 입력해 주세요.");
                return mav;
            }
            if ("insert".equals(userVO.getSaveMode()) && !isValidUserId(userVO.getUserId())) {
                logger.warn("사용자 등록 검증 실패: 사용자ID 형식 오류, requestedUserId=" + userVO.getUserId()
                        + ", loginUserId=" + reqLoginVo.getUserId()
                        + ", coId=" + userVO.getCoId());
                mav.addObject("result", "FAIL");
                mav.addObject("msg", "사용자ID는 영문 소문자와 숫자 6~20자로 입력하고 영문 소문자를 포함해야 합니다.");
                return mav;
            }
            if (userVO.getUserNm() == null || "".equals(userVO.getUserNm().trim())) {
                logger.warn("사용자 저장 검증 실패: 사용자명 미입력, mode=" + userVO.getSaveMode()
                        + ", requestedUserId=" + userVO.getUserId()
                        + ", loginUserId=" + reqLoginVo.getUserId()
                        + ", coId=" + userVO.getCoId());
                mav.addObject("result", "FAIL");
                mav.addObject("msg", "사용자명을 입력해 주세요.");
                return mav;
            }
            if ("insert".equals(userVO.getSaveMode())) {
                if (userVO.getUserEnpswd() == null || "".equals(userVO.getUserEnpswd().trim())) {
                    logger.warn("사용자 등록 검증 실패: 초기 비밀번호 미입력, requestedUserId=" + userVO.getUserId()
                            + ", loginUserId=" + reqLoginVo.getUserId()
                            + ", coId=" + userVO.getCoId());
                    mav.addObject("result", "FAIL");
                    mav.addObject("msg", "초기 비밀번호를 입력해 주세요.");
                    return mav;
                }
                if (userService.selectUserIdCount(userVO) > 0) {
                    logger.warn("사용자 등록 검증 실패: 사용자ID 중복, requestedUserId=" + userVO.getUserId()
                            + ", loginUserId=" + reqLoginVo.getUserId()
                            + ", coId=" + userVO.getCoId());
                    mav.addObject("result", "DUP");
                    mav.addObject("msg", "이미 사용 중인 사용자ID입니다.");
                    return mav;
                }
                userVO.setUserEnpswd(BCrypt.hashpw(userVO.getUserEnpswd(), BCrypt.gensalt()));
                userService.insertUserManage(userVO, profileFile, userFiles, reqLoginVo.getUserId());
            } else {
                String updateUserId = resolveEmpUpdateTarget(request, request.getParameter("updateToken"));
                if (updateUserId == null || updateUserId.trim().isEmpty()) {
                    boolean tokenPresent = request.getParameter("updateToken") != null
                            && !request.getParameter("updateToken").trim().isEmpty();
                    logger.warn("사용자 수정 대상 확인 실패: requestedUserId=" + userVO.getUserId()
                            + ", tokenPresent=" + tokenPresent
                            + ", loginUserId=" + reqLoginVo.getUserId()
                            + ", coId=" + userVO.getCoId());
                    mav.addObject("result", "FAIL");
                    mav.addObject("msg", "수정 대상 확인정보가 만료되었거나 올바르지 않습니다. 목록에서 다시 수정 화면으로 이동해 주세요.");
                    return mav;
                }
                logger.debug("사용자 수정 대상 확인 성공: requestedUserId=" + userVO.getUserId()
                        + ", resolvedUserId=" + updateUserId
                        + ", loginUserId=" + reqLoginVo.getUserId()
                        + ", coId=" + userVO.getCoId());
                userVO.setUserId(updateUserId);
                if (userVO.getUserEnpswd() != null && !"".equals(userVO.getUserEnpswd().trim())) {
                    userVO.setUserEnpswd(BCrypt.hashpw(userVO.getUserEnpswd(), BCrypt.gensalt()));
                }
                userService.updateUserManage(userVO, profileFile, userFiles, reqLoginVo.getUserId());
            }
            mav.addObject("result", "OK");
            logger.info("사용자 저장 완료: mode=" + userVO.getSaveMode()
                    + ", userId=" + userVO.getUserId()
                    + ", loginUserId=" + reqLoginVo.getUserId()
                    + ", coId=" + userVO.getCoId());
        } catch (IllegalArgumentException e) {
            logger.warn("사용자 저장 입력값 오류 userId=" + userVO.getUserId() + ", reason=" + e.getMessage());
            mav.addObject("result", "FAIL");
            mav.addObject("msg", e.getMessage());
        } catch (Exception e) {
            logger.error("사용자 저장 중 오류 발생 userId : " + userVO.getUserId(), e);
            mav.addObject("result", "FAIL");
            mav.addObject("msg", "사용자 저장 중 오류가 발생했습니다.");
        }
        return mav;
    }

    /**
     * 사용자 수정 화면별 난수 토큰을 생성하고 서버 세션에 원래 사용자ID와 연결해 보관한다.
     * @param request 수정 화면 요청 객체
     * @param userId 수정 대상 사용자ID
     * @return 화면에 전달할 수정 토큰. 사용자ID가 없으면 빈 문자열
     */
    @SuppressWarnings("unchecked")
    private String createEmpUpdateToken(HttpServletRequest request, String userId) {
        if (userId == null || userId.trim().isEmpty()) {
            return "";
        }
        HttpSession session = request.getSession();
        Map<String, String> targets = (Map<String, String>) session.getAttribute(EMP_UPDATE_TARGETS_SESSION_KEY);
        if (targets == null) {
            targets = new LinkedHashMap<String, String>();
            session.setAttribute(EMP_UPDATE_TARGETS_SESSION_KEY, targets);
        }
        synchronized (targets) {
            while (targets.size() >= MAX_EMP_UPDATE_TARGETS) {
                String oldestToken = targets.keySet().iterator().next();
                targets.remove(oldestToken);
            }
            String token = UUID.randomUUID().toString();
            targets.put(token, userId.trim());
            return token;
        }
    }

    /**
     * 수정 토큰에 연결된 원래 사용자ID를 서버 세션에서 조회한다.
     * @param request 사용자 저장 요청 객체
     * @param updateToken 수정 화면에서 전달된 난수 토큰
     * @return 서버가 보관한 수정 대상 사용자ID. 토큰이 없거나 올바르지 않으면 null
     */
    @SuppressWarnings("unchecked")
    private String resolveEmpUpdateTarget(HttpServletRequest request, String updateToken) {
        if (updateToken == null || updateToken.trim().isEmpty()) {
            return null;
        }
        Object targetObject = request.getSession().getAttribute(EMP_UPDATE_TARGETS_SESSION_KEY);
        if (!(targetObject instanceof Map)) {
            return null;
        }
        Map<String, String> targets = (Map<String, String>) targetObject;
        synchronized (targets) {
            return targets.get(updateToken);
        }
    }

    private boolean canManageUserFile(UserVO loginUser, String targetUserId) {
        return targetUserId != null && (targetUserId.equals(loginUser.getUserId())
                || "ADMIN".equals(loginUser.getAuthrtId())
                || "MANAGER".equals(loginUser.getAuthrtId()));
    }

    /**
     * 사용자ID가 영문 소문자를 포함한 소문자·숫자 6~20자 형식인지 검사한다.
     * @param userId 검사할 사용자ID
     * @return 사용자ID 정책 충족 여부
     */
    private boolean isValidUserId(String userId) {
        return userId != null && userId.matches("^(?=.*[a-z])[a-z0-9]{6,20}$");
    }

    /**
     * 사용자(직원)를 사용중지 처리한다.
     * @param userVO userId를 포함한 삭제 조건
     * @param request 현재 요청 객체
     * @return 삭제 결과 JSON
     * @throws Exception 삭제 중 예외 발생 시 전달
     */
    @RequestMapping(value="/user/empDelete.ajax", method=RequestMethod.POST)
    public ModelAndView deleteEmp(@ModelAttribute("userVO") UserVO userVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
        userVO.setCoId(reqLoginVo.getCoId());
        try {
            if (reqLoginVo.getUserId().equals(userVO.getUserId())) {
                mav.addObject("result", "FAIL");
                mav.addObject("msg", "현재 로그인 사용자는 삭제할 수 없습니다.");
                return mav;
            }
            userService.deleteUserManage(userVO);
            mav.addObject("result", "OK");
        } catch (Exception e) {
            logger.error("사용자 삭제 중 오류 발생 userId : " + userVO.getUserId(), e);
            mav.addObject("result", "FAIL");
            mav.addObject("msg", "사용자 삭제 중 오류가 발생했습니다.");
        }
        return mav;
    }

}
