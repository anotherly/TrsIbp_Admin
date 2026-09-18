/**
 * DevSync - IT 개발사 스마트 대시보드 인터랙션 스크립트
 * 파일명: dashboard.js
 * 설명: index.jsp 비동기 통신 및 UI 제어 전용 스크립트 (jQuery 기반)
 * 수정이력: 2026-05-28 - 자동 출근 연동 및 근무지 상태 제어 함수 추가
 */

/* ============================================================
   0. 전역 변수 및 초기화 설정
   ============================================================ */
let timerInterval  = null;
let totalSeconds   = 0;
let isWorking      = false;       // 현재 근무 상태 플래그
let isCheckedOut   = false;       // 당일 마감 상태 플래그
let currentWorkLoc = 'OFFICE';    // 기본 근무지 코드 (OFFICE/HOME/OUTSIDE)

// JSP ContextPath 주입 확인 (미정의 시 기본값 빈 문자열 처리)
var ctxPath = (typeof ctxPath !== 'undefined') ? ctxPath : '';

/* ============================================================
1. 당일 근태 현황 초기 조회 (AJAX GET)
- AttendController 응답값 기준:
  result, gtwkDt, lvwkDt, powkNm, workMinutes
============================================================ */
function loadTodayAttendStatus() {
 $.ajax({
     url     : ctxPath + '/attend/todayStatus.ajax',
     type    : 'GET',
     dataType: 'json',
     success : function(data) {

         if (data.result === 'NO_SESSION') {
             window.location.href = ctxPath + '/login/login.do';
             return;
         }

         if (data.result === 'ERROR') {
             console.warn('▶ [DevSync] todayStatus 서버 오류:', data.msg);
             stopTimer();
             isWorking = false;
             return;
         }

         if (data.result === 'NO_RECORD') {
             isWorking    = false;
             isCheckedOut = false;
             totalSeconds = 0;
             stopTimer();
             updateTimerDisplay();

             $('#checkin-time-display').text('출근 인증 : -');
             $('#checkout-time-display').text('');
             renderWorkLocationOptions(data.powkCodeList || [], data.powkNm || 'OFFICE', data.scheduleLinkedYn === 'Y');
             setWorkLocationUI(data.powkNm || 'OFFICE', data.scheduleLinkedYn === 'Y', data.powkSeNm, data.scheduleNm);
             return;
         }

         if (data.result !== 'OK') {
             console.warn('▶ [DevSync] 알 수 없는 근태 응답:', data);
             return;
         }

         /*
          * 컨트롤러 응답명 기준으로 변수 정리
          * - gtwkDt : 출근일시
          * - lvwkDt : 퇴근일시
          * - powkNm : 근무지명 또는 근무지코드
          * - workMinutes : 근무분
          */
         const gtwkDt      = data.gtwkDt || '';
         const lvwkDt      = data.lvwkDt || '';
         const powkNm      = data.powkNm || 'OFFICE';
         const workMinutes = parseInt(data.workMinutes || '0', 10);

         if (!gtwkDt) {
             isWorking    = false;
             isCheckedOut = false;
             totalSeconds = 0;
             stopTimer();
             updateTimerDisplay();

             $('#checkin-time-display').text('출근 인증 : -');
             $('#checkout-time-display').text('');
             renderWorkLocationOptions(data.powkCodeList || [], powkNm, data.scheduleLinkedYn === 'Y');
             setWorkLocationUI(powkNm, data.scheduleLinkedYn === 'Y', data.powkSeNm, data.scheduleNm);
             return;
         }

         /*
          * 출근 기록 있음
          */
         isWorking = true;

         $('#checkin-time-display').text('출근 인증 : ' + formatDateTimeToHm(gtwkDt));

         $('#btn-checkout').prop('disabled', false)
             .removeClass('bg-slate-800 text-gray-500 border-brand-border cursor-not-allowed')
             .addClass('bg-gradient-to-r from-red-500 to-orange-500 hover:brightness-110 text-white shadow-lg shadow-red-500/10 cursor-pointer');

         $('#btn-outside').prop('disabled', false)
             .removeClass('bg-slate-800 text-gray-500 border-brand-border cursor-not-allowed')
             .addClass('bg-slate-900 text-gray-200 border-brand-border hover:text-white transition cursor-pointer');

         /*
          * 퇴근 완료 상태
          */
         if (lvwkDt) {
             isWorking    = false;
             isCheckedOut = true;

             stopTimer();
             updateCheckOutUI(lvwkDt, workMinutes);
             renderWorkLocationOptions(data.powkCodeList || [], powkNm, data.scheduleLinkedYn === 'Y');
             setWorkLocationUI(powkNm, data.scheduleLinkedYn === 'Y', data.powkSeNm, data.scheduleNm);
             return;
         }

         /*
          * 근무 중 상태
          * 현재 DB/컨트롤러 구조에서는 workMinutes가 내려오므로
          * 우선 workMinutes * 60초를 초기값으로 사용.
          *
          * 단, gtwkDt가 정상적인 datetime 문자열이면 출근시각 기준 보정도 가능.
          */
         isCheckedOut = false;

         let initSeconds = 0;

         if (!isNaN(workMinutes) && workMinutes > 0) {
             initSeconds = workMinutes * 60;
         } else {
             initSeconds = calcElapsedSecondsFromDateTime(gtwkDt);
         }

         if (initSeconds < 0 || isNaN(initSeconds)) {
             initSeconds = 0;
         }

         startTimer(initSeconds);
         renderWorkLocationOptions(data.powkCodeList || [], powkNm, data.scheduleLinkedYn === 'Y');
         setWorkLocationUI(powkNm, data.scheduleLinkedYn === 'Y', data.powkSeNm, data.scheduleNm);
     },
     error: function(xhr) {
         console.warn('▶ [DevSync] 당일 근태 데이터 로드 실패 (통신 오류)', xhr);
     }
 });
}


