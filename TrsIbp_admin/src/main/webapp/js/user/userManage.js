var empTable = null;
var empIdCheckedValue = '';

/**
 * 사용자ID 중복확인 결과 문구와 상태 색상을 갱신한다.
 * @param {string} message 표시할 결과 문구
 * @param {string} state success, error 또는 빈 문자열
 * @returns {void}
 */
function setEmpIdCheckMessage(message, state) {
    var $message = $('#empIdCheckMessage');
    $message.text(message || '').removeClass('is-success is-error');
    if (state === 'success' || state === 'error') {
        $message.addClass('is-' + state);
    }
}

/**
 * 사용자 목록 화면을 초기화한다.
 * @returns {void}
 */
function initEmpListPage() {
    loadEmpMeta(function () {
        loadEmpList();
    });
}

/**
 * 사용자 등록/수정 화면을 초기화한다.
 * @param {string} mode 저장 모드(insert/update)
 * @param {string} userId 수정 대상 사용자ID
 * @returns {void}
 */
function initEmpFormPage(mode, userId) {
    if (mode === 'insert') {
        $('#frmUserId').on('input', function () {
            empIdCheckedValue = '';
            setEmpIdCheckMessage('', '');
        });
    }
    $('#frmProfileFile').on('change', previewEmpProfileFile);
    $('#frmUserFiles').on('change', renderSelectedEmpFiles);
    loadEmpMeta(function () {
        if (mode === 'update' && userId) {
            loadEmpForm(userId);
        }
    });
}

/**
 * 사용자 등록 화면에서 사용자ID 형식과 중복 여부를 확인한다.
 * @returns {void}
 */
