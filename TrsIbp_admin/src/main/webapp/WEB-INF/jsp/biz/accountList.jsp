<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync - 회계 관리"/>
    </jsp:include>
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp">
        <jsp:param name="dsPageTitle" value="회계 관리"/>
    </jsp:include>
    <main class="ds-page">
        <div class="ds-breadcrumb">프로젝트/사업 &gt; 회계 관리</div>
        <div class="ds-page-head">
            <div><h1 class="ds-page-title">회계 관리</h1><p class="ds-page-desc">사업별 직접비와 투입비 기준 손익을 조회합니다.</p></div>
            <div class="ds-actions"><a href="${pageContext.request.contextPath}/biz/bizList.do" class="ds-btn ds-btn-outline">사업 목록</a></div>
        </div>
        <section class="ds-card ds-card-inner ds-mb-20">
            <div class="ds-form-grid"><div class="ds-field ds-col-span-2"><label for="manageBizId">사업 선택</label><select id="manageBizId" class="ds-select" onchange="changeManagedBiz('account');"><option value="">사업을 선택하십시오.</option></select></div></div>
        </section>
        <section class="ds-card ds-card-inner">
            <div class="ds-section-head"><div><h2 class="ds-section-title">직접비 및 손익</h2><p class="ds-section-desc">직접비는 별도 입력하고 인건비는 투입인력 M/M와 단가로 계산합니다.</p></div>
                <div class="ds-form-actions ds-form-actions-top"><button type="button" class="ds-btn ds-btn-outline" onclick="resetCstForm();">초기화</button><button type="button" class="ds-btn ds-btn-primary" data-authority-any="PROJECT_ACCOUNT_REG,PROJECT_ACCOUNT_MDFCN" onclick="saveBizCst();">저장</button></div>
            </div>
            <section class="ds-summary-grid">
                <div class="ds-summary-card"><div class="ds-summary-label">계약금액</div><div id="profitCtrtAmt" class="ds-summary-value">0</div></div>
                <div class="ds-summary-card"><div class="ds-summary-label">직접비</div><div id="profitDirectCst" class="ds-summary-value">0</div></div>
                <div class="ds-summary-card"><div class="ds-summary-label">인건비</div><div id="profitLaborCst" class="ds-summary-value">0</div></div>
                <div class="ds-summary-card"><div class="ds-summary-label">영업이익</div><div id="profitAmt" class="ds-summary-value">0</div><div id="profitRate" class="ds-summary-hint">0%</div></div>
            </section>
            <div class="ds-form-12 ds-mb-20">
                <input type="hidden" id="frmBizCstSn">
                <div class="ds-field ds-col-3"><label for="frmCstSeCd">비용구분</label><select id="frmCstSeCd" class="ds-select"><option value="">선택</option></select></div>
                <div class="ds-field ds-col-3"><label for="frmCstNm">비용명</label><input type="text" id="frmCstNm" class="ds-input" maxlength="100"></div>
                <div class="ds-field ds-col-3"><label for="frmOcrnCst">발생비용</label><input type="text" id="frmOcrnCst" class="ds-input ds-number-input" inputmode="numeric" autocomplete="off"></div>
                <div class="ds-field ds-col-3"><label for="frmOcrnYmd">발생일자</label><input type="text" id="frmOcrnYmd" class="ds-input ds-date-picker" readonly autocomplete="off"></div>
            </div>
            <div class="ds-table-wrap"><table class="ds-table ds-table-compact"><thead><tr><th>번호</th><th>구분</th><th>비용명</th><th>금액</th><th>발생일자</th><th>관리</th></tr></thead><tbody id="bizCstBody"></tbody></table></div>
        </section>
    </main>
</div>
<script>var ctxPath='${pageContext.request.contextPath}'; var currentBizId=''; var bizPageMode='account';</script>
<script src="${pageContext.request.contextPath}/js/biz/biz.js"></script>
<script>$(function(){ initBizManagePage('account'); });</script>
</body>
</html>