/**
* yyyy-MM-dd HH:mm:ss 또는 yyyy-MM-ddTHH:mm:ss 형태를 HH:mm으로 표시
*/
function formatDateTimeToHm(dateTimeStr) {
 if (!dateTimeStr) {
     return '-';
 }

 /*
  * 예:
  * 2026-06-04 10:01:30 -> 10:01
  * 2026-06-04T10:01:30 -> 10:01
  */
 if (dateTimeStr.length >= 16) {
     return dateTimeStr.substring(11, 16);
 }

 return dateTimeStr;
}


/**
* 출근일시 문자열 기준으로 현재까지 지난 초 계산
*/
function calcElapsedSecondsFromDateTime(dateTimeStr) {
 if (!dateTimeStr) {
     return 0;
 }

 try {
     const normalized = dateTimeStr.replace(/-/g, '/').replace('T', ' ');
     const start = new Date(normalized);
     const now = new Date();

     const elapsedSec = Math.floor((now.getTime() - start.getTime()) / 1000);
     return elapsedSec > 0 ? elapsedSec : 0;
 } catch (e) {
     console.warn('▶ [DevSync] 출근일시 파싱 실패:', dateTimeStr, e);
     return 0;
 }
}

// 근무지 상태값에 따른 상단 배지 및 토글 UI 변경
function setWorkLocationUI(locCode, scheduleLinked, statusName, scheduleName) {
    currentWorkLoc = locCode;
    const $badge = $('#work-location-badge');
    var label = statusName || workStatusName(locCode);
    $badge.text(workStatusDisplayLabel(locCode, label));
    $badge.attr('class', 'px-2.5 py-0.5 border text-xs rounded-full font-bold ' + workStatusBadgeClass(locCode));
    $('#work-location-notice').text(scheduleLinked
        ? '[' + label + '] ' + (scheduleName || '일정') + '과 연동된 상태입니다.' : '');
    $('#work-location-options button').each(function() {
        var selected = $(this).attr('data-location-code') === locCode;
        $(this).toggleClass('bg-brand-accent text-white border-brand-accent', selected)
               .toggleClass('bg-slate-900 text-gray-400 border-brand-border', !selected);
    });
}

function renderWorkLocationOptions(codeList, selectedCode, scheduleLinked) {
    var html = '';
    (codeList || []).forEach(function(item) {
        var code = item.powkNm || '';
        var name = item.statusNm || code;
        html += '<button type="button" data-location-code="' + escapeDashboardHtml(code) + '" onclick="setWorkLocation(\''
            + escapeDashboardJs(code) + '\')" class="py-1 text-xs rounded-lg font-semibold border transition '
            + (code === selectedCode ? 'bg-brand-accent text-white border-brand-accent' : 'bg-slate-900 text-gray-400 border-brand-border hover:text-white')
            + '"' + (scheduleLinked ? ' disabled title="일정 연동 상태에서는 직접 변경할 수 없습니다."' : '') + '>'
            + escapeDashboardHtml(name) + '</button>';
    });
    $('#work-location-options').html(html);
}

function setWorkLocation(locCode) {
    $.ajax({
        url: ctxPath + '/attend/powkNm.ajax',
        type: 'POST',
        dataType: 'json',
        data: { powkNm: locCode },
        success: function(data) {
            if (data.result === 'OK') {
                showToast('근무상태가 변경되었습니다.', 'success');
                loadTodayAttendStatus();
                loadTeamStatus();
                return;
            }
            showToast(data.msg || '근무상태를 변경하지 못했습니다.', 'error');
        },
        error: function() {
            showToast('근무상태 변경 중 통신 오류가 발생했습니다.', 'error');
        }
    });
}

