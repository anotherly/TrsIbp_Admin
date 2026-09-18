/**
 * 사업관리 JavaScript
 * - 첨부 DB 스키마 기준 테이블: biz_info, cust_info, biz_cust_rel, biz_mnpw, biz_cst, biz_schdl
 * - 기존 Controller 메소드명과 URL은 유지한다.
 */

var bizTable = null;
var bizCodeMap = {};
var bizCodeGroupIds = ['BIZ_STTS_CD', 'INST_SE_CD', 'BIZ_KND_CD', 'BIZ_SE_CD', 'CUST_SE_CD', 'REL_SE_CD', 'INPUT_SE_CD', 'CST_SE_CD', 'SCHDL_SE_CD', 'GIVE_MTHD_CD'];

/**
 * 빈 값이면 대체값을 반환한다.
 * @param {*} value 검사할 값
 * @param {*} defaultValue 빈 값일 때 반환할 값
 * @returns {*} value 또는 defaultValue
 */
function nvl(value, defaultValue) {
    return (value === null || value === undefined || value === '') ? defaultValue : value;
}

/**
 * HTML 문자열 삽입 전 특수문자를 이스케이프한다.
 * @param {string} value 출력 대상 문자열
 * @returns {string} HTML 이스케이프된 문자열
 */
function escapeHtml(value) {
    return String(nvl(value, '')).replace(/[&<>"']/g, function(ch) {
        return {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#39;'
        }[ch];
    });
}

/**
 * 자바스크립트 문자열 리터럴에 넣을 값을 이스케이프한다.
 * @param {string} value 이스케이프 대상 문자열
 * @returns {string} 작은따옴표 문자열에 안전한 값
 */
function escapeJs(value) {
    return String(nvl(value, '')).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
}

/**
 * 숫자 금액을 천 단위 구분 문자열로 변환한다.
 * @param {*} value 금액 값
 * @returns {string} 화면 표시용 금액 문자열
 */
function formatAmt(value) {
    if (value === null || value === undefined || value === '') {
        return '-';
    }
    var num = Number(unformatNumber(value));
    if (isNaN(num)) {
        return escapeHtml(value);
    }
    return num.toLocaleString('ko-KR');
}

/**
 * 화면 입력용 숫자 문자열에서 천 단위 콤마를 제거한다.
 * @param {*} value 콤마가 포함될 수 있는 숫자 문자열
 * @returns {string} 서버 전송용 숫자 문자열
 */
function unformatNumber(value) {
    return String(nvl(value, '')).replace(/,/g, '').trim();
}

/**
 * 숫자 입력값을 천 단위 콤마가 포함된 화면 표시 문자열로 변환한다.
 * @param {*} value 숫자 또는 숫자 문자열
 * @returns {string} 콤마가 적용된 숫자 문자열
 */
function formatNumberInput(value) {
    var raw = unformatNumber(value).replace(/[^0-9.-]/g, '');
    if (raw === '' || raw === '-' || raw === '.') {
        return raw;
    }
    var parts = raw.split('.');
    var integerPart = parts[0];
    var decimalPart = parts.length > 1 ? '.' + parts.slice(1).join('').replace(/\./g, '') : '';
    var sign = '';
    if (integerPart.indexOf('-') === 0) {
        sign = '-';
        integerPart = integerPart.substring(1);
    }
    integerPart = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return sign + integerPart + decimalPart;
}

/**
 * ds-number-input 클래스가 지정된 숫자 입력창에 천 단위 콤마 표시 이벤트를 연결한다.
 * @param {Object|string=} scope 이벤트 연결 범위. 없으면 document 기준
 * @returns 없음
 */
function bindNumberInputFormatter(scope) {
    var $scope = scope ? $(scope) : $(document);
    $scope.find('.ds-number-input').addBack('.ds-number-input')
        .off('input.numberFormat blur.numberFormat')
        .on('input.numberFormat blur.numberFormat', function() {
            this.value = formatNumberInput(this.value);
        });
}

/**
 * 날짜 기간을 기준으로 투입 M/M을 계산한다.
 * @param {string} bgngYmd 투입시작일(yyyy-MM-dd)
 * @param {string} endYmd 투입종료일(yyyy-MM-dd)
 * @param {*} inputRt 투입률. 값이 없으면 100으로 계산
 * @returns {string} 소수점 둘째 자리까지 계산된 M/M 문자열. 날짜가 없거나 잘못되면 빈 문자열
 */
