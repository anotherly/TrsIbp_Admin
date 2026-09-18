<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync - 계약 관리"/>
    </jsp:include>
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>

<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp">
        <jsp:param name="dsPageTitle" value="계약 관리"/>
    </jsp:include>

    <main class="ds-page">
        <div class="ds-breadcrumb">프로젝트/사업 &gt; 계약 관리</div>
        <div class="ds-page-head">
            <div>
                <h1 class="ds-page-title">계약 관리</h1>
                <p class="ds-page-desc">사업별 고객사와 발주처 계약 관계를 등록, 수정, 삭제합니다.</p>
            </div>
            <div class="ds-actions">
                <a href="${pageContext.request.contextPath}/biz/bizList.do" class="ds-btn ds-btn-outline">사업 목록</a>
            </div>
        </div>

        <section class="ds-card ds-card-inner ds-mb-20">
            <div class="ds-form-grid">
                <div class="ds-field ds-col-span-2">
                    <label for="manageBizId">사업 선택</label>
                    <select id="manageBizId" class="ds-select" onchange="changeManagedBiz('contract');">
                        <option value="">사업을 선택하십시오.</option>
                    </select>
                </div>
            </div>
        </section>

        <section class="ds-card ds-card-inner">
            <div class="ds-section-head">
                <div>
                    <h2 class="ds-section-title">고객사/발주처 계약관계</h2>
                    <p class="ds-section-desc">갑/을/병/정 관계와 직접계약 여부를 관리합니다.</p>
                </div>
                <div class="ds-form-actions ds-form-actions-top">
                    <button type="button" class="ds-btn ds-btn-outline" onclick="resetCustRelForm();">초기화</button>
                    <button type="button" class="ds-btn ds-btn-primary" data-authority-any="PROJECT_CONTRACT_REG,PROJECT_CONTRACT_MDFCN" onclick="saveCustAndRel();">저장</button>
                </div>
            </div>
            <div class="ds-form-12 ds-mb-20">
                <input type="hidden" id="frmCustSn">
                <input type="hidden" id="frmBizCustRelSn">
                <div class="ds-field ds-col-3"><label for="frmCustCoNm">고객사명</label><input type="text" id="frmCustCoNm" class="ds-input" maxlength="100"></div>
                <div class="ds-field ds-col-3"><label for="frmCustSeCd">고객구분</label><select id="frmCustSeCd" class="ds-select"><option value="">선택</option></select></div>
                <div class="ds-field ds-col-3"><label for="frmBrno">사업자등록번호</label><input type="text" id="frmBrno" class="ds-input" maxlength="20"></div>
                <div class="ds-field ds-col-3"><label for="frmRprsvNm">대표자명</label><input type="text" id="frmRprsvNm" class="ds-input" maxlength="50"></div>

                <div class="ds-field ds-col-3"><label for="frmTelno">전화번호</label><input type="text" id="frmTelno" class="ds-input" maxlength="20"></div>
                <div class="ds-field ds-col-3"><label for="frmAddr">주소</label><input type="text" id="frmAddr" class="ds-input" maxlength="300"></div>
                <div class="ds-field ds-col-2"><label for="frmRelSeCd">계약관계</label><select id="frmRelSeCd" class="ds-select"><option value="">선택</option></select></div>
                <div class="ds-field ds-col-2"><label for="frmRelLvl">관계레벨</label><input type="text" id="frmRelLvl" class="ds-input ds-number-input" inputmode="numeric" autocomplete="off"></div>
                <div class="ds-field ds-col-2"><label for="frmDirectCtrtYn">직접계약여부</label><select id="frmDirectCtrtYn" class="ds-select"><option value="N">N</option><option value="Y">Y</option></select></div>

            </div>
            <div class="ds-table-wrap">
                <table class="ds-table ds-table-compact">
                    <thead><tr><th>번호</th><th>고객사</th><th>구분</th><th>계약관계</th><th>레벨</th><th>직접계약</th><th>관리</th></tr></thead>
                    <tbody id="bizCustRelBody"></tbody>
                </table>
            </div>
        </section>
    </main>
</div>

<script>
    var ctxPath = '${pageContext.request.contextPath}';
    var currentBizId = '';
    var bizPageMode = 'contract';
</script>
<script src="${pageContext.request.contextPath}/js/biz/biz.js"></script>
<script>
    $(function() {
        initBizManagePage('contract');
    });
</script>
</body>
</html>