function workStatusName(code) {
    return { OFFICE: '본사', HOME: '재택', OUTSIDE: '외근', CLIENT: '상주', VAC: '휴가', BIZTRIP: '출장' }[code] || code || '-';
}

function workStatusDisplayLabel(code, name) {
    return code === 'OFFICE' || code === 'HOME' || code === 'CLIENT' ? name + ' 근무' : name;
}

function workStatusBadgeClass(code) {
    var classes = {
        OFFICE: 'bg-blue-500/10 border-blue-500/20 text-blue-400',
        HOME: 'bg-cyan-500/10 border-cyan-500/20 text-cyan-300',
        OUTSIDE: 'bg-amber-500/10 border-amber-500/20 text-amber-300',
        CLIENT: 'bg-purple-500/10 border-purple-500/20 text-purple-300',
        VAC: 'bg-emerald-500/10 border-emerald-500/20 text-emerald-300',
        BIZTRIP: 'bg-orange-500/10 border-orange-500/20 text-orange-300'
    };
    return classes[code] || classes.OFFICE;
}

function loadTeamStatus() {
    $.ajax({
        url: ctxPath + '/attend/teamStatus.ajax',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            if (data.result !== 'OK') {
                $('#teamStatusSummary').text('조회 실패');
                $('#teamStatusList').html('<div class="ds-empty">부서원 상태를 조회하지 못했습니다.</div>');
                return;
            }
            renderTeamStatus(data.teamList || []);
        },
        error: function() {
            $('#teamStatusSummary').text('조회 실패');
            $('#teamStatusList').html('<div class="ds-empty">부서원 상태를 조회하지 못했습니다.</div>');
        }
    });
}

function renderTeamStatus(list) {
    var externalCount = list.filter(function(item) { return item.externalYn === 'Y'; }).length;
    $('#teamStatusSummary').text('총 ' + list.length + '명 중 ' + externalCount + '명 외부·부재');
    if (!list.length) {
        $('#teamStatusList').html('<div class="ds-empty">조회된 부서원이 없습니다.</div>');
        return;
    }
    var html = list.map(function(item) {
        var name = item.userNm || item.userId || '-';
        var defaultProfile = ctxPath + '/images/default-profile.svg';
        var profile = item.profileFileSn
            ? '<img src="' + ctxPath + '/common/fileView.do?atchFileSn=' + encodeURIComponent(item.profileFileSn) + '" onerror="this.onerror=null;this.src=\'' + defaultProfile + '\';" alt="' + escapeDashboardHtml(name) + ' 프로필" class="ds-team-avatar">'
            : '<img src="' + defaultProfile + '" alt="기본 사용자 프로필" class="ds-team-avatar">';
        var detail = item.deptNm || '-';
        var title = item.schdlNm ? ' title="' + escapeDashboardHtml(item.schdlNm) + '"' : '';
        return '<div class="flex items-center justify-between gap-3 bg-slate-950/40 p-3 rounded-xl border border-brand-border/60">'
            + '<div class="flex items-center gap-3 min-w-0">' + profile + '<div class="min-w-0"><span class="font-bold text-sm text-gray-200">'
            + escapeDashboardHtml(name) + (item.jbpsNm ? ' ' + escapeDashboardHtml(item.jbpsNm) : '')
            + '</span><p class="text-[11px] text-gray-400 truncate">' + escapeDashboardHtml(detail || '-') + '</p></div></div>'
            + '<span class="px-2 py-1 text-xs rounded-full font-bold whitespace-nowrap border ' + workStatusBadgeClass(item.statusCd) + '"' + title + '>'
            + escapeDashboardHtml(item.statusNm || workStatusName(item.statusCd)) + '</span></div>';
    }).join('');
    $('#teamStatusList').html(html);
}

function escapeDashboardHtml(value) {
    return String(value === null || value === undefined ? '' : value)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

function escapeDashboardJs(value) {
    return String(value === null || value === undefined ? '' : value)
        .replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\r?\n/g, ' ');
}


/* ============================================================
   3. 퇴근 마감 처리 (AJAX POST)
   ============================================================ */
