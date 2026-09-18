<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync - 조직 관리"/>
    </jsp:include>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/dept/organization.css">
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen min-w-0">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp">
        <jsp:param name="dsPageTitle" value="조직 관리"/>
    </jsp:include>
    <main class="ds-page">
        <div class="ds-breadcrumb">회사 관리 &gt; 조직 관리</div>
        <div class="ds-page-head">
            <div>
                <h1 class="ds-page-title">조직 관리</h1>
                <p class="ds-page-desc">전체 조직을 한 화면에서 확인하고 카드에서 하위 조직과 상세정보를 관리합니다.</p>
            </div>
            <div class="ds-actions">
                <button type="button" id="orgExpandBtn" class="ds-btn ds-btn-outline">전체 접기</button>
                <button type="button" id="orgAddBtn" class="ds-btn ds-btn-primary" data-authority-code="MANAGEMENT_ORG_REG"><i class="fa-solid fa-plus"></i> 조직 추가</button>
            </div>
        </div>

        <section class="ds-org-stats">
            <article class="ds-card ds-org-stat"><span>회사</span><strong id="orgCompanyName">-</strong><em>사용 중</em></article>
            <article class="ds-card ds-org-stat"><span>운영 조직</span><strong id="orgCount">0</strong><em>본부 · 부서 · 팀</em></article>
            <article class="ds-card ds-org-stat"><span>전체 구성원</span><strong id="orgMemberCount">0명</strong><em>재직 사용자 기준</em></article>
            <article class="ds-card ds-org-stat"><span>미배정 사용자</span><strong id="orgUnassignedCount">0명</strong><em class="is-warning">조직 배정 필요</em></article>
        </section>

        <section class="ds-card ds-org-chart-workspace">
            <header class="ds-org-chart-head">
                <div><h2>전체 조직도</h2><p>카드 또는 화살표로 하위 조직을 접고 펼칠 수 있습니다.</p></div>
                <div class="ds-org-chart-tools">
                    <label class="ds-org-search"><i class="fa-solid fa-magnifying-glass"></i><input type="search" id="orgKeyword" placeholder="조직명 또는 코드 검색"></label>
                    <button type="button" id="orgResetViewBtn" class="ds-btn ds-btn-outline ds-btn-sm"><i class="fa-solid fa-house"></i> 전체 보기</button>
                </div>
            </header>
            <div class="ds-org-guide">
                <span><i></i><b>카드/▼</b> 하위 조직 접기·펼치기</span>
                <span><i></i><b>＋</b> 하위 조직 추가</span>
                <span><i></i><b>상세</b> 조직정보·수정·삭제</span>
            </div>
            <div class="ds-org-chart-scroll"><div id="orgChart" class="ds-org-chart"></div></div>
        </section>
    </main>
</div>

<div id="orgDetailModal" class="ds-modal hidden" aria-hidden="true">
    <div class="ds-modal-dim"></div>
    <section class="ds-modal-panel ds-org-detail-modal-panel" role="dialog" aria-modal="true" aria-labelledby="orgDetailModalTitle">
        <header class="ds-modal-head">
            <div><h3 id="orgDetailModalTitle" class="ds-modal-title">조직 상세</h3><p class="ds-modal-desc">선택한 조직의 기본정보와 소속 구성원입니다.</p></div>
            <button type="button" class="ds-modal-close" data-org-detail-close aria-label="닫기"><i class="fa-solid fa-xmark"></i></button>
        </header>
        <div id="orgDetailModalBody" class="ds-org-detail-modal-body"></div>
        <footer class="ds-org-detail-modal-foot">
            <button type="button" id="orgDetailDeleteBtn" class="ds-btn ds-btn-danger" data-authority-code="MANAGEMENT_ORG_DEL">삭제</button>
            <span></span>
            <button type="button" class="ds-btn ds-btn-outline" data-org-detail-close>닫기</button>
            <button type="button" id="orgDetailEditBtn" class="ds-btn ds-btn-primary" data-authority-code="MANAGEMENT_ORG_MDFCN">수정</button>
        </footer>
    </section>