function calcInputMcnt(bgngYmd, endYmd, inputRt) {
    if (!bgngYmd || !endYmd) {
        return '';
    }
    var start = new Date(bgngYmd + 'T00:00:00');
    var end = new Date(endYmd + 'T00:00:00');
    if (isNaN(start.getTime()) || isNaN(end.getTime()) || start > end) {
        return '';
    }
    var rate = Number(unformatNumber(nvl(inputRt, '100')));
    if (isNaN(rate)) {
        rate = 100;
    }
    var diffDays = Math.floor((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) + 1;
    return (Math.round((diffDays / 30) * (rate / 100) * 100) / 100).toString();
}

/**
 * 공통코드 목록을 조회하고 화면 select option을 구성한다.
 * @param {Function} callback 코드 로드 후 실행할 콜백
 * @returns 없음
 */
function loadBizCodeOptions(callback) {
    $.ajax({
        url: ctxPath + '/comm/codeList.ajax',
        type: 'GET',
        dataType: 'json',
        data: { cdGroupIds: bizCodeGroupIds.join(',') },
        success: function(res) {
            if (res.result === 'OK') {
                bizCodeMap = res.codeMap || {};
                populateCodeSelect('searchBizSttsCd', 'BIZ_STTS_CD', '전체');
                populateCodeSelect('searchInstSeCd', 'INST_SE_CD', '전체');
                populateCodeSelect('searchBizKndCd', 'BIZ_KND_CD', '전체');
                populateCodeSelect('searchBizSeCd', 'BIZ_SE_CD', '전체');
                populateCodeSelect('frmBizSttsCd', 'BIZ_STTS_CD', '선택');
                populateCodeSelect('frmInstSeCd', 'INST_SE_CD', '선택');
                populateCodeSelect('frmBizKndCd', 'BIZ_KND_CD', '선택');
                populateCodeSelect('frmBizSeCd', 'BIZ_SE_CD', '선택');
                populateCodeSelect('frmCustSeCd', 'CUST_SE_CD', '선택');
                populateCodeSelect('frmRelSeCd', 'REL_SE_CD', '선택');
                populateCodeSelect('frmInputSeCd', 'INPUT_SE_CD', '선택');
                populateCodeSelect('frmCstSeCd', 'CST_SE_CD', '선택');
                populateCodeSelect('frmSchdlSeCd', 'SCHDL_SE_CD', '선택');
            }
            if (typeof callback === 'function') {
                callback();
            }
        },
        error: function() {
            if (typeof callback === 'function') {
                callback();
            }
        }
    });
}

/**
 * 지정한 select에 공통코드 option을 채운다.
 * @param {string} selectId select element ID
 * @param {string} cdGroupId 코드 그룹 ID
 * @param {string} firstText 첫 번째 빈 option 텍스트
 * @returns 없음
 */
function populateCodeSelect(selectId, cdGroupId, firstText) {
    var $select = $('#' + selectId);
    if ($select.length === 0) {
        return;
    }

    var currentValue = $select.val();
    var html = '<option value="">' + escapeHtml(firstText || '선택') + '</option>';
    $.each(bizCodeMap[cdGroupId] || [], function(_, code) {
        html += '<option value="' + escapeHtml(code.cd) + '">' + escapeHtml(code.cdNm) + '</option>';
    });
    $select.html(html);
    if (currentValue) {
        $select.val(currentValue);
    }
}

/**
 * 공통코드의 기본값을 반환한다.
 * @param {string} cdGroupId 코드 그룹 ID
 * @returns {string} 기본 코드
 */
function getDefaultCode(cdGroupId) {
    var list = bizCodeMap[cdGroupId] || [];
    for (var i = 0; i < list.length; i++) {
        if (list[i].dfltYn === 'Y') {
            return list[i].cd;
        }
    }
    return list.length > 0 ? list[0].cd : '';
}

/**
 * 공통코드명을 반환한다.
 * @param {string} cdGroupId 코드 그룹 ID
 * @param {string} code 코드
 * @returns {string} 코드명
 */
function getCodeNm(cdGroupId, code) {
    var list = bizCodeMap[cdGroupId] || [];
    for (var i = 0; i < list.length; i++) {
        if (list[i].cd === code) {
            return list[i].cdNm;
        }
    }
    return code || '-';
}

/**
 * 테이블 행 객체를 onclick 속성에 넣기 위한 문자열로 인코딩한다.
 * @param {Object} row 인코딩할 행 데이터
 * @returns {string} URI 인코딩된 JSON 문자열
 */
function encodeRowData(row) {
    return encodeURIComponent(JSON.stringify(row || {}));
}

/**
 * onclick 속성에서 전달받은 행 문자열을 객체로 복원한다.
 * @param {string} encodedRow URI 인코딩된 JSON 문자열
 * @returns {Object} 복원된 행 데이터
 */
function decodeRowData(encodedRow) {
    if (!encodedRow) {
        return {};
    }
    return JSON.parse(decodeURIComponent(encodedRow));
}

/**
 * 사업상태 배지 CSS 클래스를 반환한다.
 * @param {string} code BIZ_STTS_CD 값
 * @returns {string} ds-badge 계열 CSS 클래스명
 */
function getBizSttsBadgeClass(code) {
    var map = {
        READY: 'ds-badge-orange',
        PRGRS: 'ds-badge-green',
        CMPTN: 'ds-badge-blue',
        HOLD: 'ds-badge-cyan',
        CANCEL: 'ds-badge-red'
    };
    return map[code] || 'ds-badge-cyan';
}

/**
 * 사업 목록 화면을 초기화한다.
 * @param 없음
 * @returns 없음
 */
function initBizListPage() {
    loadBizCodeOptions(function() {
        initBizDataTable();
        loadBizList();
    });
}

/**
 * DataTables를 1회 초기화한다.
 * @param 없음
 * @returns 없음
 */
function initBizDataTable() {
    if (!$.fn.DataTable || $.fn.DataTable.isDataTable('#bizTable')) {
        return;
    }

    bizTable = $('#bizTable').DataTable({
        paging: true,
        searching: false,
        ordering: true,
        info: true,
        pageLength: 10,
        lengthChange: false,
        columnDefs: [
            { targets: -1, orderable: false },
            { targets: '_all', className: 'dt-center' }
        ],
        order: [[0, 'asc']],
        language: {
            emptyTable: '조회된 사업 데이터가 없습니다.',
            info: '_TOTAL_건 중 _START_ - _END_',
            infoEmpty: '0건',
            zeroRecords: '조회된 사업 데이터가 없습니다.',
            paginate: {
                first: '처음',
                previous: '이전',
                next: '다음',
                last: '마지막'
            }
        }
    });
}

/**
 * 검색 조건 기준으로 사업 목록을 조회하고 테이블에 렌더링한다.
 * @param 없음
 * @returns 없음
 */
function loadBizList() {
    $.ajax({
        url: ctxPath + '/biz/bizList.ajax',
        type: 'GET',
        dataType: 'json',
        data: {
            searchKeyword: $('#searchKeyword').val(),
            searchBizSttsCd: $('#searchBizSttsCd').val(),
            searchInstSeCd: $('#searchInstSeCd').val(),
            searchBizKndCd: $('#searchBizKndCd').val(),
            searchBizSeCd: $('#searchBizSeCd').val(),
            sDate: $('#sDate').val(),
            eDate: $('#eDate').val()
        },
        success: function(res) {
            if (res.result !== 'OK') {
                alert('사업 목록 조회에 실패했습니다.');
                return;
            }
            renderBizList(res.list || []);
            renderBizSummary(res.list || [], res.totalCnt || 0);
        },
        error: function() {
            alert('사업 목록 조회 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 사업 목록 데이터를 테이블 행으로 변환한다.
 * @param {Array} list 사업 목록 배열
 * @returns 없음
 */
function renderBizList(list) {
    var rows = [];

    $.each(list, function(index, row) {
        var bizId = escapeHtml(row.bizId);
        var sttsCd = nvl(row.bizSttsCd, '');
        var periodStart = escapeHtml(nvl(row.otstYmd || row.bizBgngYmd, '-'));
        var periodEnd = escapeHtml(nvl(row.bizEndYmd, '-'));
        var period = '<span class="ds-period"><span>' + periodStart + '</span><span>~ ' + periodEnd + '</span></span>';

        rows.push([
            '<span class="ds-code">' + escapeHtml(nvl(row.bizCd, '-')) + '</span>',
            hasAuthorityCode('PROJECT_BIZ_DETAIL')
                ? '<a class="ds-link" href="' + ctxPath + '/biz/bizDetail.do?bizId=' + encodeURIComponent(row.bizId) + '">' + escapeHtml(row.bizNm) + '</a>'
                : escapeHtml(row.bizNm),
            escapeHtml(nvl(row.instSeNm, getCodeNm('INST_SE_CD', row.instSeCd))),
            escapeHtml(nvl(row.ordplNm, '-')),
            escapeHtml(nvl(row.bizKndNm, getCodeNm('BIZ_KND_CD', row.bizKndCd))),
            escapeHtml(nvl(row.bizSeNm, getCodeNm('BIZ_SE_CD', row.bizSeCd))),
            '<span class="ds-badge ' + getBizSttsBadgeClass(sttsCd) + '">' + escapeHtml(nvl(row.bizSttsNm, getCodeNm('BIZ_STTS_CD', sttsCd))) + '</span>',
            formatAmt(row.ctrtAmt),
            escapeHtml(nvl(row.ctrtYmd, '-')),
            period,
            '<div class="ds-row-actions">'
                + (hasAuthorityCode('PROJECT_BIZ_MDFCN_SCREEN') ? '<button type="button" class="ds-mini-btn" onclick="goBizUpdate(\'' + escapeJs(row.bizId) + '\');">수정</button>' : '')
                + (hasAuthorityCode('PROJECT_BIZ_DEL') ? '<button type="button" class="ds-mini-btn ds-mini-btn-danger" onclick="deleteBizById(\'' + escapeJs(row.bizId) + '\');">삭제</button>' : '')
            + '</div>'
        ]);
    });

    if (bizTable) {
        bizTable.clear();
        bizTable.rows.add(rows);
        bizTable.draw();
        return;
    }

    var html = '';
    if (rows.length === 0) {
        html = '<tr><td colspan="12" class="ds-empty">조회된 사업 데이터가 없습니다.</td></tr>';
    } else {
        $.each(rows, function(_, cols) {
            html += '<tr>';
            $.each(cols, function(__, col) {
                html += '<td>' + col + '</td>';
            });
            html += '</tr>';
        });
    }
    $('#bizListBody').html(html);
}

/**
 * 사업 상태별 요약 카운트를 갱신한다.
 * @param {Array} list 사업 목록 배열
 * @param {number} totalCnt 전체 건수
 * @returns 없음
 */
function renderBizSummary(list, totalCnt) {
    var readyCnt = 0;
    var prgrsCnt = 0;
    var cmptnCnt = 0;

    $.each(list, function(_, row) {
        if (row.bizSttsCd === 'READY') readyCnt++;
        if (row.bizSttsCd === 'PRGRS') prgrsCnt++;
        if (row.bizSttsCd === 'CMPTN') cmptnCnt++;
    });

    $('#summaryTotalCnt').text(totalCnt);
    $('#summaryReadyCnt').text(readyCnt);
    $('#summaryPrgrsCnt').text(prgrsCnt);
    $('#summaryCmptnCnt').text(cmptnCnt);
}

/**
 * 사업 검색 조건을 초기화한 뒤 다시 조회한다.
 * @param 없음
 * @returns 없음
 */
function resetBizSearch() {
    $('#searchKeyword').val('');
    $('#searchBizSttsCd').val('');
    $('#searchInstSeCd').val('');
    $('#searchBizKndCd').val('');
    $('#searchBizSeCd').val('');
    $('#sDate').val('');
    $('#eDate').val('');
    loadBizList();
}

/**
 * 사업 등록 화면으로 이동한다.
 * @param 없음
 * @returns 없음
 */
function goBizRegist() {
    location.href = ctxPath + '/biz/bizInsert.do';
}

/**
 * 사업 상세/수정 화면으로 이동한다.
 * @param {string} bizId 사업ID
 * @returns 없음
 */
function goBizDetail(bizId) {
    location.href = ctxPath + '/biz/bizDetail.do?bizId=' + encodeURIComponent(bizId);
}

/**
 * 사업 수정 화면으로 이동한다.
 * @param {string} bizId 사업ID
 * @returns 없음
 */
function goBizUpdate(bizId) {
    location.href = ctxPath + '/biz/bizUpdate.do?bizId=' + encodeURIComponent(bizId);
}

/**
 * 목록에서 지정한 사업ID의 사업을 삭제한다.
 * @param {string} bizId 삭제할 사업ID
 * @returns 없음
 */
function deleteBizById(bizId) {
    if (!bizId) {
        alert('삭제할 사업ID가 없습니다.');
        return;
    }
    if (!confirm('선택한 사업을 삭제하시겠습니까?\n연결된 사업 단계 업무도 함께 삭제될 수 있습니다.')) {
        return;
    }

    $.ajax({
        url: ctxPath + '/biz/bizDelete.ajax',
        type: 'POST',
        dataType: 'json',
        data: { bizId: bizId },
        success: function(res) {
            if (res.result === 'OK') {
                alert('삭제되었습니다.');
                if ($('#bizTable').length > 0) {
                    loadBizList();
                } else {
                    location.href = ctxPath + '/biz/bizList.do';
                }
            } else {
                alert('삭제에 실패했습니다.');
            }
        },
        error: function() {
            alert('삭제 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 사업 등록 화면을 초기화한다.
 * @param 없음
 * @returns 없음
 */
function initBizInsertPage() {
    bindNumberInputFormatter(document);
    loadBizCodeOptions(function() {
        $('#frmBizCd').val('저장 시 자동 생성');
        $('#frmBizSttsCd').val(getDefaultCode('BIZ_STTS_CD'));
        $('#frmInstSeCd').val(getDefaultCode('INST_SE_CD'));
        bindBizStatusChangeEvent();
        bindBizGiveMthdRows([]);
        toggleReadyContractFields();
    });
}

/**
 * 사업 상세 화면을 초기화한다.
 * @param 없음
 * @returns 없음
 */
function initBizDetailPage() {
    if (!checkBizIdOrBack()) {
        return;
    }
    loadBizCodeOptions(function() {
        loadBizDetail();
    });
}

/**
 * 사업 수정 화면을 초기화한다.
 * @param 없음
 * @returns 없음
 */
function initBizUpdatePage() {
    bindNumberInputFormatter(document);
    if (!checkBizIdOrBack()) {
        return;
    }
    loadBizCodeOptions(function() {
        bindBizStatusChangeEvent();
        loadBizDetail();
    });
}

/**
 * 계약/회계/투입인력/프로세스 관리 개별 화면을 초기화한다.
 * @param {string} manageType contract/account/mnpw/schdl 중 현재 관리 화면 구분
 * @returns 없음
 */
function initBizManagePage(manageType) {
    bindNumberInputFormatter(document);
    loadBizCodeOptions(function() {
        loadManageBizOptions(function() {
            var firstBizId = $('#manageBizId option:eq(1)').val();
            if (firstBizId) {
                $('#manageBizId').val(firstBizId);
                changeManagedBiz(manageType);
            } else {
                renderEmptyManageArea(manageType);
            }
        });
    });
}

/**
 * 관리 화면 상단 사업 선택 select를 구성한다.
 * @param {Function} callback 사업 option 생성 후 실행할 콜백
 * @returns 없음
 */
function loadManageBizOptions(callback) {
    $.ajax({
        url: ctxPath + '/biz/bizList.ajax',
        type: 'GET',
        dataType: 'json',
        data: { recordCountPerPage: 0 },
        success: function(res) {
            var html = '<option value="">사업을 선택하십시오.</option>';
            $.each(res.list || [], function(_, row) {
                html += '<option value="' + escapeHtml(row.bizId) + '">' + escapeHtml(row.bizCd) + ' - ' + escapeHtml(row.bizNm) + '</option>';
            });
            $('#manageBizId').html(html);
            if (typeof callback === 'function') {
                callback();
            }
        },
        error: function() {
            alert('사업 목록 조회 중 오류가 발생했습니다.');
            if (typeof callback === 'function') {
                callback();
            }
        }
    });
}

/**
 * 관리 화면의 사업 선택 변경 시 해당 업무 목록을 다시 조회한다.
 * @param {string} manageType contract/account/mnpw/schdl 중 현재 관리 화면 구분
 * @returns 없음
 */
function changeManagedBiz(manageType) {
    currentBizId = $('#manageBizId').val();
    if (!currentBizId) {
        renderEmptyManageArea(manageType);
        return;
    }

    if (manageType === 'contract') {
        resetCustRelForm();
        loadBizCustRelList();
    } else if (manageType === 'account') {
        resetCstForm();
        loadBizCstList();
        loadBizProfitSummary();
    } else if (manageType === 'mnpw') {
        resetMnpwForm();
        loadBizMnpwList();
    } else if (manageType === 'schdl') {
        resetSchdlForm();
        loadBizSchdlList();
    }
}

/**
 * 사업 미선택 또는 사업 없음 상태의 빈 목록 문구를 표시한다.
 * @param {string} manageType contract/account/mnpw/schdl 중 현재 관리 화면 구분
 * @returns 없음
 */
function renderEmptyManageArea(manageType) {
    if (manageType === 'contract') {
        $('#bizCustRelBody').html('<tr><td colspan="7" class="ds-empty">사업을 선택하십시오.</td></tr>');
    } else if (manageType === 'account') {
        $('#bizCstBody').html('<tr><td colspan="6" class="ds-empty">사업을 선택하십시오.</td></tr>');
        $('#profitCtrtAmt,#profitDirectCst,#profitLaborCst,#profitAmt').text('0');
        $('#profitRate').text('0%');
    } else if (manageType === 'mnpw') {
        $('#bizMnpwBody').html('<tr><td colspan="10" class="ds-empty">사업을 선택하십시오.</td></tr>');
    } else if (manageType === 'schdl') {
        $('#bizSchdlBody').html('<tr><td colspan="7" class="ds-empty">사업을 선택하십시오.</td></tr>');
    }
}

/**
 * 상세/수정 화면의 사업ID 존재 여부를 확인한다.
 * @param 없음
 * @returns 없음
 */
function checkBizIdOrBack() {
    if (!currentBizId) {
        alert('사업ID가 없습니다.');
        location.href = ctxPath + '/biz/bizList.do';
        return false;
    }
    return true;
}

/**
 * 현재 사업ID의 상세 정보를 조회하여 입력폼에 채운다.
 * @param 없음
 * @returns 없음
 */
function loadBizDetail() {
    $.ajax({
        url: ctxPath + '/biz/bizDetail.ajax',
        type: 'GET',
        dataType: 'json',
        data: { bizId: currentBizId },
        success: function(res) {
            if (res.result !== 'OK') {
                alert('사업 상세 조회에 실패했습니다.');
                location.href = ctxPath + '/biz/bizList.do';
                return;
            }
            bindBizForm(res.detail || {});
            bindBizGiveMthdRows(res.giveMthdList || []);
        },
        error: function() {
            alert('사업 상세 조회 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 사업 상세 데이터를 입력폼에 바인딩한다.
 * @param {Object} data 사업 상세 데이터
 * @returns 없음
 */
function bindBizForm(data) {
    if (bizPageMode === 'detail') {
        bindBizDetailText(data);
        return;
    }

    $('#frmBizId').val(nvl(data.bizId, ''));
    $('#frmBizCd').val(nvl(data.bizCd, '저장 시 자동 생성'));
    $('#frmCtrtNo').val(nvl(data.ctrtNo, ''));
    $('#frmBizNm').val(nvl(data.bizNm, ''));
    $('#frmBizAbrvNm').val(nvl(data.bizAbrvNm, ''));
    $('#frmInstSeCd').val(nvl(data.instSeCd, ''));
    $('#frmBizKndCd').val(nvl(data.bizKndCd, ''));
    $('#frmBizSttsCd').val(nvl(data.bizSttsCd, getDefaultCode('BIZ_STTS_CD')));
    $('#frmBizSeCd').val(nvl(data.bizSeCd, ''));
    $('#frmOrdplNm').val(nvl(data.ordplNm, ''));
    $('#frmCtrtYmd').val(nvl(data.ctrtYmd, ''));
    $('#frmOtstYmd').val(nvl(data.otstYmd || data.bizBgngYmd, ''));
    $('#frmBizEndYmd').val(nvl(data.bizEndYmd, ''));
    $('#frmCtrtAmt').val(formatNumberInput(nvl(data.ctrtAmt, '')));
    $('#frmVatInclYn').val(nvl(data.vatInclYn, ''));
    $('#frmGiveDdtYmd').val(nvl(data.giveDdtYmd, ''));
    $('#frmDfrpGrnteBgngYmd').val(nvl(data.dfrpGrnteBgngYmd, ''));
    $('#frmDfrpGrnteEndYmd').val(nvl(data.dfrpGrnteEndYmd, ''));
    $('#frmRmrkCn').val(nvl(data.rmrkCn, ''));
    toggleReadyContractFields();
}

/**
 * 사업 상세 화면 표시 전용 태그에 조회 데이터를 바인딩한다.
 * @param {Object} data 사업 상세 데이터
 * @returns 없음
 */
function bindBizDetailText(data) {
    $('#frmBizId').val(nvl(data.bizId, ''));
    $('#dispBizCd').text(nvl(data.bizCd, '-'));
    $('#dispCtrtNo').text(nvl(data.ctrtNo, '-'));
    $('#dispBizNm').text(nvl(data.bizNm, '-'));
    $('#dispBizAbrvNm').text(nvl(data.bizAbrvNm, '-'));
    $('#dispInstSeNm').text(nvl(data.instSeNm, getCodeNm('INST_SE_CD', data.instSeCd)));
    $('#dispBizKndNm').text(nvl(data.bizKndNm, getCodeNm('BIZ_KND_CD', data.bizKndCd)));
    $('#dispBizSttsNm').text(nvl(data.bizSttsNm, getCodeNm('BIZ_STTS_CD', data.bizSttsCd)));
    $('#dispBizSeNm').text(nvl(data.bizSeNm, getCodeNm('BIZ_SE_CD', data.bizSeCd)));
    $('#dispOrdplNm').text(nvl(data.ordplNm, '-'));
    $('#dispCtrtYmd').text(nvl(data.ctrtYmd, '-'));
    $('#dispOtstYmd').text(nvl(data.otstYmd || data.bizBgngYmd, '-'));
    $('#dispBizEndYmd').text(nvl(data.bizEndYmd, '-'));
    $('#dispCtrtAmt').text(formatAmt(data.ctrtAmt));
    $('#dispVatInclNm').text(nvl(data.vatInclNm, data.vatInclYn === 'Y' ? 'VAT포함' : (data.vatInclYn === 'N' ? 'VAT별도' : '-')));
    $('#dispGiveDdtYmd').text(nvl(data.giveDdtYmd, '-'));
    $('#dispDfrpGrnteBgngYmd').text(nvl(data.dfrpGrnteBgngYmd, '-'));
    $('#dispDfrpGrnteEndYmd').text(nvl(data.dfrpGrnteEndYmd, '-'));
    $('#dispRmrkCn').text(nvl(data.rmrkCn, '-'));
}


/**
 * 대금지급방법 입력 행을 추가한다.
 * @param {Object=} row 기존 대금지급방법 행 데이터
 * @returns 없음
 */
function addBizGiveMthdRow(row) {
    var idx = $('#bizGiveMthdEditBody tr').length;
    var html = '<tr>'
        + '<td><select class="ds-select give-mthd-cd ready-disabled-field"><option value="">선택</option></select></td>'
        + '<td><input type="text" class="ds-input give-mthd-cn ready-disabled-field" maxlength="1000" placeholder="예: 10%, 몇 단계 완료 시 얼마"></td>'
        + '<td><button type="button" class="ds-mini-btn ds-mini-btn-danger ready-disabled-field" onclick="removeBizGiveMthdRow(this);">삭제</button></td>'
        + '</tr>';
    $('#bizGiveMthdEditBody').append(html);
    var $tr = $('#bizGiveMthdEditBody tr').eq(idx);
    populateGiveMthdSelect($tr.find('.give-mthd-cd'));
    if (row) {
        $tr.find('.give-mthd-cd').val(nvl(row.giveMthdCd, ''));
        $tr.find('.give-mthd-cn').val(nvl(row.giveMthdCn, ''));
    }
    toggleReadyContractFields();
}

/**
 * 대금지급방법 행의 지급방법 select option을 구성한다.
 * @param {Object} $select 지급방법 select jQuery 객체
 * @returns 없음
 */
function populateGiveMthdSelect($select) {
    $select.empty().append('<option value="">선택</option>');
    $.each(bizCodeMap['GIVE_MTHD_CD'] || [], function(_, code) {
        $select.append('<option value="' + escapeHtml(code.cd) + '">' + escapeHtml(code.cdNm) + '</option>');
    });
}

/**
 * 선택한 대금지급방법 입력 행을 제거한다.
 * @param {HTMLElement} btn 삭제 버튼
 * @returns 없음
 */
function removeBizGiveMthdRow(btn) {
    $(btn).closest('tr').remove();
}

/**
 * 조회된 대금지급방법 목록을 등록/수정 또는 상세 화면에 바인딩한다.
 * @param {Array} list 대금지급방법 단계 목록
 * @returns 없음
 */
function bindBizGiveMthdRows(list) {
    if (bizPageMode === 'detail') {
        renderBizGiveMthdDetailRows(list || []);
        return;
    }
    $('#bizGiveMthdEditBody').empty();
    $.each(list || [], function(_, row) {
        addBizGiveMthdRow(row);
    });
    if ($('#bizGiveMthdEditBody tr').length === 0) {
        addBizGiveMthdRow();
    }
}

/**
 * 상세 화면 대금지급방법 목록을 표시한다.
 * @param {Array} list 대금지급방법 단계 목록
 * @returns 없음
 */
function renderBizGiveMthdDetailRows(list) {
    var html = '';
    if (!list || list.length === 0) {
        $('#bizGiveMthdDetailBody').html('<tr><td colspan="2" class="ds-empty">등록된 대금지급방법이 없습니다.</td></tr>');
        return;
    }
    $.each(list, function(_, row) {
        html += '<tr><td>' + escapeHtml(nvl(row.giveMthdNm, getCodeNm('GIVE_MTHD_CD', row.giveMthdCd))) + '</td>'
            + '<td>' + escapeHtml(nvl(row.giveMthdCn, '-')) + '</td></tr>';
    });
    $('#bizGiveMthdDetailBody').html(html);
}

/**
 * 등록/수정 화면의 대금지급방법 입력 행을 서버 전송용 배열로 수집한다.
 * @param 없음
 * @returns {Array} 대금지급방법 단계 배열
 */
function collectBizGiveMthdRows() {
    var rows = [];
    $('#bizGiveMthdEditBody tr').each(function() {
        var giveMthdCd = $(this).find('.give-mthd-cd').val();
        var giveMthdCn = $(this).find('.give-mthd-cn').val();
        if (giveMthdCd || giveMthdCn) {
            rows.push({ giveMthdCd: giveMthdCd, giveMthdCn: giveMthdCn });
        }
    });
    return rows;
}

/**
 * 사업상태 변경 시 준비 상태 계약 필드 제어 이벤트를 연결한다.
 * @param 없음
 * @returns 없음
 */
function bindBizStatusChangeEvent() {
    $('#frmBizSttsCd').off('change.bizStatus').on('change.bizStatus', function() {
        toggleReadyContractFields();
    });
}

/**
 * 사업상태가 준비(READY)이면 계약 관련 필드를 비활성화하고 값을 비운다.
 * @param 없음
 * @returns 없음
 */
function toggleReadyContractFields() {
    var isReady = $('#frmBizSttsCd').val() === 'READY';
    $('.ready-disabled-field').prop('disabled', isReady);
    if (isReady) {
        $('.ready-disabled-field').val('');
    }
}

/**
 * 사업 정보를 저장한다. bizId가 없으면 등록, 있으면 수정한다.
 * @param 없음
 * @returns 없음
 */
function saveBiz() {
    var requiredFields = [
        { id: 'frmBizNm', name: '사업명' },
        { id: 'frmBizSttsCd', name: '사업상태' },
        { id: 'frmInstSeCd', name: '민간/공공' },
        { id: 'frmBizKndCd', name: '사업종류' },
        { id: 'frmBizSeCd', name: '사업성격' }
    ];

    for (var i = 0; i < requiredFields.length; i++) {
        var field = requiredFields[i];
        if (!$('#' + field.id).val()) {
            alert(field.name + ' 항목을 입력하십시오.');
            $('#' + field.id).focus();
            return;
        }
    }

    var isReady = $('#frmBizSttsCd').val() === 'READY';

    $.ajax({
        url: ctxPath + '/biz/bizSave.ajax',
        type: 'POST',
        dataType: 'json',
        data: {
            bizId: $('#frmBizId').val(),
            ctrtNo: $('#frmCtrtNo').val(),
            bizNm: $('#frmBizNm').val(),
            bizAbrvNm: $('#frmBizAbrvNm').val(),
            instSeCd: $('#frmInstSeCd').val(),
            bizKndCd: $('#frmBizKndCd').val(),
            bizSttsCd: $('#frmBizSttsCd').val(),
            bizSeCd: $('#frmBizSeCd').val(),
            ordplNm: $('#frmOrdplNm').val(),
            ctrtYmd: isReady ? '' : $('#frmCtrtYmd').val(),
            otstYmd: isReady ? '' : $('#frmOtstYmd').val(),
            bizEndYmd: isReady ? '' : $('#frmBizEndYmd').val(),
            ctrtAmt: isReady ? '' : unformatNumber($('#frmCtrtAmt').val()),
            vatInclYn: isReady ? '' : $('#frmVatInclYn').val(),
            giveMthdListJson: isReady ? '[]' : JSON.stringify(collectBizGiveMthdRows()),
            giveDdtYmd: isReady ? '' : $('#frmGiveDdtYmd').val(),
            dfrpGrnteBgngYmd: isReady ? '' : $('#frmDfrpGrnteBgngYmd').val(),
            dfrpGrnteEndYmd: isReady ? '' : $('#frmDfrpGrnteEndYmd').val(),
            rmrkCn: $('#frmRmrkCn').val()
        },
        success: function(res) {
            if (res.result === 'OK') {
                alert('저장되었습니다.');
                location.href = ctxPath + '/biz/bizDetail.do?bizId=' + encodeURIComponent(res.bizId || $('#frmBizId').val());
            } else {
                alert('저장에 실패했습니다.');
            }
        },
        error: function() {
            alert('저장 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 현재 상세 화면의 사업을 삭제한다.
 * @param 없음
 * @returns 없음
 */
function deleteBiz() {
    deleteBizById($('#frmBizId').val());
}

/**
 * 사업 상세 하위 관리 영역 전체 데이터를 조회한다.
 * @param 없음
 * @returns 없음
 */
function loadBizManageAll() {
    loadBizCustRelList();
    loadBizCstList();
    loadBizMnpwList();
    loadBizSchdlList();
    loadBizProfitSummary();
}

/**
 * 사업 손익 요약을 조회해 회계 요약 영역에 표시한다.
 * @param 없음
 * @returns 없음
 */
function loadBizProfitSummary() {
    $.ajax({
        url: ctxPath + '/biz/profitSummary.ajax',
        type: 'GET',
        dataType: 'json',
        data: { bizId: currentBizId },
        success: function(res) {
            var summary = res.summary || {};
            $('#profitCtrtAmt').text(formatAmt(summary.ctrtAmt || 0));
            $('#profitDirectCst').text(formatAmt(summary.directCstSum || 0));
            $('#profitLaborCst').text(formatAmt(summary.laborCstSum || 0));
            $('#profitAmt').text(formatAmt(summary.profitAmt || 0));
            $('#profitRate').text(nvl(summary.profitRate, 0) + '%');
        }
    });
}

/**
 * 고객사와 사업 계약관계 입력폼을 초기화한다.
 * @param 없음
 * @returns 없음
 */
function resetCustRelForm() {
    $('#frmCustSn').val('');
    $('#frmBizCustRelSn').val('');
    $('#frmCustCoNm').val('');
    $('#frmCustSeCd').val(getDefaultCode('CUST_SE_CD'));
    $('#frmBrno').val('');
    $('#frmRprsvNm').val('');
    $('#frmTelno').val('');
    $('#frmAddr').val('');
    $('#frmRelSeCd').val(getDefaultCode('REL_SE_CD'));
    $('#frmRelLvl').val('');
    $('#frmDirectCtrtYn').val('N');
}

/**
 * 사업 계약관계 목록을 조회한다.
 * @param 없음
 * @returns 없음
 */
function loadBizCustRelList() {
    $.ajax({
        url: ctxPath + '/biz/custRelList.ajax',
        type: 'GET',
        dataType: 'json',
        data: { bizId: currentBizId },
        success: function(res) {
            renderBizCustRelList(res.list || []);
        },
        error: function() {
            $('#bizCustRelBody').html('<tr><td colspan="7" class="ds-empty">계약 관계 조회 중 오류가 발생했습니다.</td></tr>');
        }
    });
}

/**
 * 사업 계약관계 목록을 테이블에 렌더링한다.
 * @param {Array} list 사업 고객관계 목록
 * @returns 없음
 */
function renderBizCustRelList(list) {
    var html = '';
    if (list.length === 0) {
        $('#bizCustRelBody').html('<tr><td colspan="7" class="ds-empty">등록된 계약 관계가 없습니다.</td></tr>');
        return;
    }
    $.each(list, function(index, row) {
        html += '<tr>';
        html += '<td>' + (index + 1) + '</td>';
        html += '<td>' + escapeHtml(row.custCoNm) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.custSeNm, getCodeNm('CUST_SE_CD', row.custSeCd))) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.relSeNm, getCodeNm('REL_SE_CD', row.relSeCd))) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.relLvl, '-')) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.directCtrtYn, 'N')) + '</td>';
        html += '<td><div class="ds-row-actions">'
            + (hasAuthorityCode('PROJECT_CONTRACT_MDFCN') ? '<button type="button" class="ds-mini-btn" onclick="bindCustRelFormFromEncoded(\'' + encodeRowData(row) + '\');">수정</button>' : '')
            + (hasAuthorityCode('PROJECT_CONTRACT_DEL') ? '<button type="button" class="ds-mini-btn ds-mini-btn-danger" onclick="deleteBizCustRel(\'' + escapeJs(row.bizCustRelSn) + '\');">삭제</button>' : '')
            + '</div></td>';
        html += '</tr>';
    });
    $('#bizCustRelBody').html(html);
}

/**
 * 선택한 계약관계 행 데이터를 입력폼에 채운다.
 * @param {Object} row 선택한 계약관계 데이터
 * @returns 없음
 */
function bindCustRelFormFromRow(row) {
    $('#frmCustSn').val(nvl(row.custSn, ''));
    $('#frmBizCustRelSn').val(nvl(row.bizCustRelSn, ''));
    $('#frmCustCoNm').val(nvl(row.custCoNm, ''));
    $('#frmCustSeCd').val(nvl(row.custSeCd, ''));
    $('#frmBrno').val(nvl(row.brno, ''));
    $('#frmRprsvNm').val(nvl(row.rprsvNm, ''));
    $('#frmTelno').val(nvl(row.telno, ''));
    $('#frmAddr').val(nvl(row.addr, ''));
    $('#frmRelSeCd').val(nvl(row.relSeCd, ''));
    $('#frmRelLvl').val(formatNumberInput(nvl(row.relLvl, '')));
    $('#frmDirectCtrtYn').val(nvl(row.directCtrtYn, 'N'));
}

/**
 * 인코딩된 계약관계 행 데이터를 복원해 입력폼에 채운다.
 * @param {string} encodedRow URI 인코딩된 계약관계 JSON 문자열
 * @returns 없음
 */
function bindCustRelFormFromEncoded(encodedRow) {
    bindCustRelFormFromRow(decodeRowData(encodedRow));
}

/**
 * 고객사 저장 후 사업 계약관계를 저장한다.
 * @param 없음
 * @returns 없음
 */
function saveCustAndRel() {
    if (!$('#frmCustCoNm').val()) {
        alert('고객사명을 입력하십시오.');
        $('#frmCustCoNm').focus();
        return;
    }
    if (!$('#frmRelSeCd').val()) {
        alert('계약관계를 선택하십시오.');
        $('#frmRelSeCd').focus();
        return;
    }

    $.ajax({
        url: ctxPath + '/biz/custSave.ajax',
        type: 'POST',
        dataType: 'json',
        data: {
            custSn: $('#frmCustSn').val(),
            custCoNm: $('#frmCustCoNm').val(),
            custSeCd: $('#frmCustSeCd').val(),
            brno: $('#frmBrno').val(),
            rprsvNm: $('#frmRprsvNm').val(),
            telno: $('#frmTelno').val(),
            addr: $('#frmAddr').val()
        },
        success: function(res) {
            if (res.result !== 'OK') {
                alert('고객사 저장에 실패했습니다.');
                return;
            }
            saveBizCustRelAfterCust(res.custSn || $('#frmCustSn').val());
        },
        error: function() {
            alert('고객사 저장 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 고객사 저장 결과의 고객일련번호로 사업 계약관계를 저장한다.
 * @param {string|number} custSn 고객일련번호
 * @returns 없음
 */
function saveBizCustRelAfterCust(custSn) {
    $.ajax({
        url: ctxPath + '/biz/custRelSave.ajax',
        type: 'POST',
        dataType: 'json',
        data: {
            bizCustRelSn: $('#frmBizCustRelSn').val(),
            bizId: currentBizId,
            custSn: custSn,
            relSeCd: $('#frmRelSeCd').val(),
            relLvl: unformatNumber($('#frmRelLvl').val()),
            directCtrtYn: $('#frmDirectCtrtYn').val()
        },
        success: function(res) {
            if (res.result === 'OK') {
                alert('저장되었습니다.');
                resetCustRelForm();
                loadBizCustRelList();
            } else {
                alert('계약 관계 저장에 실패했습니다.');
            }
        },
        error: function() {
            alert('계약 관계 저장 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 선택한 사업 계약관계를 삭제한다.
 * @param {string|number} bizCustRelSn 사업고객관계일련번호
 * @returns 없음
 */
function deleteBizCustRel(bizCustRelSn) {
    if (!confirm('선택한 계약 관계를 삭제하시겠습니까?')) {
        return;
    }
    $.ajax({
        url: ctxPath + '/biz/custRelDelete.ajax',
        type: 'POST',
        dataType: 'json',
        data: { bizId: currentBizId, bizCustRelSn: bizCustRelSn },
        success: function(res) {
            if (res.result === 'OK') {
                loadBizCustRelList();
            } else {
                alert('삭제에 실패했습니다.');
            }
        }
    });
}

/**
 * 직접비 입력폼을 초기화한다.
 * @param 없음
 * @returns 없음
 */
function resetCstForm() {
    $('#frmBizCstSn').val('');
    $('#frmCstSeCd').val(getDefaultCode('CST_SE_CD'));
    $('#frmCstNm').val('');
    $('#frmOcrnCst').val('');
    $('#frmOcrnYmd').val('');
}

/**
 * 사업 직접비 목록을 조회한다.
 * @param 없음
 * @returns 없음
 */
function loadBizCstList() {
    $.ajax({
        url: ctxPath + '/biz/cstList.ajax',
        type: 'GET',
        dataType: 'json',
        data: { bizId: currentBizId },
        success: function(res) {
            renderBizCstList(res.list || []);
        },
        error: function() {
            $('#bizCstBody').html('<tr><td colspan="6" class="ds-empty">비용 조회 중 오류가 발생했습니다.</td></tr>');
        }
    });
}

/**
 * 직접비 목록을 테이블에 렌더링한다.
 * @param {Array} list 직접비 목록
 * @returns 없음
 */
function renderBizCstList(list) {
    var html = '';
    if (list.length === 0) {
        $('#bizCstBody').html('<tr><td colspan="6" class="ds-empty">등록된 직접비가 없습니다.</td></tr>');
        return;
    }
    $.each(list, function(index, row) {
        html += '<tr>';
        html += '<td>' + (index + 1) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.cstSeNm, getCodeNm('CST_SE_CD', row.cstSeCd))) + '</td>';
        html += '<td>' + escapeHtml(row.cstNm) + '</td>';
        html += '<td>' + formatAmt(row.ocrnCst) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.ocrnYmd, '-')) + '</td>';
        html += '<td><div class="ds-row-actions">'
            + (hasAuthorityCode('PROJECT_ACCOUNT_MDFCN') ? '<button type="button" class="ds-mini-btn" onclick="bindCstFormFromEncoded(\'' + encodeRowData(row) + '\');">수정</button>' : '')
            + (hasAuthorityCode('PROJECT_ACCOUNT_DEL') ? '<button type="button" class="ds-mini-btn ds-mini-btn-danger" onclick="deleteBizCst(\'' + escapeJs(row.bizCstSn) + '\');">삭제</button>' : '')
            + '</div></td>';
        html += '</tr>';
    });
    $('#bizCstBody').html(html);
}

/**
 * 선택한 직접비 행 데이터를 입력폼에 채운다.
 * @param {Object} row 직접비 데이터
 * @returns 없음
 */
function bindCstFormFromRow(row) {
    $('#frmBizCstSn').val(nvl(row.bizCstSn, ''));
    $('#frmCstSeCd').val(nvl(row.cstSeCd, ''));
    $('#frmCstNm').val(nvl(row.cstNm, ''));
    $('#frmOcrnCst').val(formatNumberInput(nvl(row.ocrnCst, '')));
    $('#frmOcrnYmd').val(nvl(row.ocrnYmd, ''));
}

/**
 * 인코딩된 직접비 행 데이터를 복원해 입력폼에 채운다.
 * @param {string} encodedRow URI 인코딩된 직접비 JSON 문자열
 * @returns 없음
 */
function bindCstFormFromEncoded(encodedRow) {
    bindCstFormFromRow(decodeRowData(encodedRow));
}

/**
 * 직접비를 등록 또는 수정한다.
 * @param 없음
 * @returns 없음
 */
function saveBizCst() {
    if (!$('#frmCstSeCd').val() || !$('#frmCstNm').val()) {
        alert('비용구분과 비용명을 입력하십시오.');
        return;
    }
    $.ajax({
        url: ctxPath + '/biz/cstSave.ajax',
        type: 'POST',
        dataType: 'json',
        data: {
            bizId: currentBizId,
            bizCstSn: $('#frmBizCstSn').val(),
            cstSeCd: $('#frmCstSeCd').val(),
            cstNm: $('#frmCstNm').val(),
            ocrnCst: unformatNumber($('#frmOcrnCst').val()),
            ocrnYmd: $('#frmOcrnYmd').val()
        },
        success: function(res) {
            if (res.result === 'OK') {
                resetCstForm();
                loadBizCstList();
                loadBizProfitSummary();
            } else {
                alert('비용 저장에 실패했습니다.');
            }
        }
    });
}

/**
 * 선택한 직접비를 삭제한다.
 * @param {string|number} bizCstSn 사업비용일련번호
 * @returns 없음
 */
function deleteBizCst(bizCstSn) {
    if (!confirm('선택한 비용을 삭제하시겠습니까?')) {
        return;
    }
    $.ajax({
        url: ctxPath + '/biz/cstDelete.ajax',
        type: 'POST',
        dataType: 'json',
        data: { bizId: currentBizId, bizCstSn: bizCstSn },
        success: function(res) {
            if (res.result === 'OK') {
                loadBizCstList();
                loadBizProfitSummary();
            } else {
                alert('삭제에 실패했습니다.');
            }
        }
    });
}

/**
 * 투입인력 입력폼을 초기화한다.
 * @param 없음
 * @returns 없음
 */
function resetMnpwForm() {
    $('#frmBizMnpwSn').val('');
    $('#frmUserId').val('');
    $('#frmUserDispNm').val('');
    $('#frmInputMnpwNm').val('');
    $('#frmInputSeCd').val(getDefaultCode('INPUT_SE_CD'));
    $('#frmRoleNm').val('');
    $('#frmJbpsNm').val('');
    $('#frmInputBgngYmd').val('');
    $('#frmInputEndYmd').val('');
    $('#frmInputMcnt').val('');
    $('#frmUntprc').val('');
    $('#frmInputRt').val('100');
}

/**
 * 사업 투입인력 목록을 조회한다.
 * @param 없음
 * @returns 없음
 */
function loadBizMnpwList() {
    $.ajax({
        url: ctxPath + '/biz/mnpwList.ajax',
        type: 'GET',
        dataType: 'json',
        data: { bizId: currentBizId },
        success: function(res) {
            renderBizMnpwList(res.list || []);
        },
        error: function() {
            $('#bizMnpwBody').html('<tr><td colspan="10" class="ds-empty">투입인력 조회 중 오류가 발생했습니다.</td></tr>');
        }
    });
}

/**
 * 투입인력 목록을 테이블에 렌더링한다.
 * @param {Array} list 투입인력 목록
 * @returns 없음
 */
function renderBizMnpwList(list) {
    var html = '';
    if (list.length === 0) {
        $('#bizMnpwBody').html('<tr><td colspan="10" class="ds-empty">등록된 투입인력이 없습니다.</td></tr>');
        return;
    }
    $.each(list, function(index, row) {
        var labor = Number(row.inputMcnt || 0) * Number(row.untprc || 0);
        html += '<tr>';
        html += '<td>' + (index + 1) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.inputMnpwNm || row.userNm, '-')) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.inputSeNm, getCodeNm('INPUT_SE_CD', row.inputSeCd))) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.roleNm, '-')) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.inputBgngYmd, '-')) + ' ~ ' + escapeHtml(nvl(row.inputEndYmd, '-')) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.inputRt, '100')) + '%</td>';
        html += '<td>' + escapeHtml(nvl(row.inputMcnt, '0')) + '</td>';
        html += '<td>' + formatAmt(row.untprc) + '</td>';
        html += '<td>' + formatAmt(labor) + '</td>';
        html += '<td><div class="ds-row-actions">'
            + (hasAuthorityCode('PROJECT_MNPW_MDFCN') ? '<button type="button" class="ds-mini-btn" onclick="bindMnpwFormFromEncoded(\'' + encodeRowData(row) + '\');">수정</button>' : '')
            + (hasAuthorityCode('PROJECT_MNPW_DEL') ? '<button type="button" class="ds-mini-btn ds-mini-btn-danger" onclick="deleteBizMnpw(\'' + escapeJs(row.bizMnpwSn) + '\');">삭제</button>' : '')
            + '</div></td>';
        html += '</tr>';
    });
    $('#bizMnpwBody').html(html);
}

/**
 * 선택한 투입인력 행 데이터를 입력폼에 채운다.
 * @param {Object} row 투입인력 데이터
 * @returns 없음
 */
function bindMnpwFormFromRow(row) {
    $('#frmBizMnpwSn').val(nvl(row.bizMnpwSn, ''));
    $('#frmUserId').val(nvl(row.userId, ''));
    $('#frmUserDispNm').val(nvl(row.userNm || row.inputMnpwNm || row.userId, ''));
    $('#frmInputMnpwNm').val(nvl(row.inputMnpwNm || row.userNm, ''));
    $('#frmInputSeCd').val(nvl(row.inputSeCd, ''));
    $('#frmRoleNm').val(nvl(row.roleNm, ''));
    $('#frmJbpsNm').val(nvl(row.jbpsNm, ''));
    $('#frmInputBgngYmd').val(nvl(row.inputBgngYmd, ''));
    $('#frmInputEndYmd').val(nvl(row.inputEndYmd, ''));
    $('#frmInputMcnt').val(nvl(row.inputMcnt, ''));
    $('#frmUntprc').val(formatNumberInput(nvl(row.untprc, '')));
    $('#frmInputRt').val(formatNumberInput(nvl(row.inputRt, '100')));
}

/**
 * 인코딩된 투입인력 행 데이터를 복원해 입력폼에 채운다.
 * @param {string} encodedRow URI 인코딩된 투입인력 JSON 문자열
 * @returns 없음
 */
function bindMnpwFormFromEncoded(encodedRow) {
    bindMnpwFormFromRow(decodeRowData(encodedRow));
}

/**
 * 투입인력을 등록 또는 수정한다.
 * @param 없음
 * @returns 없음
 */
function saveBizMnpw() {
    if (!$('#frmInputMnpwNm').val()) {
        alert('투입인력명을 입력하십시오.');
        $('#frmInputMnpwNm').focus();
        return;
    }
    $.ajax({
        url: ctxPath + '/biz/mnpwSave.ajax',
        type: 'POST',
        dataType: 'json',
        data: {
            bizId: currentBizId,
            bizMnpwSn: $('#frmBizMnpwSn').val(),
            userId: $('#frmUserId').val(),
            inputMnpwNm: $('#frmInputMnpwNm').val(),
            inputSeCd: $('#frmInputSeCd').val(),
            roleNm: $('#frmRoleNm').val(),
            jbpsNm: $('#frmJbpsNm').val(),
            inputBgngYmd: $('#frmInputBgngYmd').val(),
            inputEndYmd: $('#frmInputEndYmd').val(),
            inputMcnt: calcInputMcnt($('#frmInputBgngYmd').val(), $('#frmInputEndYmd').val(), $('#frmInputRt').val()),
            untprc: unformatNumber($('#frmUntprc').val()),
            inputRt: unformatNumber($('#frmInputRt').val()) || '100'
        },
        success: function(res) {
            if (res.result === 'OK') {
                resetMnpwForm();
                loadBizMnpwList();
                loadBizProfitSummary();
            } else {
                alert('투입인력 저장에 실패했습니다.');
            }
        }
    });
}

/**
 * 선택한 투입인력을 삭제한다.
 * @param {string|number} bizMnpwSn 사업투입인력일련번호
 * @returns 없음
 */
function deleteBizMnpw(bizMnpwSn) {
    if (!confirm('선택한 투입인력을 삭제하시겠습니까?')) {
        return;
    }
    $.ajax({
        url: ctxPath + '/biz/mnpwDelete.ajax',
        type: 'POST',
        dataType: 'json',
        data: { bizId: currentBizId, bizMnpwSn: bizMnpwSn },
        success: function(res) {
            if (res.result === 'OK') {
                loadBizMnpwList();
                loadBizProfitSummary();
            } else {
                alert('삭제에 실패했습니다.');
            }
        }
    });
}

/**
 * 사업 일정 입력폼을 초기화한다.
 * @param 없음
 * @returns 없음
 */
function resetSchdlForm() {
    $('#frmBizSchdlSn').val('');
    $('#frmSchdlSeCd').val(getDefaultCode('SCHDL_SE_CD'));
    $('#frmSchdlNm').val('');
    $('#frmSchdlCn').val('');
    $('#frmSchdlBgngYmd').val('');
    $('#frmSchdlEndYmd').val('');
    $('#frmPicId').val('');
    $('#frmPicDispNm').val('');
}

/**
 * 사업 프로세스 일정 목록을 조회한다.
 * @param 없음
 * @returns 없음
 */
function loadBizSchdlList() {
    $.ajax({
        url: ctxPath + '/biz/schdlList.ajax',
        type: 'GET',
        dataType: 'json',
        data: { bizId: currentBizId },
        success: function(res) {
            renderBizSchdlList(res.list || []);
        },
        error: function() {
            $('#bizSchdlBody').html('<tr><td colspan="7" class="ds-empty">일정 조회 중 오류가 발생했습니다.</td></tr>');
        }
    });
}

/**
 * 사업 프로세스 일정 목록을 테이블에 렌더링한다.
 * @param {Array} list 사업 일정 목록
 * @returns 없음
 */
function renderBizSchdlList(list) {
    var html = '';
    if (list.length === 0) {
        $('#bizSchdlBody').html('<tr><td colspan="7" class="ds-empty">등록된 일정이 없습니다.</td></tr>');
        return;
    }
    $.each(list, function(index, row) {
        html += '<tr>';
        html += '<td>' + (index + 1) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.schdlSeNm, getCodeNm('SCHDL_SE_CD', row.schdlSeCd))) + '</td>';
        html += '<td>' + escapeHtml(row.schdlNm) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.schdlBgngYmd, '-')) + ' ~ ' + escapeHtml(nvl(row.schdlEndYmd, '-')) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.picNm || row.picId, '-')) + '</td>';
        html += '<td>' + escapeHtml(nvl(row.schdlCn, '-')) + '</td>';
        html += '<td><div class="ds-row-actions">'
            + (hasAuthorityCode('PROJECT_PROCESS_MDFCN') ? '<button type="button" class="ds-mini-btn" onclick="bindSchdlFormFromEncoded(\'' + encodeRowData(row) + '\');">수정</button>' : '')
            + (hasAuthorityCode('PROJECT_PROCESS_DEL') ? '<button type="button" class="ds-mini-btn ds-mini-btn-danger" onclick="deleteBizSchdl(\'' + escapeJs(row.bizSchdlSn) + '\');">삭제</button>' : '')
            + '</div></td>';
        html += '</tr>';
    });
    $('#bizSchdlBody').html(html);
}

/**
 * 선택한 일정 행 데이터를 입력폼에 채운다.
 * @param {Object} row 사업 일정 데이터
 * @returns 없음
 */
function bindSchdlFormFromRow(row) {
    $('#frmBizSchdlSn').val(nvl(row.bizSchdlSn, ''));
    $('#frmSchdlSeCd').val(nvl(row.schdlSeCd, ''));
    $('#frmSchdlNm').val(nvl(row.schdlNm, ''));
    $('#frmSchdlCn').val(nvl(row.schdlCn, ''));
    $('#frmSchdlBgngYmd').val(nvl(row.schdlBgngYmd, ''));
    $('#frmSchdlEndYmd').val(nvl(row.schdlEndYmd, ''));
    $('#frmPicId').val(nvl(row.picId, ''));
    $('#frmPicDispNm').val(nvl(row.picNm || row.picId, ''));
}

/**
 * 인코딩된 일정 행 데이터를 복원해 입력폼에 채운다.
 * @param {string} encodedRow URI 인코딩된 일정 JSON 문자열
 * @returns 없음
 */
function bindSchdlFormFromEncoded(encodedRow) {
    bindSchdlFormFromRow(decodeRowData(encodedRow));
}

/**
 * 사업 프로세스 일정을 등록 또는 수정한다.
 * @param 없음
 * @returns 없음
 */
function saveBizSchdl() {
    if (!$('#frmSchdlSeCd').val() || !$('#frmSchdlNm').val()) {
        alert('일정구분과 일정명을 입력하십시오.');
        return;
    }
    $.ajax({
        url: ctxPath + '/biz/schdlSave.ajax',
        type: 'POST',
        dataType: 'json',
        data: {
            bizId: currentBizId,
            bizSchdlSn: $('#frmBizSchdlSn').val(),
            schdlSeCd: $('#frmSchdlSeCd').val(),
            schdlNm: $('#frmSchdlNm').val(),
            schdlCn: $('#frmSchdlCn').val(),
            schdlBgngYmd: $('#frmSchdlBgngYmd').val(),
            schdlEndYmd: $('#frmSchdlEndYmd').val(),
            picId: $('#frmPicId').val()
        },
        success: function(res) {
            if (res.result === 'OK') {
                resetSchdlForm();
                loadBizSchdlList();
            } else {
                alert('일정 저장에 실패했습니다.');
            }
        }
    });
}

/**
 * 선택한 사업 프로세스 일정을 삭제한다.
 * @param {string|number} bizSchdlSn 사업일정일련번호
 * @returns 없음
 */
function deleteBizSchdl(bizSchdlSn) {
    if (!confirm('선택한 일정을 삭제하시겠습니까?')) {
        return;
    }
    $.ajax({
        url: ctxPath + '/biz/schdlDelete.ajax',
        type: 'POST',
        dataType: 'json',
        data: { bizId: currentBizId, bizSchdlSn: bizSchdlSn },
        success: function(res) {
            if (res.result === 'OK') {
                loadBizSchdlList();
            } else {
                alert('삭제에 실패했습니다.');
            }
        }
    });
}
