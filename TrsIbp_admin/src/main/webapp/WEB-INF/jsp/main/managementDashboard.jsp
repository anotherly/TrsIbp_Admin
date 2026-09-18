<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="ds-dashboard-stack">
    <section class="ds-dashboard-hero">
        <div>
            <p class="ds-dashboard-eyebrow">DevSync Workspace</p>
            <h1>경영 관리 대시보드</h1>
            <p>현재 사용자, 진행 사업, 계약금액과 발생비용 데이터를 종합합니다.</p>
        </div>
        <div class="ds-dashboard-scope">
            <strong><i class="fa-solid fa-shield-halved"></i> 조회 범위</strong>
            <span>회사 범위와 부여된 계약·회계 세부권한에 따라 금액 표시</span>
        </div>
    </section>

    <section class="ds-dashboard-kpis">
        <article class="ds-dashboard-card"><div class="ds-kpi-label">재직 인원</div><div class="ds-kpi-value"><fmt:formatNumber value="${empty dashboardSummary.employeeCount ? 0 : dashboardSummary.employeeCount}"/>명</div><div class="ds-kpi-sub">사용 중인 사용자 기준</div></article>
        <article class="ds-dashboard-card"><div class="ds-kpi-label">진행 사업</div><div class="ds-kpi-value is-cyan"><fmt:formatNumber value="${empty dashboardSummary.activeProjectCount ? 0 : dashboardSummary.activeProjectCount}"/>개</div><div class="ds-kpi-sub">사업상태 `진행` 기준</div></article>
        <article class="ds-dashboard-card">
            <div class="ds-kpi-label">진행 사업 계약금액</div>
            <c:choose>
                <c:when test="${canViewContractAmount}"><div class="ds-kpi-value"><fmt:formatNumber value="${empty dashboardSummary.activeContractAmount ? 0 : dashboardSummary.activeContractAmount}"/>원</div><div class="ds-kpi-sub">진행 사업 계약금액 합계</div></c:when>
                <c:otherwise><div class="ds-kpi-value is-locked">권한 없음</div><div class="ds-kpi-sub">계약 조회권한 필요</div></c:otherwise>
            </c:choose>
        </article>
        <article class="ds-dashboard-card">
            <div class="ds-kpi-label">이번 달 발생비용</div>
            <c:choose>
                <c:when test="${canViewCostAmount}"><div class="ds-kpi-value is-amber"><fmt:formatNumber value="${empty dashboardSummary.monthCostAmount ? 0 : dashboardSummary.monthCostAmount}"/>원</div><div class="ds-kpi-sub">발생일자 기준 직접비 합계</div></c:when>
                <c:otherwise><div class="ds-kpi-value is-locked">권한 없음</div><div class="ds-kpi-sub">회계 조회권한 필요</div></c:otherwise>
            </c:choose>
        </article>
    </section>

    <section class="ds-dashboard-columns">
        <article class="ds-dashboard-card">
            <div class="ds-dashboard-card-head">
                <div class="ds-dashboard-card-title">진행 사업 현황</div>
                <span class="ds-dashboard-link">이번 달 신규 계약 ${empty dashboardSummary.monthContractCount ? 0 : dashboardSummary.monthContractCount}건</span>
            </div>
            <c:choose>
                <c:when test="${empty dashboardPrimaryList}"><div class="ds-empty">진행 중인 사업이 없습니다.</div></c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${dashboardPrimaryList}">
                        <div class="ds-dashboard-row">
                            <div><strong><c:out value="${item.bizNm}"/></strong><small class="ds-dashboard-muted">종료일 <c:out value="${item.bizEndYmd}"/></small></div>
                            <c:choose>
                                <c:when test="${canViewContractAmount}"><span class="ds-dashboard-muted">계약 <fmt:formatNumber value="${item.ctrtAmt}"/>원</span></c:when>
                                <c:otherwise><span class="ds-dashboard-muted">계약금액 비공개</span></c:otherwise>
                            </c:choose>
                            <c:choose>
                                <c:when test="${canViewCostAmount}"><span class="ds-dashboard-badge ${item.currentProfitAmt lt 0 ? 'is-danger' : 'is-ok'}">현재차액 <fmt:formatNumber value="${item.currentProfitAmt}"/>원</span></c:when>
                                <c:otherwise><span class="ds-dashboard-badge">회계권한 필요</span></c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </article>
        <article class="ds-dashboard-card">
            <div class="ds-dashboard-card-head"><div class="ds-dashboard-card-title">경영 빠른 실행</div></div>
            <div class="ds-dashboard-quick">
                <a data-authority-code="MANAGEMENT_USER_SCREEN" href="${pageContext.request.contextPath}/user/empList.do"><strong><i class="fa-solid fa-id-card"></i> 사용자 관리</strong><span>목록 · 상세 · 권한별 버튼</span></a>
                <a data-authority-code="PROJECT_CONTRACT_SCREEN" href="${pageContext.request.contextPath}/biz/contractList.do"><strong><i class="fa-solid fa-file-signature"></i> 계약 관리</strong><span>계약 · 고객사 · 관계</span></a>
                <a data-authority-code="PROJECT_ACCOUNT_SCREEN" href="${pageContext.request.contextPath}/biz/accountList.do"><strong><i class="fa-solid fa-coins"></i> 회계·손익</strong><span>비용 · 현재 손익</span></a>
                <a data-authority-code="MANAGEMENT_AUTHRT_SCREEN" href="${pageContext.request.contextPath}/authority/authorityManage.do"><strong><i class="fa-solid fa-shield-halved"></i> 역할·권한</strong><span>업무공간 · 기능 권한</span></a>
            </div>
        </article>
    </section>
</div>
