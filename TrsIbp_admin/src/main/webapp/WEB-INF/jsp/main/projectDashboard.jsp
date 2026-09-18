<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="ds-dashboard-stack">
    <section class="ds-dashboard-hero">
        <div>
            <p class="ds-dashboard-eyebrow">DevSync Workspace</p>
            <h1>프로젝트 관리 대시보드</h1>
            <p>현재 DB의 담당·참여 프로젝트와 투입인력, 일정을 기준으로 표시합니다.</p>
        </div>
        <div class="ds-dashboard-scope">
            <strong><i class="fa-solid fa-shield-halved"></i> 조회 범위</strong>
            <span>최고관리자는 회사 전체, 그 외 사용자는 참여 프로젝트만 표시</span>
        </div>
    </section>

    <section class="ds-dashboard-kpis">
        <article class="ds-dashboard-card"><div class="ds-kpi-label">조회 프로젝트</div><div class="ds-kpi-value"><fmt:formatNumber value="${empty dashboardSummary.projectCount ? 0 : dashboardSummary.projectCount}"/>개</div><div class="ds-kpi-sub">권한·참여 범위 기준</div></article>
        <article class="ds-dashboard-card"><div class="ds-kpi-label">진행 프로젝트</div><div class="ds-kpi-value is-cyan"><fmt:formatNumber value="${empty dashboardSummary.activeProjectCount ? 0 : dashboardSummary.activeProjectCount}"/>개</div><div class="ds-kpi-sub">사업상태 `진행` 기준</div></article>
        <article class="ds-dashboard-card"><div class="ds-kpi-label">등록 투입인력</div><div class="ds-kpi-value"><fmt:formatNumber value="${empty dashboardSummary.inputMnpwCount ? 0 : dashboardSummary.inputMnpwCount}"/>명</div><div class="ds-kpi-sub">내부 사용자와 외부인력 포함</div></article>
        <article class="ds-dashboard-card"><div class="ds-kpi-label">30일 내 종료 일정</div><div class="ds-kpi-value is-amber"><fmt:formatNumber value="${empty dashboardSummary.dueScheduleCount ? 0 : dashboardSummary.dueScheduleCount}"/>건</div><div class="ds-kpi-sub">사업 일정 종료일 기준</div></article>
    </section>

    <section class="ds-dashboard-columns">
        <article class="ds-dashboard-card">
            <div class="ds-dashboard-card-head">
                <div class="ds-dashboard-card-title">프로젝트 기간·투입 현황</div>
                <a class="ds-dashboard-link" data-authority-code="PROJECT_BIZ_LIST_SCREEN" href="${pageContext.request.contextPath}/biz/bizList.do">프로젝트 목록 <i class="fa-solid fa-arrow-right"></i></a>
            </div>
            <c:choose>
                <c:when test="${empty dashboardPrimaryList}"><div class="ds-empty">조회 가능한 프로젝트가 없습니다.</div></c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${dashboardPrimaryList}">
                        <div class="ds-dashboard-row">
                            <div>
                                <strong><c:out value="${item.bizNm}"/></strong>
                                <div class="ds-dashboard-progress"><i style="width:${item.periodProgress}%"></i></div>
                            </div>
                            <span class="ds-dashboard-muted">기간 경과 ${item.periodProgress}% · ${item.inputMnpwCount}명</span>
                            <span class="ds-dashboard-badge ${item.bizSttsCd eq 'PRGRS' ? 'is-ok' : ''}"><c:out value="${item.bizSttsNm}"/></span>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </article>
        <article class="ds-dashboard-card">
            <div class="ds-dashboard-card-head"><div class="ds-dashboard-card-title">프로젝트 빠른 실행</div></div>
            <div class="ds-dashboard-quick">
                <a data-authority-code="PROJECT_BIZ_LIST_SCREEN" href="${pageContext.request.contextPath}/biz/bizList.do"><strong><i class="fa-solid fa-diagram-project"></i> 사업 관리</strong><span>목록 · 상세 · 권한별 버튼</span></a>
                <a data-authority-code="PROJECT_CONTRACT_SCREEN" href="${pageContext.request.contextPath}/biz/contractList.do"><strong><i class="fa-solid fa-file-signature"></i> 계약 관리</strong><span>계약 · 고객사 · 관계</span></a>
                <a data-authority-code="PROJECT_MNPW_SCREEN" href="${pageContext.request.contextPath}/biz/mnpwList.do"><strong><i class="fa-solid fa-people-group"></i> 투입인력</strong><span>기간 · M/M · 역할</span></a>
                <a data-authority-code="PROJECT_PROCESS_SCREEN" href="${pageContext.request.contextPath}/biz/schdlList.do"><strong><i class="fa-solid fa-list-check"></i> 프로세스</strong><span>업무 · 일정 · 산출물</span></a>
            </div>
        </article>
    </section>

    <section class="ds-dashboard-card">
        <div class="ds-dashboard-card-head"><div class="ds-dashboard-card-title">다가오는 사업 일정</div></div>
        <c:choose>
            <c:when test="${empty dashboardSecondaryList}"><div class="ds-empty">오늘 이후 등록된 사업 일정이 없습니다.</div></c:when>
            <c:otherwise>
                <c:forEach var="item" items="${dashboardSecondaryList}">
                    <div class="ds-dashboard-row">
                        <div><strong><c:out value="${item.schdlNm}"/></strong><small class="ds-dashboard-muted"><c:out value="${item.bizNm}"/></small></div>
                        <span class="ds-dashboard-muted"><c:out value="${empty item.picNm ? '담당자 미지정' : item.picNm}"/></span>
                        <span class="ds-dashboard-badge ${item.remainDay le 7 ? 'is-warn' : ''}">D-${item.remainDay}</span>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </section>
</div>
