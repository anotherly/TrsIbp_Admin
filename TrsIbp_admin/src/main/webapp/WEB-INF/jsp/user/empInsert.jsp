<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head><jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync - 사용자 등록"/></jsp:include></head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="사용자 등록"/></jsp:include>
    <main class="ds-page">
        <div class="ds-breadcrumb">회사 관리 &gt; 사용자 관리 &gt; 등록</div>
        <div class="ds-page-head"><div><h1 class="ds-page-title">사용자 등록</h1><p class="ds-page-desc">신규 직원 계정을 등록합니다.</p></div><div class="ds-actions"><button type="button" class="ds-btn ds-btn-outline" onclick="goEmpList();">목록</button><button type="button" class="ds-btn ds-btn-primary" data-authority-code="MANAGEMENT_USER_REG" onclick="saveEmp();">저장</button></div></div>
        <jsp:include page="/WEB-INF/jsp/user/empForm.jsp"><jsp:param name="mode" value="insert"/></jsp:include>
    </main>
</div>
<jsp:include page="/WEB-INF/jsp/common/deptSelectModal.jsp"/>
<script>var ctxPath='<%=request.getContextPath()%>';</script>
<script src="<%=request.getContextPath()%>/js/comm/deptSelectModal.js"></script>
<script src="<%=request.getContextPath()%>/js/user/userManage.js"></script>
<script>$(function(){ initEmpFormPage('insert', ''); });</script>
</body>
</html>
