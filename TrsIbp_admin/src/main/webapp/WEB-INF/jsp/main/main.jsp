<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync - IT 개발사 스마트 대시보드"/>
    </jsp:include>
</head>
<body class="ds-body min-h-screen flex">
    <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
    <c:set var="workspace" value="${empty requestScope.selectedWorkspace ? 'work' : requestScope.selectedWorkspace}"/>
    <div class="flex-grow flex flex-col min-h-screen">
        <jsp:include page="/WEB-INF/jsp/common/header.jsp">
            <jsp:param name="dsPageTitle" value="대시보드 홈"/>
        </jsp:include>
        <main class="flex-grow p-8 space-y-6 max-w-7xl mx-auto w-full">
            <c:choose>
                <c:when test="${workspace eq 'project'}">
                    <jsp:include page="/WEB-INF/jsp/main/projectDashboard.jsp"/>
                </c:when>
                <c:when test="${workspace eq 'org'}">
                    <jsp:include page="/WEB-INF/jsp/main/orgDashboard.jsp"/>
                </c:when>
                <c:when test="${workspace eq 'management'}">
                    <jsp:include page="/WEB-INF/jsp/main/managementDashboard.jsp"/>
                </c:when>
                <c:otherwise>
                    <jsp:include page="/WEB-INF/jsp/main/workDashboard.jsp"/>
                </c:otherwise>
            </c:choose>
        </main>
    </div>

    <script>var ctxPath = '<%=request.getContextPath()%>';</script>
    <c:if test="${workspace eq 'work'}">
        <script src="<%=request.getContextPath()%>/js/dashboard.js"></script>
        <script src="<%=request.getContextPath()%>/js/schedule/schedule.js"></script>
        <script>
            $(function() {
                if (${canViewScheduleWidget ? 'true' : 'false'} && typeof initDashboardScheduleWidget === 'function') {
                    initDashboardScheduleWidget();
                }
            });
        </script>
    </c:if>
    <c:if test="${param.authDenied eq 'Y'}">
        <script>$(function(){ if (typeof showToast === 'function') showToast('해당 화면을 사용할 권한이 없습니다.', 'error'); });</script>
    </c:if>
</body>
</html>
