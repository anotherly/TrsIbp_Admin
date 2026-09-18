<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<div class="ds-dashboard-stack">
    <section class="ds-dashboard-hero">
        <div>
            <p class="ds-dashboard-eyebrow">DevSync Workspace</p>
            <h1>내 업무 대시보드</h1>
            <p>현재 등록된 일정, 근태와 참여 프로젝트 정보를 한곳에서 확인합니다.</p>
        </div>
        <div class="ds-dashboard-scope">
            <strong><i class="fa-solid fa-shield-halved"></i> 조회 범위</strong>
            <span>로그인 사용자 본인의 일정·근태·참여 프로젝트만 표시</span>
        </div>
    </section>

    <section class="ds-dashboard-kpis">
        <article class="ds-dashboard-card">
            <div class="ds-kpi-label">오늘 일정</div>
            <div class="ds-kpi-value"><fmt:formatNumber value="${dashboardSummary.todayScheduleCount}"/>건</div>
            <div class="ds-kpi-sub">일정·휴가·출장 등 현재 DB 기준</div>
        </article>
        <article class="ds-dashboard-card">
            <div class="ds-kpi-label">참여 중 프로젝트</div>
            <div class="ds-kpi-value is-cyan"><fmt:formatNumber value="${dashboardSummary.myProjectCount}"/>개</div>
            <div class="ds-kpi-sub">현재 투입기간과 진행 상태 기준</div>
        </article>
        <article class="ds-dashboard-card">
            <div class="ds-kpi-label">이번 달 일정</div>
            <div class="ds-kpi-value"><fmt:formatNumber value="${dashboardSummary.monthScheduleCount}"/>건</div>
            <div class="ds-kpi-sub">이번 달과 기간이 겹치는 일정</div>
        </article>
        <article class="ds-dashboard-card">
            <div class="ds-kpi-label">오늘 출근 기록</div>
            <div class="ds-kpi-value is-green">${dashboardSummary.todayAttendCount gt 0 ? '기록됨' : '미기록'}</div>
            <div class="ds-kpi-sub">근태 기록과 실시간 타이머 연동</div>
        </article>
    </section>

    <section class="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <article class="lg:col-span-5 bg-brand-card p-6 rounded-2xl border border-brand-border shadow-xl">
            <div class="flex items-center justify-between mb-4">
                <h3 class="font-bold text-gray-200 text-base">근무 상태</h3>
                <span id="work-location-badge" class="px-2.5 py-0.5 bg-brand-accent/15 border border-brand-accent/30 text-brand-neonBlue text-xs rounded-full font-bold">조회 중</span>
            </div>
            <div id="work-location-options" class="grid grid-cols-4 gap-1.5 mb-2"></div>
            <p id="work-location-notice" class="text-[11px] text-amber-300 min-h-[16px] mb-2"></p>
            <div class="text-center py-3">
                <span id="timer-display" class="text-3xl font-extrabold text-white tracking-widest font-mono">00 : 00 : 00</span>
                <p class="text-xs text-gray-400 mt-1">오늘 총 기록된 근무 시간</p>
            </div>
            <button id="btn-checkout" onclick="triggerCheckOut()" class="w-full mt-3 py-2.5 bg-slate-800 text-gray-500 border border-brand-border rounded-xl text-sm font-bold cursor-not-allowed" disabled>
                <i class="fa-solid fa-arrow-right-from-bracket"></i> 퇴근하기
            </button>
            <div class="mt-3 text-center text-xs text-gray-500 space-y-0.5">
                <p id="checkin-time-display"></p>
                <p id="checkout-time-display"></p>
                <p id="work-time-display"></p>
            </div>
        </article>

        <article class="lg:col-span-7 bg-brand-card p-6 rounded-2xl border border-brand-border shadow-xl">
            <div class="ds-dashboard-card-head">
                <div class="ds-dashboard-card-title">오늘 내 일정</div>
                <a class="ds-dashboard-link" data-authority-code="WORK_SCHEDULE_LIST_SCREEN" href="${pageContext.request.contextPath}/schedule/scheduleList.do">일정 관리 <i class="fa-solid fa-arrow-right"></i></a>
            </div>
            <c:choose>
                <c:when test="${empty dashboardPrimaryList}">
                    <div class="ds-empty">오늘 등록된 일정이 없습니다.</div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${dashboardPrimaryList}">
                        <div class="ds-dashboard-row">
                            <div>
                                <strong><c:out value="${item.schdlNm}"/></strong>
                                <small class="ds-dashboard-muted"><c:out value="${empty item.bizNm ? item.placeNm : item.bizNm}"/></small>
                            </div>
                            <span class="ds-dashboard-muted"><c:choose><c:when test="${item.allDayYn eq 'Y'}">종일</c:when><c:otherwise><c:out value="${item.bgngTm}"/> ~ <c:out value="${item.endTm}"/></c:otherwise></c:choose></span>
                            <span class="ds-dashboard-badge"><c:out value="${item.schdlSeNm}"/></span>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </article>
    </section>

    <c:if test="${canViewScheduleWidget}">
    <section class="bg-brand-card rounded-2xl border border-brand-border shadow-xl overflow-hidden">
        <div class="p-6 border-b border-brand-border bg-slate-950/40 flex flex-col xl:flex-row xl:items-end justify-between gap-4">
            <div>
                <h2 class="text-lg font-bold text-gray-100">스마트 일정 위젯</h2>
                <p class="text-xs text-gray-400">등록된 휴가, 출장, 외근, 회의와 프로젝트 일정을 표시합니다.</p>
            </div>
            <div class="ds-schedule-toolbar">
                <label class="ds-project-filter">프로젝트 필터
                    <select id="dashScheduleProjectFilter" class="ds-select"><option value="">전체 프로젝트</option></select>
                </label>
                <div class="ds-tab-group">
                    <button type="button" data-view-type="all" onclick="changeDashboardScheduleView('all')" class="dash-schedule-tab ds-tab is-active">전체 일정</button>
                    <button type="button" data-view-type="my" onclick="changeDashboardScheduleView('my')" class="dash-schedule-tab ds-tab">내 일정</button>
                    <button type="button" data-view-type="team" onclick="changeDashboardScheduleView('team')" class="dash-schedule-tab ds-tab">팀 일정</button>
                </div>
            </div>
        </div>
        <div class="grid grid-cols-1 lg:grid-cols-12">
            <div class="lg:col-span-7 p-6 border-r border-brand-border bg-slate-950/20">
                <div class="ds-calendar-head">
                    <button type="button" class="ds-icon-btn" onclick="moveDashboardScheduleMonth(-1);">‹</button>
                    <strong id="dashScheduleMonthLabel"></strong>
                    <button type="button" class="ds-icon-btn" onclick="moveDashboardScheduleMonth(1);">›</button>
                </div>
                <div id="dashScheduleCalendarGrid" class="ds-calendar-grid"></div>
                <div id="dashScheduleCalendarLegend" class="ds-calendar-legend">
                    <span><em><i class="ds-dot ds-dot-leave"></i>휴가</em><b data-legend-count="leave">0</b></span>
                    <span><em><i class="ds-dot ds-dot-biztrip"></i>출장</em><b data-legend-count="biztrip">0</b></span>
                    <span><em><i class="ds-dot ds-dot-outside"></i>외근</em><b data-legend-count="outside">0</b></span>
                    <span><em><i class="ds-dot ds-dot-home"></i>재택</em><b data-legend-count="home">0</b></span>
                    <span><em><i class="ds-dot ds-dot-resident"></i>상주</em><b data-legend-count="resident">0</b></span>
                    <span><em><i class="ds-dot ds-dot-meeting"></i>회의</em><b data-legend-count="meeting">0</b></span>
                    <span><em><i class="ds-dot ds-dot-etc"></i>기타</em><b data-legend-count="etc">0</b></span>
                </div>
            </div>
            <div class="lg:col-span-5 p-6">
                <div class="ds-schedule-list-head">
                    <h3 id="dashScheduleSelectedTitle" class="font-bold text-sm text-gray-300"></h3>
                    <a href="${pageContext.request.contextPath}/schedule/scheduleList.do" class="ds-btn ds-btn-outline">캘린더 크게보기</a>
                </div>
                <div id="dashScheduleDayList" class="ds-schedule-list"></div>
            </div>
        </div>
    </section>
    </c:if>

    <section class="bg-brand-card p-6 rounded-2xl border border-brand-border shadow-xl">
        <div class="flex items-center justify-between mb-4">
            <h3 class="font-bold text-gray-200 text-base">오늘의 부서원 상태 공유</h3>
            <span id="teamStatusSummary" class="text-xs bg-slate-900 border border-brand-border px-2 py-1 rounded text-gray-400">조회 중</span>
        </div>
        <div id="teamStatusList" class="grid grid-cols-1 lg:grid-cols-2 gap-3">
            <div class="ds-empty">부서원 상태를 조회 중입니다.</div>
        </div>
    </section>
</div>