</div>

<div id="orgEditModal" class="ds-modal hidden" aria-hidden="true">
    <div class="ds-modal-dim"></div>
    <section class="ds-modal-panel ds-org-modal-panel" role="dialog" aria-modal="true" aria-labelledby="orgModalTitle">
        <header class="ds-modal-head">
            <div><h3 id="orgModalTitle" class="ds-modal-title">조직 추가</h3><p id="orgModalDesc" class="ds-modal-desc">조직 정보를 입력해 주세요.</p></div>
            <button type="button" class="ds-modal-close" id="orgModalCloseBtn" aria-label="닫기"><i class="fa-solid fa-xmark"></i></button>
        </header>
        <form id="orgForm" onsubmit="return false;">
            <input type="hidden" id="orgFormMode" value="insert">
            <div class="ds-org-modal-body">
                <div class="ds-form-12">
                    <div class="ds-field ds-col-6"><label class="required" for="orgDeptSeCd">조직 구분</label><select id="orgDeptSeCd" name="deptSeCd" class="ds-select"><option value="HQ">본부</option><option value="DEPT">부서</option><option value="TEAM">팀</option></select></div>
                    <div class="ds-field ds-col-6"><label for="orgUpDeptId">상위 조직</label><select id="orgUpDeptId" name="upDeptId" class="ds-select"></select></div>
                    <div class="ds-field ds-col-6"><label class="required" for="orgDeptNm">조직명</label><input type="text" id="orgDeptNm" name="deptNm" class="ds-input" maxlength="100" placeholder="예: 플랫폼개발팀"></div>
                    <div class="ds-field ds-col-6"><label class="required" for="orgDeptId">조직 코드</label><input type="text" id="orgDeptId" name="deptId" class="ds-input" maxlength="20" placeholder="예: DEV-PLATFORM"><p class="ds-field-help">영문 대문자, 숫자, 하이픈 2~20자</p></div>
                    <div class="ds-field ds-col-6"><label id="orgMngrLabel" for="orgMngrUserNm">본부장</label><input type="hidden" id="orgMngrUserId" name="mngrUserId"><div class="ds-input-button"><input type="text" id="orgMngrUserNm" class="ds-input" readonly placeholder="미지정"><button type="button" class="ds-btn ds-btn-outline" id="orgManagerSelectBtn">선택</button><button type="button" class="ds-btn ds-btn-outline" id="orgManagerClearBtn">해제</button></div></div>
                    <div class="ds-field ds-col-6"><label for="orgSortDeptSeq">정렬 순서</label><input type="number" id="orgSortDeptSeq" name="sortDeptSeq" class="ds-input" min="0" max="9999" value="1"></div>
                    <div class="ds-field ds-col-12"><label for="orgDeptExpln">설명</label><textarea id="orgDeptExpln" name="deptExpln" class="ds-textarea" maxlength="500" placeholder="조직의 역할이나 담당 업무를 입력합니다."></textarea></div>
                </div>
            </div>
            <footer class="ds-org-modal-foot"><button type="button" class="ds-btn ds-btn-outline" id="orgModalCancelBtn">취소</button><button type="button" class="ds-btn ds-btn-primary" id="orgSaveBtn" data-authority-any="MANAGEMENT_ORG_REG,MANAGEMENT_ORG_MDFCN">저장</button></footer>
        </form>
    </section>
</div>

<jsp:include page="/WEB-INF/jsp/common/userSelectModal.jsp"/>
<div id="orgToast" class="ds-org-toast" role="status" aria-live="polite"><i class="fa-solid fa-circle-check"></i><span></span></div>
<script>window.dsContextPath = '<%=request.getContextPath()%>';</script>
<script>var ctxPath='<%=request.getContextPath()%>';</script>
<script src="<%=request.getContextPath()%>/js/comm/userSelectModal.js"></script>
<script src="<%=request.getContextPath()%>/js/dept/organization.js"></script>
<script>$(function(){ initOrganizationPage(); });</script>
</body>
</html>
