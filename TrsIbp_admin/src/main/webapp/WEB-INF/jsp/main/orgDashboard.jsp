<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="ds-dashboard-stack">
    <section class="ds-dashboard-hero">
        <div>
            <p class="ds-dashboard-eyebrow">DevSync Workspace</p>
            <h1>조직 관리 대시보드</h1>
            <p>현재 조직도, 사용자, 근태, 일정과 투입인력 데이터를 집계합니다.</p>
        </div>
        <div class="ds-dashboard-scope">
            <strong><i class="fa-solid fa-shield-halved"></i> 조회 범위</strong>
            <span>최고관리자는 회사 전체, 조직장은 본인 부서와 하위 조직 기준</span>
        </div>
    </section>

    <section class="ds-dashboard-kpis">
        <article class="ds-dashboard-card"><div class="ds-kpi-label">조직원</div><div class="ds-kpi-value"><fmt:formatNumber value="${empty dashboardSummary.orgUserCount ? 0 : dashboardSummary.orgUserCount}"/>명</div><div class="ds-kpi-sub">사용 중인 사용자 기준</div></article>
        <article class="ds-dashboard-card"><div class="ds-kpi-label">오늘 출근 기록</div><div class="ds-kpi-value is-green"><fmt:formatNumber value="${empty dashboardSummary.todayAttendCount ? 0 : dashboardSummary.todayAttendCount}"/>명</div><div class="ds-kpi-sub">출근시간이 기록된 인원</div></article>
        <article class="ds-dashboard-card"><div class="ds-kpi-label">외부·부재 일정</div><div class="ds-kpi-value is-cyan"><fmt:formatNumber value="${empty dashboardSummary.externalUserCount ? 0 : dashboardSummary.externalUserCount}"/>명</div><div class="ds-kpi-sub">휴가·출장·외근·재택·상주</div></article>
        <article class="ds-dashboard-card"><div class="ds-kpi-label">평균 투입률</div><div class="ds-kpi-value is-amber"><fmt:formatNumber value="${empty dashboardSummary.avgInputRate ? 0 : dashboardSummary.avgInputRate}"/>%</div><div class="ds-kpi-sub">과투입 ${empty dashboardSummary.overInputUserCount ? 0 : dashboardSummary.overInputUserCount}명</div></article>
    </section>

    <section class="ds-dashboard-columns">
        <article class="ds-dashboard-card">
            <div class="ds-dashboard-card-head"><div class="ds-dashboard-card-title">조직별 근무·투입 현황</div></div>
            <c:choose>
                <c:when test="${empty dashboardPrimaryList}"><div class="ds-empty">조회할 조직이 없습니다.</div></c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${dashboardPrimaryList}">
                        <div class="ds-dashboard-row">
                            <strong><c:out value="${item.deptNm}"/></strong>
                            <span class="ds-dashboard-muted">출근 ${item.attendCount} / ${item.userCount}명</span>
                            <span class="ds-dashboard-badge ${item.avgInputRate gt 100 ? 'is-danger' : 'is-ok'}">투입 ${item.avgInputRate}%</span>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </article>
        <article class="ds-dashboard-card">
            <div class="ds-dashboard-card-head"><div class="ds-dashboard-card-title">오늘 조직 일정</div></div>
            <c:choose>
                <c:when test="${empty dashboardSecondaryList}"><div class="ds-empty">오늘 조직 일정이 없습니다.</div></c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${dashboardSecondaryList}">
                        <div class="ds-dashboard-row">
                            <div><strong><c:out value="${item.schdlNm}"/></strong><small class="ds-dashboard-muted"><c:out value="${item.userNm}"/> · <c:out value="${item.deptNm}"/></small></div>
                            <span class="ds-dashboard-muted">${item.bgngTm} ~ ${item.endTm}</span>
                            <span class="ds-dashboard-badge"><c:out value="${item.schdlSeNm}"/></span>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </article>
    </section>
</div>
