package kr.co.TRSolution.trsIbp.comm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

/**
 * 세션 체크 인터셉터
 *
 * 로그인이 필요한 URL 접근 시 세션 유무를 확인하여
 * 미로그인 상태이면 /login/login.do 로 리다이렉트
 *
 * [적용 URL] dispatcher-servlet.xml 참조
 *  - 적용 : /*.do, /*.ajax
 *  - 제외 : /login/login.do, /user/loginAction.do, /login/logout.do
 *
 * @author DevSync
 * @since 2026-05-28
 */
public class SessionCheckInterceptor extends HandlerInterceptorAdapter {

    public static final Logger logger = LoggerFactory.getLogger(SessionCheckInterceptor.class);
    public static final String SESSION_KEY = "login";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {

        HttpSession session = request.getSession(false);

        // 세션이 없거나 로그인 정보가 없으면 → 로그인 화면으로
        if (session == null || session.getAttribute(SESSION_KEY) == null) {
            logger.debug("▶ 세션 없음 → 로그인 화면으로 리다이렉트: URI=" + request.getRequestURI());
            response.sendRedirect(request.getContextPath() + "/login/login.do");
            return false;
        }

        logger.debug("▶ 세션 체크 통과: userId="
                + ((kr.co.TRSolution.trsIbp.user.vo.UserVO) session.getAttribute(SESSION_KEY)).getUserId());
        return true;
    }
}
