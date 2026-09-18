/* =========================================================
 * 공통 단일 사용자 선택 모달
 * - 부서 트리는 접기/펼치기 방식으로 표시한다.
 * - 상위 부서를 선택하면 해당 부서 하위 전체 사용자를 조회한다.
 * ========================================================= */
(function(window, $) {
    'use strict';

    var userSelectTarget = '';
    var userSelectDeptId = '';
    var userSelectDeptList = [];
    var userDeptExpandedMap = {};
    var userMultiSelectedMap = {};
    var UNASSIGNED_DEPT_ID = '__UNASSIGNED__';

    /**
     * null/undefined 값을 기본 문자열로 치환한다.
     * @param {*} value 검사할 값
     * @param {string} defaultValue 값이 없을 때 반환할 기본값
     * @returns {string} 치환된 문자열
     */
    function usmNvl(value, defaultValue) {
        return value === null || value === undefined || value === '' ? (defaultValue || '') : value;
    }

    /**
     * HTML 출력용 문자열을 이스케이프한다.
     * @param {*} value 이스케이프할 값
     * @returns {string} HTML 특수문자가 변환된 문자열
     */
    function usmEscapeHtml(value) {
        return String(usmNvl(value, ''))
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    /**
     * onclick 인자에 넣을 수 있도록 문자열을 이스케이프한다.
     * @param {*} value 이스케이프할 값
     * @returns {string} JS 문자열용 이스케이프 결과
     */
    function usmEscapeJs(value) {
        return String(usmNvl(value, '')).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
    }

    /**
     * 행 데이터를 URI 인코딩 JSON 문자열로 변환한다.
     * @param {Object} row 인코딩할 행 데이터
     * @returns {string} URI 인코딩된 JSON 문자열
     */
    function usmEncodeRowData(row) {
        return encodeURIComponent(JSON.stringify(row || {}));
    }

    /**
     * URI 인코딩된 행 데이터를 Object로 복원한다.
     * @param {string} encodedRow URI 인코딩된 JSON 문자열
     * @returns {Object} 복원된 행 데이터
     */
    function usmDecodeRowData(encodedRow) {
        try {
            return JSON.parse(decodeURIComponent(encodedRow || '%7B%7D'));
        } catch (e) {
            return {};
        }
    }

    /**
     * 단일 사용자 선택 모달을 연다.
     * @param {string} target 선택 결과를 반영할 대상 구분값(mnpw: 투입인력, schdl: 일정 담당자)
     * @returns {void}
     */
    window.openUserSelectModal = function(target) {
        userSelectTarget = target || '';
        userSelectDeptId = '';
        userDeptExpandedMap = {};
        userMultiSelectedMap = {};
        if (userSelectTarget === 'scheduleMulti' && typeof window.getScheduleSelectedUsers === 'function') {
            window.getScheduleSelectedUsers().forEach(function(user) {
                if (user && user.userId) {
                    userMultiSelectedMap[user.userId] = user;
                }
            });
        }
        $('#userSelectKeyword').val('');
        if (userSelectTarget === 'scheduleMulti') {
            $('#userSelectMultiFooter').removeClass('hidden');
        } else {
            $('#userSelectMultiFooter').addClass('hidden');
        }
        updateUserSelectMultiSummary();
        $('#userSelectModal').removeClass('hidden').attr('aria-hidden', 'false');
        window.loadUserSelectList();
        setTimeout(function() { $('#userSelectKeyword').focus(); }, 50);
    };

    /**
     * 단일 사용자 선택 모달을 닫는다.
     * @returns {void}
     */
    window.closeUserSelectModal = function() {
        $('#userSelectModal').addClass('hidden').attr('aria-hidden', 'true');
    };

    /**
     * 사용자 선택 모달의 부서/사용자 목록을 조회한다.
     * @returns {void}
     */
    window.loadUserSelectList = function() {
        $.ajax({
            url: ctxPath + '/common/userSelectList.ajax',
            type: 'GET',
            dataType: 'json',
            data: {
                deptId: userSelectDeptId,
                searchKeyword: $('#userSelectKeyword').val()
            },
            success: function(res) {
                if (res.result !== 'OK') {
                    $('#userSelectDeptList').html('<div class="ds-empty">조직 조회 권한이 없습니다.</div>');
                    $('#userSelectUserList').html('<div class="ds-empty">사용자 조회 권한이 없습니다.</div>');
                    return;
                }
                userSelectDeptList = res.deptList || [];
                renderUserSelectDeptList(userSelectDeptList);
                renderUserSelectUserList(res.userList || []);
            },
            error: function() {
                $('#userSelectUserList').html('<div class="ds-empty">사용자 조회 중 오류가 발생했습니다.</div>');
            }
        });
    };

    /**
     * 부서ID 기준 자식 부서 목록을 반환한다.
     * @param {string} parentId 상위부서ID. 최상위는 빈 문자열
     * @returns {Array} 자식 부서 목록
     */
    function getUserDeptChildren(parentId) {
        var normalizedParentId = parentId || '';
        return userSelectDeptList.filter(function(dept) {
            if (!normalizedParentId) {
                var deptParentId = usmNvl(dept.upDeptId, '');
                return !deptParentId || !userSelectDeptList.some(function(candidate) {
                    return usmNvl(candidate.deptId, '') === deptParentId;
                });
            }
            return usmNvl(dept.upDeptId, '') === normalizedParentId;
        });
    }

    /**
     * 사용자 선택 모달의 부서 트리를 렌더링한다.
     * @param {Array} deptList 부서 목록
     * @returns {void}
     */
    function renderUserSelectDeptList(deptList) {
        var html = '<button type="button" class="ds-user-dept-item ' + (userSelectDeptId === '' ? 'is-active' : '') + '" onclick="selectUserDept(\'\');">전체</button>'
            + '<button type="button" class="ds-user-dept-item ' + (userSelectDeptId === UNASSIGNED_DEPT_ID ? 'is-active' : '') + '" onclick="selectUserDept(\'' + UNASSIGNED_DEPT_ID + '\');"><span class="ds-user-dept-toggle is-empty"></span><span class="ds-user-dept-name">소속 없음</span></button>';
        if (deptList.length === 0) {
            $('#userSelectDeptList').html(html);
            return;
        }
        html += renderUserDeptNodes('', 0);
        $('#userSelectDeptList').html(html);
    }

    /**
     * 사용자 선택 모달의 부서 트리 노드를 재귀 렌더링한다.
     * @param {string} parentId 상위부서ID
     * @param {number} depth 트리 깊이
     * @returns {string} 렌더링 HTML
     */
    function renderUserDeptNodes(parentId, depth) {
        var html = '';
        getUserDeptChildren(parentId).forEach(function(dept) {
            var deptId = usmNvl(dept.deptId, '');
            var children = getUserDeptChildren(deptId);
            var hasChildren = children.length > 0;
            var expanded = userDeptExpandedMap[deptId] === true;
            var active = userSelectDeptId === deptId;
            var padding = Math.min(depth * 18, 72);
            html += '<div class="ds-user-dept-node">'
                + '<button type="button" class="ds-user-dept-item ' + (active ? 'is-active ' : '') + (hasChildren ? 'has-children' : '') + '" style="--dept-depth:' + padding + 'px" onclick="selectUserDept(\'' + usmEscapeJs(deptId) + '\');">'
                + (hasChildren ? '<span class="ds-user-dept-toggle" onclick="toggleUserDeptNode(event,\'' + usmEscapeJs(deptId) + '\');">' + (expanded ? '▾' : '▸') + '</span>' : '<span class="ds-user-dept-toggle is-empty">' + (depth > 0 ? '└' : '') + '</span>')
                + '<span class="ds-user-dept-name">' + usmEscapeHtml(usmNvl(dept.deptNm, deptId)) + '</span>'
                + '</button>';
            if (hasChildren && expanded) {
                html += renderUserDeptNodes(deptId, depth + 1);
            }
            html += '</div>';
        });
        return html;
    }

    /**
     * 사용자 선택 모달에서 부서 트리 노드를 접거나 펼친다.
     * @param {Event} event 클릭 이벤트
     * @param {string} deptId 부서ID
     * @returns {void}
     */
    window.toggleUserDeptNode = function(event, deptId) {
        if (event) {
            event.preventDefault();
            event.stopPropagation();
        }
        userDeptExpandedMap[deptId] = userDeptExpandedMap[deptId] !== true;
        renderUserSelectDeptList(userSelectDeptList);
    };

    /**
     * 사용자 선택 모달에서 부서를 선택하고 사용자 목록을 다시 조회한다.
     * @param {string} deptId 선택 부서ID
     * @returns {void}
     */
    window.selectUserDept = function(deptId) {
        userSelectDeptId = deptId || '';
        if (userSelectDeptId && getUserDeptChildren(userSelectDeptId).length > 0) {
            userDeptExpandedMap[userSelectDeptId] = true;
        }
        window.loadUserSelectList();
    };

    /**
     * 사용자 선택 모달의 사용자 목록을 렌더링한다.
     * @param {Array} userList 사용자 목록
     * @returns {void}
     */
    function renderUserSelectUserList(userList) {
        if (userList.length === 0) {
            $('#userSelectUserList').html('<div class="ds-empty">조회된 사용자가 없습니다.</div>');
            return;
        }
        var html = '';
        $('#userSelectUserList').data('lastUserList', userList);
        $.each(userList, function(index, user) {
            var selected = userSelectTarget === 'scheduleMulti' && userMultiSelectedMap[user.userId];
            html += '<button type="button" class="ds-user-row ' + (selected ? 'is-selected' : '') + '" aria-pressed="' + (selected ? 'true' : 'false') + '" onclick="applySelectedUserFromEncoded(\'' + usmEncodeRowData(user) + '\');">'
                + '<span><strong>' + usmEscapeHtml(usmNvl(user.userNm, '-')) + '</strong>'
                + '<span>' + usmEscapeHtml(usmNvl(user.deptNm, '소속 없음')) + ' / ' + usmEscapeHtml(usmNvl(user.jbpsNm, '-')) + ' / ' + usmEscapeHtml(usmNvl(user.userId, '-')) + '</span></span>'
                + '<em>' + (selected ? '선택됨' : '선택') + '</em>'
                + '</button>';
        });
        $('#userSelectUserList').html(html);
    }

    /**
     * 인코딩된 사용자 행 데이터를 복원해 현재 대상 입력폼에 반영한다.
     * @param {string} encodedUser URI 인코딩된 사용자 JSON 문자열
     * @returns {void}
     */
    window.applySelectedUserFromEncoded = function(encodedUser) {
        window.applySelectedUser(usmDecodeRowData(encodedUser));
    };

    /**
     * 선택한 사용자를 투입인력 또는 일정 담당자 입력폼에 반영한다.
     * @param {Object} user 사용자ID, 사용자명, 직위명, 부서명을 포함한 사용자 데이터
     * @returns {void}
     */
    window.applySelectedUser = function(user) {
        if (userSelectTarget === 'scheduleMulti') {
            var userId = usmNvl(user.userId, '');
            if (userId) {
                if (userMultiSelectedMap[userId]) {
                    delete userMultiSelectedMap[userId];
                } else {
                    userMultiSelectedMap[userId] = user;
                }
                updateUserSelectMultiSummary();
                renderUserSelectUserList($('#userSelectUserList').data('lastUserList') || []);
            }
            return;
        }
        if (userSelectTarget === 'mnpw') {
            $('#frmUserId').val(usmNvl(user.userId, ''));
            $('#frmUserDispNm').val(usmNvl(user.userNm, ''));
            $('#frmInputMnpwNm').val(usmNvl(user.userNm, ''));
            if (!$('#frmJbpsNm').val()) {
                $('#frmJbpsNm').val(usmNvl(user.jbpsNm, ''));
            }
        } else if (userSelectTarget === 'schdl') {
            $('#frmPicId').val(usmNvl(user.userId, ''));
            $('#frmPicDispNm').val(usmNvl(user.userNm, ''));
        } else if (userSelectTarget === 'orgManager') {
            $('#orgMngrUserId').val(usmNvl(user.userId, ''));
            $('#orgMngrUserNm').val(usmNvl(user.userNm, ''));
        }
        window.closeUserSelectModal();
    };

    /**
     * 다중 사용자 선택 상태 요약을 갱신한다.
     * @returns {void}
     */
    function updateUserSelectMultiSummary() {
        var count = Object.keys(userMultiSelectedMap).length;
        $('#userSelectMultiSummary').text('선택된 사용자 ' + count + '명');
    }

    /**
     * 다중 선택된 사용자를 호출 화면에 반영한다.
     * @returns {void}
     */
    window.applyMultiSelectedUsers = function() {
        if (typeof window.setScheduleSelectedUsers === 'function') {
            window.setScheduleSelectedUsers(Object.keys(userMultiSelectedMap).map(function(key) { return userMultiSelectedMap[key]; }));
        }
        window.closeUserSelectModal();
    };

    $(document).on('keydown', '#userSelectKeyword', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            window.loadUserSelectList();
        }
    });
})(window, jQuery);