function triggerCheckOut() {
    if (!isWorking || isCheckedOut) return;

    if (!confirm('퇴근 처리 하시겠습니까?')) return;

    $.ajax({
        url     : ctxPath + '/attend/checkOut.ajax',
        type    : 'POST',
        dataType: 'json',
        success : function(data) {
            if (data.result === 'OK') {
                isWorking    = false;
                isCheckedOut = true;
                stopTimer();
                updateCheckOutUI(data.lvwkDt, data.workMinutes);
                showToast('퇴근 처리가 마감되었습니다.', 'success');
            } else if (data.result === 'ALREADY_CHECKED_OUT') {
                isWorking    = false;
                isCheckedOut = true;
                stopTimer();
                updateCheckOutUI(data.lvwkDt, data.workMinutes);
                showToast('이미 퇴근 마감된 레코드입니다.', 'info');
            } else {
                showToast(data.msg || '퇴근 처리 중 오류가 발생했습니다.', 'error');
            }
        },
        error: function() {
            showToast('서버 통신 장애로 인해 퇴근 마감에 실패했습니다.', 'error');
        }
    });
}

// 퇴근 마감 완료에 따른 제어 장치 전면 잠금
function updateCheckOutUI(checkOutTime, workMinutes) {
    $('#btn-checkout, #btn-outside')
        .prop('disabled', true)
        .removeClass('from-red-500 to-orange-500 hover:brightness-110 cursor-pointer shadow-lg hover:text-white transition')
        .addClass('bg-slate-800 text-gray-500 border-brand-border cursor-not-allowed');

    if (checkOutTime) {
        $('#checkout-time-display').text('퇴근 마감 : ' + formatDateTimeToHm(checkOutTime));
    }
    
    if (workMinutes) {
        const mins = parseInt(workMinutes) || 0;
        const h    = Math.floor(mins / 60);
        const m    = mins % 60;
        $('#work-time-display').html(`<span class="text-brand-neonBlue font-bold">확정 근무시간: ${h}시간 ${m}분</span>`);
    }
}


/* ============================================================
   4. 실시간 누적 근무 시간 타이머 엔진
   ============================================================ */
function startTimer(initSeconds) {
    totalSeconds  = initSeconds || 0;
    clearInterval(timerInterval);
    timerInterval = setInterval(function() {
        totalSeconds++;
        updateTimerDisplay();
    }, 1000);
}

function stopTimer() {
    clearInterval(timerInterval);
    timerInterval = null;
}

function updateTimerDisplay() {
    const hours   = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    const format  = function(num) { return String(num).padStart(2, '0'); };

    $('#timer-display').text(`${format(hours)} : ${format(minutes)} : ${format(seconds)}`);
}


/* ============================================================
   5. 아코디언 서브메뉴 토글 함수
   ============================================================ */
function toggleSubmenu(id) {
    const $menu  = $('#' + id);
    const $arrow = $('#arrow-' + id);

    if ($menu.hasClass('hidden')) {
        $menu.removeClass('hidden');
        $arrow.removeClass('fa-chevron-down text-gray-500').addClass('fa-chevron-up text-cyan-400');
    } else {
        $menu.addClass('hidden');
        $arrow.removeClass('fa-chevron-up text-cyan-400').addClass('fa-chevron-down text-gray-500');
    }
}


/* ============================================================
   6. 대시보드 공통 알림 컴포넌트 (Toast 메커니즘)
   ============================================================ */
function showToast(msg, type) {
    $('#devsync-toast').remove();

    var colorMap = {
        'success': 'bg-emerald-500/90 border-emerald-400',
        'error'  : 'bg-red-500/90 border-red-400',
        'info'   : 'bg-blue-500/90 border-blue-400'
    };
    var iconMap = {
        'success': 'fa-circle-check',
        'error'  : 'fa-circle-xmark',
        'info'   : 'fa-circle-info'
    };

    var colorClass = colorMap[type] || colorMap['info'];
    var iconClass  = iconMap[type]  || iconMap['info'];

    var toast = document.createElement('div');
    toast.id  = 'devsync-toast';
    toast.style.cssText = 'position:fixed;bottom:24px;right:24px;z-index:9999;transition:opacity 0.3s;';
    toast.innerHTML = `
        <div class="${colorClass} border text-white text-sm font-semibold px-5 py-3 rounded-xl shadow-2xl flex items-center gap-3 backdrop-blur-sm">
            <i class="fa-solid ${iconClass}"></i>
            <span>${msg}</span>
        </div>`;
    document.body.appendChild(toast);

    setTimeout(function() {
        toast.style.opacity = '0';
        setTimeout(function() { $(toast).remove(); }, 300);
    }, 3000);
}


/* ============================================================
   7. jQuery DOM Ready 진입점 (엔진 초기 구동)
   ============================================================ */
$(document).ready(function() {
    // 최초 화면 로딩 시 당일 자동 출근 검증 프로세스 연동 스캔
    loadTodayAttendStatus();
    loadTeamStatus();
});