function checkEmpUserId() {
    var userId = $.trim($('#frmUserId').val());
    if (!/^(?=.*[a-z])[a-z0-9]{6,20}$/.test(userId)) {
        empIdCheckedValue = '';
        setEmpIdCheckMessage('', '');
        alert('사용자ID는 영문 소문자와 숫자 6~20자로 입력하고 영문 소문자를 포함해야 합니다.');
        $('#frmUserId').focus();
        return;
    }
    $.ajax({
        url: getContextPath() + '/user/empIdCheck.ajax',
        type: 'GET',
        data: { userId: userId },
        dataType: 'json',
        success: function (res) {
            if (res.result !== 'OK') {
                empIdCheckedValue = '';
                setEmpIdCheckMessage('', '');
                alert(res.msg || '사용자ID를 확인하지 못했습니다.');
                return;
            }
            if (Number(res.cnt || 0) > 0) {
                empIdCheckedValue = '';
                setEmpIdCheckMessage('이미 사용 중인 사용자ID입니다.', 'error');
                return;
            }
            empIdCheckedValue = userId;
            setEmpIdCheckMessage('사용할 수 있는 사용자ID입니다.', 'success');
        },
        error: function () {
            empIdCheckedValue = '';
            setEmpIdCheckMessage('', '');
            alert('사용자ID 중복확인 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 사용자 상세 화면을 초기화한다.
 * @param {string} userId 조회 대상 사용자ID
 * @returns {void}
 */
function initEmpDetailPage(userId) {
    if (!userId) {
        alert('사용자ID가 없습니다.');
        goEmpList();
        return;
    }
    loadEmpDetail(userId);
}

/**
 * 사용자 화면에서 사용하는 부서/권한 목록을 조회하여 select에 바인딩한다.
 * @param {Function} callback 조회 완료 후 실행할 콜백
 * @returns {void}
 */
function loadEmpMeta(callback) {
    $.ajax({
        url: getContextPath() + '/user/empMeta.ajax',
        type: 'GET',
        dataType: 'json',
        success: function (res) {
            bindEmpDeptOptions(res.deptList || []);
            bindEmpAuthOptions(res.authList || []);
            if (typeof callback === 'function') {
                callback();
            }
        },
        error: function () {
            alert('사용자 관리 공통 정보를 조회하지 못했습니다.');
        }
    });
}

/**
 * 부서 select 옵션을 바인딩한다.
 * @param {Array} deptList 부서 목록
 * @returns {void}
 */
function clearEmpDeptSelection() {
    $('#frmDeptId').val('');
    $('#frmDeptNm').val('');
}

function bindEmpDeptOptions(deptList) {
    var $search = $('#empSearchDeptId');
    if ($search.length) {
        $search.empty().append('<option value="">전체</option>');
    }
    deptList.forEach(function (dept) {
        var label = dept.deptNm || '';
        if (dept.upDeptNm) {
            label = dept.upDeptNm + ' > ' + label;
        }
        var option = '<option value="' + escapeHtml(dept.deptId) + '">' + escapeHtml(label) + '</option>';
        if ($search.length) {
            $search.append(option);
        }
    });
}

/**
 * 권한 select 옵션을 바인딩한다.
 * @param {Array} authList 권한 목록
 * @returns {void}
 */
function bindEmpAuthOptions(authList) {
    var $form = $('#frmAuthrtId');
    if (!$form.length) {
        return;
    }
    $form.empty().append('<option value="">선택</option>');
    authList.forEach(function (auth) {
        $form.append('<option value="' + escapeHtml(auth.AUTHRT_ID || auth.authrtId || '') + '">' + escapeHtml(auth.AUTHRT_NM || auth.authrtNm || '') + '</option>');
    });
}

/**
 * 사용자 목록을 조회한다.
 * @returns {void}
 */
function loadEmpList() {
    $.ajax({
        url: getContextPath() + '/user/empList.ajax',
        type: 'GET',
        data: $('#empSearchForm').serialize(),
        dataType: 'json',
        success: function (res) {
            renderEmpTable(res.userList || []);
        },
        error: function () {
            alert('사용자 목록 조회 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 사용자 목록 테이블을 렌더링한다.
 * @param {Array} list 사용자 목록
 * @returns {void}
 */
function renderEmpTable(list) {
    var rows = list.map(function (item) {
        var useYnNm = item.useYn === 'Y' ? '사용' : '미사용';
        var userId = item.userId || '';
        return {
            userId: userId,
            row: [
                escapeHtml(userId),
                hasAuthorityCode('MANAGEMENT_USER_DETAIL')
                    ? '<a class="ds-link" href="' + getContextPath() + '/user/empDetail.do?userId=' + encodeURIComponent(userId) + '">' + escapeHtml(item.userNm) + '</a>'
                    : escapeHtml(item.userNm),
                escapeHtml(item.deptNm),
                escapeHtml(item.jbpsNm),
                escapeHtml(item.authrtNm),
                escapeHtml(item.userTelno),
                useYnNm,
                escapeHtml(item.regDt),
                '<div class="ds-row-actions">'
                + (hasAuthorityCode('MANAGEMENT_USER_MDFCN_SCREEN') ? '<button type="button" class="ds-mini-btn" onclick="goEmpUpdate(\'' + escapeJs(userId) + '\');">수정</button>' : '')
                + (hasAuthorityCode('MANAGEMENT_USER_DEL') ? '<button type="button" class="ds-mini-btn ds-mini-btn-danger" onclick="deleteEmp(\'' + escapeJs(userId) + '\');">삭제</button>' : '')
                + '</div>'
            ]
        };
    });

    var tableRows = rows.map(function (item) { return item.row; });

    if (empTable) {
        empTable.clear().rows.add(tableRows).draw();
        return;
    }
    empTable = $('#empTable').DataTable({
        data: tableRows,
        ordering: true,
        searching: false,
        lengthChange: false,
        pageLength: 10,
        language: {
            emptyTable: '조회된 사용자가 없습니다.',
            info: '_TOTAL_건 중 _START_ - _END_',
            infoEmpty: '0건',
            paginate: { previous: '이전', next: '다음' }
        },
    });
}

/**
 * 사용자 수정 화면에 단건 정보를 바인딩한다.
 * @param {string} userId 사용자ID
 * @returns {void}
 */
function loadEmpForm(userId) {
    $.ajax({
        url: getContextPath() + '/user/empDetail.ajax',
        type: 'GET',
        data: { userId: userId },
        dataType: 'json',
        success: function (res) {
            var user = res.user;
            if (!user) {
                alert('사용자 정보를 찾을 수 없습니다.');
                goEmpList();
                return;
            }
            $('#frmUserId').val(user.userId);
            $('#frmUserNm').val(user.userNm);
            $('#frmDeptId').val(user.deptId);
            $('#frmDeptNm').val(formatUserDeptName(user));
            $('#frmJbpsNm').val(user.jbpsNm);
            $('#frmAuthrtId').val(user.authrtId);
            $('#frmUserTelno').val(user.userTelno);
            $('#frmUseYn').val(user.useYn || 'Y');
            $('#frmMemoCn').val(user.memoCn);
            renderEmpProfile(res.profileFile, false);
            renderEmpAttachmentList(res.attachmentList || [], false);
        },
        error: function () {
            alert('사용자 정보 조회 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 사용자 상세 화면에 단건 정보를 표시한다.
 * @param {string} userId 사용자ID
 * @returns {void}
 */
function loadEmpDetail(userId) {
    $.ajax({
        url: getContextPath() + '/user/empDetail.ajax',
        type: 'GET',
        data: { userId: userId },
        dataType: 'json',
        success: function (res) {
            var user = res.user;
            if (!user) {
                alert('사용자 정보를 찾을 수 없습니다.');
                goEmpList();
                return;
            }
            $('#dispUserId').val(user.userId || '');
            $('#dispUserNm').val(user.userNm || '');
            $('#dispCoNm').val(user.coNm || '');
            $('#dispDeptNm').val(formatUserDeptName(user) || '미지정');
            $('#dispJbpsNm').val(user.jbpsNm || '');
            $('#dispAuthrtNm').val(user.authrtNm || '');
            $('#dispUserTelno').val(user.userTelno || '');
            $('#dispUseYn').val(user.useYn === 'Y' ? '사용' : '미사용');
            $('#dispRegDt').val(user.regDt || '');
            $('#dispMemoCn').val(user.memoCn || '');
            renderEmpProfile(res.profileFile, true);
            renderEmpAttachmentList(res.attachmentList || [], true);
        },
        error: function () {
            alert('사용자 정보 조회 중 오류가 발생했습니다.');
        }
    });
}

/**
 * 사용자 정보를 저장한다.
 * @returns {void}
 */
function saveEmp() {
    if (!validateEmpForm()) {
        return;
    }
    if (!validateEmpFiles()) {
        return;
    }
    var formData = new FormData($('#empForm')[0]);
    $.ajax({
        url: getContextPath() + '/user/empSave.ajax',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        dataType: 'json',
        success: function (res) {
            if (res.result === 'OK') {
                alert('저장되었습니다.');
                goEmpDetail($('#frmUserId').val());
                return;
            }
            alert(res.msg || '저장에 실패했습니다.');
        },
        error: function () {
            alert('사용자 저장 중 오류가 발생했습니다.');
        }
    });
}

function previewEmpProfileFile() {
    var file = this.files && this.files[0];
    if (!file) {
        $('#empProfileFileName').text('선택된 파일 없음');
        return;
    }
    if (!/^image\/(jpeg|png|gif)$/i.test(file.type) || file.size > 5 * 1000 * 1000) {
        alert('프로필 사진은 JPG, PNG, GIF 형식의 5MB 이하 파일만 등록할 수 있습니다.');
        $(this).val('');
        $('#empProfileFileName').text('선택된 파일 없음');
        return;
    }
    $('#empProfilePreview').attr('src', URL.createObjectURL(file)).removeClass('hidden');
    $('#empProfileFileName').text(file.name);
}

function renderSelectedEmpFiles() {
    var files = Array.prototype.slice.call(this.files || []);
    if (!files.length) {
        $('#empSelectedFileList').empty();
        $('#empUserFileSummary').text('선택된 파일 없음');
        return;
    }
    $('#empUserFileSummary').text(files.length + '개 파일 선택');
    $('#empSelectedFileList').html('<strong class="ds-file-list-title">새로 등록할 파일</strong>' + files.map(function(file) {
        return '<div class="ds-file-row"><span>' + escapeHtml(file.name) + '</span><em>' + formatEmpFileSize(file.size) + '</em></div>';
    }).join(''));
}

function renderEmpProfile(profileFile, detailMode) {
    var fileSn = profileFile && profileFile.atchFileSn;
    var defaultImage = getContextPath() + '/images/default-profile.svg';
    if (detailMode) {
        var detailImage = fileSn
            ? getContextPath() + '/common/fileView.do?atchFileSn=' + encodeURIComponent(fileSn)
            : defaultImage;
        $('#dispProfilePhoto').html('<img src="' + detailImage + '" onerror="this.onerror=null;this.src=\''
            + defaultImage + '\';" alt="프로필 사진" class="ds-profile-detail-image">');
        return;
    }
    $('#btnDeleteProfileFile').data('fileSn', fileSn || '').toggleClass('hidden', !fileSn);
    $('#empProfileFileName').text('선택된 파일 없음');
    if (!fileSn) {
        $('#empProfilePreview').attr('src', defaultImage).removeClass('hidden');
        return;
    }
    $('#empProfilePreview')
        .attr('onerror', "this.onerror=null;this.src='" + defaultImage + "';")
        .attr('src', getContextPath() + '/common/fileView.do?atchFileSn=' + encodeURIComponent(fileSn))
        .removeClass('hidden');
}

function renderEmpAttachmentList(list, detailMode) {
    var selector = detailMode ? '#dispAttachmentList' : '#empExistingFileList';
    if (!list.length) {
        $(selector).html('<span class="ds-file-empty">등록된 첨부파일이 없습니다.</span>');
        return;
    }
    var title = detailMode ? '' : '<strong class="ds-file-list-title">기존 등록 파일</strong>';
    $(selector).html(title + list.map(function(file) {
        var download = getContextPath() + '/common/fileDownload.do?atchFileSn=' + encodeURIComponent(file.atchFileSn);
        return '<div class="ds-file-row"><a href="' + download + '">' + escapeHtml(file.orgnlFileNm || '첨부파일') + '</a><span class="ds-file-row-actions"><em>'
            + formatEmpFileSize(file.fileSz) + '</em>'
            + (detailMode ? '' : '<button type="button" class="ds-mini-btn ds-mini-btn-danger" onclick="deleteEmpAttachment(' + Number(file.atchFileSn) + ');">삭제</button>')
            + '</span></div>';
    }).join(''));
}

function deleteCurrentEmpProfile() {
    var fileSn = $('#btnDeleteProfileFile').data('fileSn');
    if (fileSn) {
        deleteEmpFile(fileSn);
    }
}

function deleteEmpAttachment(fileSn) {
    deleteEmpFile(fileSn);
}

function deleteEmpFile(fileSn) {
    var userId = $('#frmUserId').val();
    if (!fileSn || !userId || !confirm('선택한 파일을 삭제하시겠습니까?')) {
        return;
    }
    $.ajax({
        url: getContextPath() + '/common/userFileDelete.ajax',
        type: 'POST',
        dataType: 'json',
        data: { atchFileSn: fileSn, userId: userId },
        success: function(res) {
            if (res.result !== 'OK') {
                alert(res.msg || '파일을 삭제하지 못했습니다.');
                return;
            }
            loadEmpForm(userId);
        },
        error: function() {
            alert('파일 삭제 중 오류가 발생했습니다.');
        }
    });
}

function validateEmpFiles() {
    var profile = $('#frmProfileFile')[0];
    if (profile && profile.files && profile.files[0]) {
        var profileFile = profile.files[0];
        if (!/^image\/(jpeg|png|gif)$/i.test(profileFile.type) || profileFile.size > 5 * 1000 * 1000) {
            alert('프로필 사진은 JPG, PNG, GIF 형식의 5MB 이하 파일만 등록할 수 있습니다.');
            return false;
        }
    }
    var input = $('#frmUserFiles')[0];
    var files = input ? Array.prototype.slice.call(input.files || []) : [];
    if (files.length > 10) {
        alert('첨부파일은 한 번에 최대 10개까지 등록할 수 있습니다.');
        return false;
    }
    for (var i = 0; i < files.length; i++) {
        if (files[i].size > 10 * 1000 * 1000) {
            alert(files[i].name + ' 파일이 10MB를 초과합니다.');
            return false;
        }
    }
    return true;
}

function formatEmpFileSize(size) {
    var value = Number(size || 0);
    if (value >= 1000 * 1000) return (value / (1000 * 1000)).toFixed(1) + ' MB';
    if (value >= 1000) return Math.round(value / 1000) + ' KB';
    return value + ' B';
}


/**
 * 사용자 등록/수정 화면의 부서 선택 모달을 연다.
 * @returns {void}
 */
function openEmpDeptSelectModal() {
    openDeptSelectModal({
        url: getContextPath() + '/common/deptSelectList.ajax',
        type: 'GET',
        targetId: '#frmDeptId',
        targetName: '#frmDeptNm'
    });
}

/**
 * 사용자 저장 전 필수값을 검증한다.
 * @returns {boolean} 검증 통과 여부
 */
function validateEmpForm() {
    if (!$('#frmUserId').val()) {
        alert('사용자ID를 입력해 주세요.');
        $('#frmUserId').focus();
        return false;
    }
    if (!$('#frmUserNm').val()) {
        alert('사용자명을 입력해 주세요.');
        $('#frmUserNm').focus();
        return false;
    }
    if ($('#frmSaveMode').val() === 'insert') {
        var userId = $.trim($('#frmUserId').val());
        if (!/^(?=.*[a-z])[a-z0-9]{6,20}$/.test(userId)) {
            alert('사용자ID는 영문 소문자와 숫자 6~20자로 입력하고 영문 소문자를 포함해야 합니다.');
            $('#frmUserId').focus();
            return false;
        }
        if (empIdCheckedValue !== userId) {
            alert('사용자ID 중복확인을 해 주세요.');
            $('#btnEmpIdCheck').focus();
            return false;
        }
    }
    if (!$('#frmAuthrtId').val()) {
        alert('권한을 선택해 주세요.');
        $('#frmAuthrtId').focus();
        return false;
    }
    if ($('#frmSaveMode').val() === 'insert' && !$('#frmUserEnpswd').val()) {
        alert('초기 비밀번호를 입력해 주세요.');
        $('#frmUserEnpswd').focus();
        return false;
    }
    return true;
}

/**
 * 사용자를 사용중지 처리한다.
 * @param {string} userId 사용자ID
 * @returns {void}
 */
function deleteEmp(userId) {
    if (!userId) {
        alert('삭제할 사용자ID가 없습니다.');
        return;
    }
    if (!confirm('해당 사용자를 삭제하시겠습니까?\n실제 데이터는 사용중지 처리됩니다.')) {
        return;
    }
    $.ajax({
        url: getContextPath() + '/user/empDelete.ajax',
        type: 'POST',
        data: { userId: userId },
        dataType: 'json',
        success: function (res) {
            if (res.result === 'OK') {
                alert('삭제되었습니다.');
                goEmpList();
                return;
            }
            alert(res.msg || '삭제에 실패했습니다.');
        },
        error: function () {
            alert('사용자 삭제 중 오류가 발생했습니다.');
        }
    });
}

/** 검색 조건을 초기화하고 목록을 재조회한다. */
function resetEmpSearch() {
    $('#empSearchForm')[0].reset();
    loadEmpList();
}

/** 사용자 목록 화면으로 이동한다. */
function goEmpList() { location.href = getContextPath() + '/user/empList.do'; }
/** 사용자 등록 화면으로 이동한다. */
function goEmpInsert() { location.href = getContextPath() + '/user/empInsert.do'; }
/** 사용자 상세 화면으로 이동한다. @param {string} userId 사용자ID */
function goEmpDetail(userId) { location.href = getContextPath() + '/user/empDetail.do?userId=' + encodeURIComponent(userId); }
/** 사용자 수정 화면으로 이동한다. @param {string} userId 사용자ID */
function goEmpUpdate(userId) { location.href = getContextPath() + '/user/empUpdate.do?userId=' + encodeURIComponent(userId); }

/**
 * 현재 애플리케이션 컨텍스트 경로를 반환한다.
 * 사용자 관리 화면이 루트 컨텍스트(/user/empList.do)로 배포된 경우 기존 pathname 기반 계산은 /user를 컨텍스트로 오인하여
 * /user/user/empMeta.ajax처럼 잘못된 URL을 만들 수 있으므로, 실제 로드된 userManage.js의 script src 기준으로 계산한다.
 *
 * @returns {string} 컨텍스트 경로. 루트 컨텍스트이면 빈 문자열을 반환한다.
 */
function getContextPath() {
    if (window.ctxPath !== undefined && window.ctxPath !== null) {
        return window.ctxPath;
    }

    var scripts = document.getElementsByTagName('script');
    for (var i = scripts.length - 1; i >= 0; i--) {
        var src = scripts[i].getAttribute('src') || '';
        var marker = '/js/user/userManage.js';
        var idx = src.indexOf(marker);
        if (idx > -1) {
            var prefix = src.substring(0, idx);
            if (prefix.indexOf('://') > -1) {
                var origin = window.location.origin || (window.location.protocol + '//' + window.location.host);
                prefix = prefix.replace(origin, '');
            }
            return prefix === '/' ? '' : prefix;
        }
    }

    return '';
}

/** HTML 특수문자를 화면 출력용으로 변환한다. @param {string} value 원본 값 @returns {string} 변환 값 */
function escapeHtml(value) {
    if (value === null || value === undefined) {
        return '';
    }
    return String(value).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

/** JS 문자열에 안전하게 들어가도록 변환한다. @param {string} value 원본 값 @returns {string} 변환 값 */
function escapeJs(value) {
    if (value === null || value === undefined) {
        return '';
    }
    return String(value).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\r?\n/g, ' ');
}

/**
 * 사용자 조회 결과의 부서 표시명을 만든다.
 * @param {Object} user 사용자 정보
 * @returns {string} 상위부서가 있으면 '상위부서 > 부서', 없으면 부서명
 */
function formatUserDeptName(user) {
    user = user || {};
    var deptNm = user.deptNm || '';
    var upDeptNm = user.upDeptNm || '';
    if (upDeptNm && deptNm && upDeptNm !== deptNm) {
        return upDeptNm + ' > ' + deptNm;
    }
    return deptNm;
}
