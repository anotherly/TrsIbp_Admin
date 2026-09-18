<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head><jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync - 프로세스 일정 관리"/></jsp:include></head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="프로세스(일정) 관리"/></jsp:include>
    <main class="ds-page">
        <div class="ds-breadcrumb">프로젝트/사업 &gt; 프로세스(일정) 관리</div>
        <div class="ds-page-head"><div><h1 class="ds-page-title">프로세스(일정) 관리</h1><p class="ds-page-desc">단계별 작업, 완료일, 담당자, 작업내용을 관리합니다.</p></div><div class="ds-actions"><a href="${pageContext.request.contextPath}/biz/bizList.do" class="ds-btn ds-btn-outline">사업 목록</a></div></div>
        <section class="ds-card ds-card-inner ds-mb-20"><div class="ds-form-grid"><div class="ds-field ds-col-span-2"><label for="manageBizId">사업 선택</label><select id="manageBizId" class="ds-select" onchange="changeManagedBiz('schdl');"><option value="">사업을 선택하십시오.</option></select></div></div></section>
        <section class="ds-card ds-card-inner">
            <div class="ds-section-head"><div><h2 class="ds-section-title">일정 등록/수정/삭제</h2><p class="ds-section-desc">사전작업, 수주, 종료, 유지보수 등 사업 프로세스 일정을 관리합니다.</p></div>
                <div class="ds-form-actions ds-form-actions-top"><button type="button" class="ds-btn ds-btn-outline" onclick="resetSchdlForm();">초기화</button><button type="button" class="ds-btn ds-btn-primary" data-authority-any="PROJECT_PROCESS_REG,PROJECT_PROCESS_MDFCN" onclick="saveBizSchdl();">저장</button></div>
            </div>
            <div class="ds-form-12 ds-mb-20">
                <input type="hidden" id="frmBizSchdlSn">
                <div class="ds-field ds-col-3"><label for="frmSchdlSeCd">일정구분</label><select id="frmSchdlSeCd" class="ds-select"><option value="">선택</option></select></div>
                <div class="ds-field ds-col-3"><label for="frmSchdlNm">일정명</label><input type="text" id="frmSchdlNm" class="ds-input" maxlength="200"></div>
                <div class="ds-field ds-col-3"><label for="frmSchdlBgngYmd">시작일</label><input type="text" id="frmSchdlBgngYmd" class="ds-input ds-date-picker" readonly autocomplete="off"></div>
                <div class="ds-field ds-col-3"><label for="frmSchdlEndYmd">종료/완료일</label><input type="text" id="frmSchdlEndYmd" class="ds-input ds-date-picker" readonly autocomplete="off"></div>
                <input type="hidden" id="frmPicId">
                <div class="ds-field ds-col-3"><label for="frmPicDispNm">담당자 추가</label><div class="ds-input-button"><input type="text" id="frmPicDispNm" class="ds-input" readonly placeholder="사용자 검색"><button type="button" class="ds-btn ds-btn-outline" onclick="openUserSelectModal('schdl');">추가</button></div></div>
                <div class="ds-field ds-col-9"><label for="frmSchdlCn">작업내용</label><input type="text" id="frmSchdlCn" class="ds-input" maxlength="1000"></div>
            </div>
            <div class="ds-table-wrap"><table class="ds-table ds-table-compact"><thead><tr><th>번호</th><th>구분</th><th>일정명</th><th>기간</th><th>담당자</th><th>작업내용</th><th>관리</th></tr></thead><tbody id="bizSchdlBody"></tbody></table></div>
        </section>
    </main>
</div>
<jsp:include page="/WEB-INF/jsp/common/userSelectModal.jsp"/>
<script>var ctxPath='${pageContext.request.contextPath}'; var currentBizId=''; var bizPageMode='schdl';</script>
<script src="${pageContext.request.contextPath}/js/biz/biz.js"></script>
<script src="${pageContext.request.contextPath}/js/comm/userSelectModal.js"></script>
<script>$(function(){ initBizManagePage('schdl'); });</script>
</body>
</html>
