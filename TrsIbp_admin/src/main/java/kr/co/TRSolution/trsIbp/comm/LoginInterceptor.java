package kr.co.TRSolution.trsIbp.comm;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import kr.co.TRSolution.trsIbp.user.vo.UserVO;
import kr.co.TRSolution.trsIbp.admin.service.AdminService;
import kr.co.TRSolution.trsIbp.admin.vo.AdminVO;

/**
 * 시스템관리자 로그인/로그아웃 처리 인터셉터
 *
 * [동작 흐름]
 * 1. preHandle  : 로그인/로그아웃 URL 진입 전 기존 세션 제거
 * 2. postHandle : 로그인 성공 시 세션 저장 및 시스템 로그 기록
 *
 * [매핑 URL] dispatcher-servlet.xml에서 /user/loginAction.do, /login/logout.do 에 적용
 * [패키지 명 명세] trsHome -> trsIbp 구조 변경 반영 완료
 */
public class LoginInterceptor extends HandlerInterceptorAdapter {

    public static final String LOGIN = "login";
    
    // ★ 복구된 로거 선언문 (컴파일 에러 방지)
    public static final Logger logger = LoggerFactory.getLogger(LoginInterceptor.class);

    @Resource(name = "adminService")
    private AdminService adminService;

    /**
     * 핸들러 실행 전 - 기존 세션 제거 (중복 로그인 방지)
     */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        logger.debug("▶ LoginInterceptor.preHandle 진입");
        HttpSession httpSession = request.getSession();
        logger.debug("▶ sessionId=" + httpSession.getId()
                + ", loginAttr=" + httpSession.getAttribute(LOGIN));

        try {
            // 기존 로그인 정보가 있으면 -> 세션 제거
            if (httpSession.getAttribute(LOGIN) != null) {
                logger.debug("▶ 기존 세션 제거 시작");
                String uid = SessionListener.getInstance().getUserID(httpSession);
                // SessionListener에서 세션 제거
                SessionListener.getInstance().removeSession(httpSession);
                logger.debug("▶ 기존 세션 제거 완료: userId=" + uid);
            }
        } catch (Exception e) {
            logger.error("▶ preHandle 내부 에러 발생: " + e.toString());
            return false;
        }
        return true;
    }

    /** 핸들러 실행 후 로그인 세션을 바인딩하고 시스템 로그를 기록한다. */
    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
            ModelAndView modelAndView) throws Exception {
        logger.debug("▶ LoginInterceptor.postHandle 진입");
        
        if (modelAndView == null) return;

        HttpSession httpSession = request.getSession();
        Object userVo = modelAndView.getModelMap().get("user");

        if (userVo != null) {
            UserVO lvo = (UserVO) userVo;
            
            // 1. 세션 기본 저장
            httpSession.setAttribute(LOGIN, lvo);
            SessionListener.getInstance().setSession(httpSession, lvo.getUserId());

            // 시스템관리자 사이트에서는 근태 자동출근을 생성하지 않는다.
            AdminVO log = new AdminVO();
            log.setUserId(lvo.getUserId());
            log.setLogSeCd("LOGIN");
            log.setLogLevelCd("INFO");
            log.setLogTitle("시스템관리자 로그인");
            log.setLogCn("로그인 성공");
            log.setRequestUri(request.getRequestURI());
            log.setClientIpAddr(resolveClientIp(request));
            adminService.recordSystemLog(log);

            // 인터셉터에서 직접 메인 대시보드로 리다이렉트 처리 후 모델 클리어
            response.sendRedirect(request.getContextPath() + "/");
            modelAndView.clear();
        }
    }

    private String resolveClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.trim().isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
