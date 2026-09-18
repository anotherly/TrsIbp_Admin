<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head><jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync - 사업 등록"/></jsp:include></head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen">
<jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="사업 등록"/></jsp:include>
<main class="ds-page">
<div class="ds-breadcrumb">프로젝트/사업 &gt; 계약 관리 &gt; 사업 등록</div>
<div class="ds-page-head"><div><h1 class="ds-page-title">사업 등록</h1><p class="ds-page-desc">사업 기본정보와 핵심 계약정보를 등록합니다.</p></div><div class="ds-actions"><a href="${pageContext.request.contextPath}/biz/bizList.do" class="ds-btn ds-btn-outline">목록</a><button type="button" class="ds-btn ds-btn-primary" data-authority-code="PROJECT_BIZ_REG" onclick="saveBiz();">저장</button></div></div>
<section class="ds-card ds-card-inner"><jsp:include page="/WEB-INF/jsp/biz/bizForm.jsp"><jsp:param name="mode" value="insert"/></jsp:include></section>
</main></div>
<script>var ctxPath='${pageContext.request.contextPath}'; var currentBizId=''; var bizPageMode='insert';</script>
<script src="${pageContext.request.contextPath}/js/biz/biz.js"></script>
<script>$(function(){initBizInsertPage();});</script>
</body></html>
