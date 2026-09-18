<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync - 종합 일정 캘린더"/>
    </jsp:include>
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp">
        <jsp:param name="dsPageTitle" value="대시보드 홈"/>
    </jsp:include>
    <main class="ds-page">
        <div class="ds-breadcrumb">일정/공유 &gt; 종합 일정 캘린더</div>
        <div class="ds-page-head">
            <div>
                <h1 class="ds-page-title">종합 일정 캘린더</h1>
                <p class="ds-page-desc">휴가, 출장, 외근, 회의, 기타 일정을 등록하고 월별로 조회합니다.</p>
            </div>
            <div class="ds-actions"><button type="button" class="ds-btn ds-btn-primary" data-authority-code="WORK_SCHEDULE_REG" onclick="openScheduleModal();">+ 새 일정 등록</button></div>
        </div>

        <section class="ds-card ds-card-inner">
            <div class="ds-section-head ds-schedule-section-head">
                <div>
                    <h2 class="ds-section-title">일정 조회</h2>
                    <p class="ds-section-desc">일자를 선택하면 우측 목록에 해당 일자의 일정이 표시됩니다.</p>
                </div>
                <div class="ds-schedule-toolbar">
                    <label class="ds-project-filter">프로젝트 필터<select id="scheduleProjectFilter" class="ds-select"><option value="">전체 프로젝트</option></select></label>
                    <div class="ds-tab-group">
                        <button type="button" class="ds-tab is-active" data-view-type="all" onclick="changeScheduleView('all');">전체 일정</button>
                        <button type="button" class="ds-tab" data-view-type="my" onclick="changeScheduleView('my');">내 일정</button>
                        <button type="button" class="ds-tab" data-view-type="team" onclick="changeScheduleView('team');">팀 일정</button>
                    </div>
                </div>
            </div>
            <div class="ds-calendar-layout">
                <div class="ds-calendar-box">
                    <div class="ds-calendar-head">
                        <button type="button" class="ds-icon-btn" onclick="moveScheduleMonth(-1);">‹</button>
                        <strong id="scheduleMonthLabel"></strong>
                        <button type="button" class="ds-icon-btn" onclick="moveScheduleMonth(1);">›</button>
                    </div>
                    <div id="scheduleCalendarGrid" class="ds-calendar-grid"></div>
                    <div id="scheduleCalendarLegend" class="ds-calendar-legend">
                        <span><em><i class="ds-dot ds-dot-leave"></i>휴가</em><b data-legend-count="leave">0</b></span>
                        <span><em><i class="ds-dot ds-dot-biztrip"></i>출장</em><b data-legend-count="biztrip">0</b></span>
                        <span><em><i class="ds-dot ds-dot-outside"></i>외근</em><b data-legend-count="outside">0</b></span>
                        <span><em><i class="ds-dot ds-dot-home"></i>재택</em><b data-legend-count="home">0</b></span>
                        <span><em><i class="ds-dot ds-dot-resident"></i>상주</em><b data-legend-count="resident">0</b></span>
                        <span><em><i class="ds-dot ds-dot-meeting"></i>회의</em><b data-legend-count="meeting">0</b></span>
                        <span><em><i class="ds-dot ds-dot-etc"></i>기타</em><b data-legend-count="etc">0</b></span>
                    </div>
                </div>
                <div class="ds-schedule-list-box">
                    <div class="ds-schedule-list-head">
                        <h3 id="scheduleSelectedDateTitle"></h3>
                    </div>
                    <div id="scheduleDayList" class="ds-schedule-list"></div>
                </div>
            </div>
        </section>
    </main>
</div>

<div id="scheduleModal" class="ds-modal hidden" aria-hidden="true">
    <div class="ds-modal-dim"></div>
    <div class="ds-modal-panel ds-schedule-modal-panel" role="dialog" aria-modal="true">
        <div class="ds-modal-head">
            <div><h3 id="scheduleModalTitle" class="ds-modal-title">일정 등록</h3><p class="ds-modal-desc">여러 대상자를 선택해 같은 일정을 한 번에 등록할 수 있습니다.</p></div>
            <button type="button" class="ds-modal-close" onclick="closeScheduleModal();">×</button>
        </div>
        <input type="hidden" id="frmSchdlSn">
        <input type="hidden" id="frmTargetUserIds">
        <div class="ds-schedule-modal-body">
            <div class="ds-form-grid ds-form-12">
                <div class="ds-field ds-col-6"><label class="required">일정구분</label><select id="frmCalSchdlSeCd" class="ds-select"></select></div>
                <div id="scheduleNameField" class="ds-field ds-col-6"><label class="required">일정명</label><input type="text" id="frmCalSchdlNm" class="ds-input" maxlength="100"></div>
                <div id="vacationTypeField" class="ds-field ds-col-6 hidden"><label class="required">휴가구분</label><select id="frmVacSeCd" class="ds-select"><option value="ANNUAL">연차</option><option value="HALF">반차</option><option value="HOURLY">시간대</option></select></div>
                <div class="ds-field ds-col-6"><label>프로젝트 명</label><select id="frmBizId" class="ds-select"><option value="">할당되지 않음</option></select></div>
                <div class="ds-field ds-col-6"><label>장소</label><input type="text" id="frmPlaceNm" class="ds-input" maxlength="100"></div>
                <div class="ds-field ds-col-12"><label class="required">대상자</label><div class="ds-input-action-row"><div id="scheduleTargetChips" class="ds-chip-box"></div><button type="button" class="ds-btn ds-btn-outline" onclick="openUserSelectModal('scheduleMulti');">대상자 선택</button></div></div>
                <div id="scheduleConflictMessage" class="ds-schedule-conflict hidden ds-col-12" role="alert" aria-live="assertive"></div>
                <div class="ds-field ds-col-4"><label>종일여부</label><select id="frmAllDayYn" class="ds-select"><option value="N">시간 지정</option><option value="Y">종일</option></select></div>
                <div class="ds-field ds-col-4"><label class="required">시작일시</label><input type="text" id="frmBgngDt" class="ds-input ds-datetime-picker" readonly autocomplete="off"></div>
                <div class="ds-field ds-col-4"><label class="required">종료일시</label><input type="text" id="frmEndDt" class="ds-input ds-datetime-picker" readonly autocomplete="off"></div>
                <div class="ds-field ds-col-12"><label>상세내용</label><textarea id="frmCalSchdlCn" class="ds-textarea" maxlength="1000"></textarea></div>
            </div>
        </div>
        <div class="ds-modal-actions ds-schedule-modal-actions"><button type="button" id="scheduleDeleteButton" class="ds-btn ds-btn-outline" data-authority-code="WORK_SCHEDULE_DEL" onclick="deleteScheduleFromModal();">삭제</button><button type="button" id="scheduleSaveButton" class="ds-btn ds-btn-primary" data-authority-any="WORK_SCHEDULE_REG,WORK_SCHEDULE_MDFCN" onclick="saveSchedule();">저장</button></div>
    </div>
</div>
<jsp:include page="/WEB-INF/jsp/common/userSelectModal.jsp"/>
<script>var ctxPath='${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/comm/userSelectModal.js"></script>
<script src="${pageContext.request.contextPath}/js/schedule/schedule.js"></script>
<script>$(function(){ initSchedulePage(); });</script>
</body>
</html>
