<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    /*
     * 루트 접근 라우팅 전용 JSP
     * - /TrsIbp/ 또는 ROOT 배포 시 / 접근 처리
     * - 세션이 있으면 시스템관리자 대시보드로 이동
     * - 세션이 없으면 로그인 화면으로 이동
     * - 실제 화면 렌더링은 /WEB-INF/jsp/admin/dashboard.jsp 에서 수행
     */
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Object login = session.getAttribute("login");

    if (login == null) {
        response.sendRedirect(request.getContextPath() + "/login/login.do");
        return;
    }

    response.sendRedirect(request.getContextPath() + "/admin/dashboard.do");
%>
