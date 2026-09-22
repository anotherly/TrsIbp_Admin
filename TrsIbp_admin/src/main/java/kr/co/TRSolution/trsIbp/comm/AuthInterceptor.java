package kr.co.TRSolution.trsIbp.comm;

import java.io.IOException;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import kr.co.TRSolution.trsIbp.admin.service.AdminService;
import kr.co.TRSolution.trsIbp.admin.vo.AdminVO;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

/**
 * 시스템관리자 사이트 전용 접근제어.
 *
 * 회사 내부 ADMIN과 시스템 전체 운영자인 SYS_ADMIN을 명확히 분리하고,
 * 관리자 사이트에서 사용하지 않는 기존 업무 URL 직접 접근도 차단한다.
 */
public class AuthInterceptor extends HandlerInterceptorAdapter {

    private static final Logger logger = LoggerFactory.getLogger(AuthInterceptor.class);

    @Resource(name = "adminService")
    private AdminService adminService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
        if (loginUser == null) {
            return true;
        }

        String requestUrl = request.getRequestURI().substring(request.getContextPath().length());
        if (!"SYS_ADMIN".equals(loginUser.getAuthrtId())) {
            logger.warn("시스템관리자 권한 거부 userId=" + loginUser.getUserId()
                    + ", authrtId=" + loginUser.getAuthrtId()
                    + ", url=" + requestUrl);
            recordDenied(request, loginUser, "시스템관리자 권한 없음");
            request.getSession().invalidate();
            if (requestUrl.endsWith(".ajax")) {
                writeDeniedJson(response, "시스템관리자 권한이 필요합니다.");
            } else {
                response.sendRedirect(request.getContextPath() + "/login/login.do");
            }
            return false;
        }

        if (isAdminSiteUrl(requestUrl)) {
            return true;
        }

        logger.warn("관리자 사이트 미사용 기능 직접 접근 차단 userId=" + loginUser.getUserId()
                + ", url=" + requestUrl);
        recordDenied(request, loginUser, "관리자 사이트 미사용 기능 직접 접근");
        deny(requestUrl, request, response, "관리자 사이트에서 제공하지 않는 기능입니다.");
        return false;
    }

    private boolean isAdminSiteUrl(String requestUrl) {
        return "/admin/dashboard.do".equals(requestUrl)
                || "/admin/companyRequestList.do".equals(requestUrl)
                || "/admin/companyRequestDetail.ajax".equals(requestUrl)
                || "/admin/companyRequestApprove.ajax".equals(requestUrl)
                || "/admin/companyRequestReject.ajax".equals(requestUrl)
                || "/admin/companyRequestFile.do".equals(requestUrl)
                || "/admin/companyList.do".equals(requestUrl)
                || "/admin/companyUseUpdate.ajax".equals(requestUrl)
                || "/admin/userList.do".equals(requestUrl)
                || "/admin/userUseUpdate.ajax".equals(requestUrl)
                || "/admin/systemLogList.do".equals(requestUrl)
                || "/admin/actionHistoryList.do".equals(requestUrl)
                || "/admin/userActionLogList.do".equals(requestUrl)
                || "/admin/systemNoticeList.do".equals(requestUrl)
                || "/admin/systemNoticeSave.ajax".equals(requestUrl)
                || "/admin/systemNoticeDelete.ajax".equals(requestUrl)
                || "/admin/operationPolicy.do".equals(requestUrl)
                || "/admin/commonCodeUseUpdate.ajax".equals(requestUrl)
                || "/admin/operationPolicyUpdate.ajax".equals(requestUrl)
                || "/main/main.do".equals(requestUrl)
                || "/login/logout.do".equals(requestUrl)
                || requestUrl.startsWith("/cmmn/");
    }

    private void deny(String requestUrl, HttpServletRequest request,
            HttpServletResponse response, String message) throws IOException {
        if (requestUrl.endsWith(".ajax")) {
            writeDeniedJson(response, message);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/admin/dashboard.do?authDenied=Y");
    }

    private void writeDeniedJson(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"result\":\"DENIED\",\"msg\":\"" + message + "\"}");
    }

    private void recordDenied(HttpServletRequest request, UserVO loginUser, String reason) {
        AdminVO log = new AdminVO();
        log.setUserId(loginUser.getUserId());
        log.setLogSeCd("AUTH_ERROR");
        log.setLogLevelCd("WARN");
        log.setLogTitle("관리자 접근권한 오류");
        log.setLogCn(reason);
        log.setRequestUri(request.getRequestURI());
        log.setClientIpAddr(request.getRemoteAddr());
        adminService.recordSystemLog(log);
    }
}
