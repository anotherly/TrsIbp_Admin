<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head><jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync - 사용자 수정"/></jsp:include></head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="사용자 수정"/></jsp:include>
    <main class="ds-page">
        <div class="ds-breadcrumb">회사 관리 &gt; 사용자 관리 &gt; 수정</div>
        <div class="ds-page-head"><div><h1 class="ds-page-title">사용자 수정</h1><p class="ds-page-desc">직원 계정 정보를 수정합니다.</p></div><div class="ds-actions"><button type="button" class="ds-btn ds-btn-outline" onclick="goEmpDetail($('#frmUserId').val());">상세</button><button type="button" class="ds-btn ds-btn-primary" data-authority-code="MANAGEMENT_USER_MDFCN" onclick="saveEmp();">저장</button></div></div>
        <jsp:include page="/WEB-INF/jsp/user/empForm.jsp">
            <jsp:param name="mode" value="update"/>
            <jsp:param name="updateToken" value="${updateToken}"/>
        </jsp:include>
    </main>
</div>
<jsp:include page="/WEB-INF/jsp/common/deptSelectModal.jsp"/>
<script>var ctxPath='<%=request.getContextPath()%>';</script>
<script src="<%=request.getContextPath()%>/js/comm/deptSelectModal.js"></script>
<script src="<%=request.getContextPath()%>/js/user/userManage.js"></script>
<script>$(function(){ initEmpFormPage('update', '${userId}'); });</script>
</body>
</html>
