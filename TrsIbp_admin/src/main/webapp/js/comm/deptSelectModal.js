/* =========================================================
 * 공통 단일 부서 선택 모달
 * - 좌측에는 상위 조직 트리, 우측에는 선택한 조직 하위의 최하위 부서를 표시한다.
 * - 사용자 등록/수정, 회원가입 등 부서 1개를 선택하는 화면에서 재사용한다.
 * ========================================================= */
(function(window, $) {
    'use strict';

    var deptSelectOptions = {};
    var deptSelectList = [];
    var deptSelectActiveId = '';
    var deptExpandedMap = {};

    /**
     * null/undefined 값을 기본 문자열로 치환한다.
     * @param {*} value 검사할 값
     * @param {string} defaultValue 값이 없을 때 반환할 기본값
     * @returns {string} 치환된 문자열
     */
    function dsmNvl(value, defaultValue) {
        return value === null || value === undefined || value === '' ? (defaultValue || '') : value;
    }

    /**
     * HTML 출력용 문자열을 이스케이프한다.
     * @param {*} value 이스케이프할 값
     * @returns {string} HTML 특수문자가 변환된 문자열
     */
    function dsmEscapeHtml(value) {
        return String(dsmNvl(value, ''))
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
    function dsmEscapeJs(value) {
        return String(dsmNvl(value, '')).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
    }

    /**
     * 부서 행 데이터를 URI 인코딩 JSON 문자열로 변환한다.
     * @param {Object} row 부서 데이터
     * @returns {string} URI 인코딩된 JSON 문자열
     */
    function dsmEncodeRowData(row) {
        return encodeURIComponent(JSON.stringify(row || {}));
    }

    /**
     * URI 인코딩된 부서 행 데이터를 복원한다.
     * @param {string} encodedRow URI 인코딩된 JSON 문자열
     * @returns {Object} 복원된 부서 데이터
     */
    function dsmDecodeRowData(encodedRow) {
        try {
            return JSON.parse(decodeURIComponent(encodedRow || '%7B%7D'));
        } catch (e) {
            return {};
        }
    }

    /**
     * 공통 부서 선택 모달을 연다.
     * @param {Object} options 선택 결과 반영 대상과 조회 URL 정보
     * @returns {void}
     */
    window.openDeptSelectModal = function(options) {
        deptSelectOptions = options || {};
        deptSelectActiveId = '';
        deptExpandedMap = {};
        $('#deptSelectKeyword').val('');
        $('#deptSelectModal').removeClass('hidden').attr('aria-hidden', 'false');
        window.loadDeptSelectList();
        setTimeout(function() { $('#deptSelectKeyword').focus(); }, 50);
    };

    /**
     * 공통 부서 선택 모달을 닫는다.
     * @returns {void}
     */
    window.closeDeptSelectModal = function() {
        $('#deptSelectModal').addClass('hidden').attr('aria-hidden', 'true');
    };

    /**
     * 부서 선택 모달의 부서 목록을 조회한다.
     * @returns {void}
     */
    window.loadDeptSelectList = function() {
        var requestUrl = deptSelectOptions.url || ((window.ctxPath || '') + '/common/deptSelectList.ajax');
        var data = { searchKeyword: $('#deptSelectKeyword').val() };
        if (deptSelectOptions.coId) {
            data.coId = typeof deptSelectOptions.coId === 'function' ? deptSelectOptions.coId() : deptSelectOptions.coId;
        }
        $.ajax({
            url: requestUrl,
            type: deptSelectOptions.type || 'GET',
            dataType: 'json',
            data: data,
            success: function(res) {
                var list = res.deptList || res.list || [];
                deptSelectList = list;
                deptSelectActiveId = '';
                renderDeptSelectTreeList();
                renderDeptSelectLeafList('');
            },
            error: function() {
                $('#deptSelectTreeList').html('<div class="ds-empty">부서 조회 중 오류가 발생했습니다.</div>');
                $('#deptSelectLeafList').html('<div class="ds-empty">부서 조회 중 오류가 발생했습니다.</div>');
            }
        });
    };

    /**
     * 상위부서ID 기준 자식 부서 목록을 반환한다.
     * @param {string} parentId 상위부서ID. 최상위는 빈 문자열
     * @returns {Array} 자식 부서 목록
     */
    function getDeptChildren(parentId) {
        var normalizedParentId = parentId || '';
        return deptSelectList.filter(function(dept) {
            return dsmNvl(dept.upDeptId, '') === normalizedParentId;
        });
    }

    /**
     * 특정 조직 하위에서 사용자 소속으로 지정 가능한 부서·팀 목록을 반환한다.
     * @param {string} parentId 기준 조직ID. 빈 값이면 전체 조직
     * @returns {Array} 선택 가능한 부서·팀 목록
     */
    function getLeafDepts(parentId) {
        var roots = parentId ? deptSelectList.filter(function(dept) { return dsmNvl(dept.deptId, '') === parentId; }) : deptSelectList.filter(function(dept) { return dsmNvl(dept.upDeptId, '') === ''; });
        var leaves = [];
        var keyword = ($('#deptSelectKeyword').val() || '').toLowerCase();
        function collect(node) {
            var children = getDeptChildren(dsmNvl(node.deptId, ''));
            var type = dsmNvl(node.deptSeCd, '');
            var selectable = type ? (type === 'DEPT' || type === 'TEAM') : children.length === 0;
            if (selectable) {
                var deptName = dsmNvl(node.deptNm, '').toLowerCase();
                var deptPath = buildDeptPath(node).toLowerCase();
                if (!keyword || deptName.indexOf(keyword) > -1 || deptPath.indexOf(keyword) > -1) {
                    leaves.push(node);
                }
            }
            children.forEach(collect);
        }
        roots.forEach(collect);
        return leaves;
    }

    /**
     * 부서 선택 모달 좌측 조직 트리를 렌더링한다.
     * @returns {void}
     */
    function renderDeptSelectTreeList() {
        if (deptSelectList.length === 0) {
            $('#deptSelectTreeList').html('<div class="ds-empty">조회된 부서가 없습니다.</div>');
            $('#deptSelectLeafList').html('<div class="ds-empty">조회된 부서가 없습니다.</div>');
            return;
        }
        $('#deptSelectTreeList').html(renderDeptNodes('', 0));
    }

    /**
     * 부서 선택 모달 좌측 조직 트리 노드를 재귀 렌더링한다.
     * @param {string} parentId 상위부서ID
     * @param {number} depth 트리 깊이
     * @returns {string} 렌더링 HTML
     */
    function renderDeptNodes(parentId, depth) {
        var html = '';
        getDeptChildren(parentId).forEach(function(dept) {
            var deptId = dsmNvl(dept.deptId, '');
            var children = getDeptChildren(deptId);
            var hasChildren = children.length > 0;
            var expanded = deptExpandedMap[deptId] === true;
            var active = deptSelectActiveId === deptId;
            var padding = Math.min(depth * 18, 72);
            html += '<div class="ds-user-dept-node">'
                + '<button type="button" class="ds-user-dept-item ' + (active ? 'is-active ' : '') + (hasChildren ? 'has-children' : '') + '" style="--dept-depth:' + padding + 'px" onclick="selectDeptBranch(\'' + dsmEscapeJs(deptId) + '\');">'
                + (hasChildren ? '<span class="ds-user-dept-toggle" onclick="toggleDeptSelectNode(event,\'' + dsmEscapeJs(deptId) + '\');">' + (expanded ? '▾' : '▸') + '</span>' : '<span class="ds-user-dept-toggle is-empty">└</span>')
                + '<span class="ds-user-dept-name">' + dsmEscapeHtml(dsmNvl(dept.deptNm, deptId)) + '</span>'
                + '</button>';
            if (hasChildren && expanded) {
                html += renderDeptNodes(deptId, depth + 1);
            }
            html += '</div>';
        });
        return html;
    }

    /**
     * 부서 선택 모달 좌측 트리 노드를 접거나 펼친다.
     * @param {Event} event 클릭 이벤트
     * @param {string} deptId 부서ID
     * @returns {void}
     */
    window.toggleDeptSelectNode = function(event, deptId) {
        if (event) {
            event.preventDefault();
            event.stopPropagation();
        }
        deptExpandedMap[deptId] = deptExpandedMap[deptId] !== true;
        renderDeptSelectTreeList();
    };

    /**
     * 좌측 조직을 선택하고 우측 최하위 부서 목록을 갱신한다.
     * @param {string} deptId 기준 부서ID
     * @returns {void}
     */
    window.selectDeptBranch = function(deptId) {
        deptSelectActiveId = deptId || '';
        if (deptSelectActiveId && getDeptChildren(deptSelectActiveId).length > 0) {
            deptExpandedMap[deptSelectActiveId] = true;
        }
        renderDeptSelectTreeList();
        renderDeptSelectLeafList(deptSelectActiveId);
    };

    /**
     * 부서 선택 모달 우측 최하위 부서 목록을 렌더링한다.
     * @param {string} parentId 기준 부서ID
     * @returns {void}
     */
    function renderDeptSelectLeafList(parentId) {
        var leafList = getLeafDepts(parentId);
        if (leafList.length === 0) {
            $('#deptSelectLeafList').html('<div class="ds-empty">선택 가능한 하위 부서가 없습니다.</div>');
            return;
        }
        var html = '';
        leafList.forEach(function(dept) {
            html += '<button type="button" class="ds-user-row" onclick="applySelectedDeptFromEncoded(\'' + dsmEncodeRowData(dept) + '\');">'
                + '<span><strong>' + dsmEscapeHtml(dsmNvl(dept.deptNm, '-')) + '</strong>'
                + '<span>' + dsmEscapeHtml(buildDeptPath(dept)) + '</span></span>'
                + '<em>선택</em>'
                + '</button>';
        });
        $('#deptSelectLeafList').html(html);
    }

    /**
     * 부서ID 기준 부서 객체를 조회한다.
     * @param {string} deptId 부서ID
     * @returns {Object|null} 부서 객체
     */
    function findDept(deptId) {
        for (var i = 0; i < deptSelectList.length; i++) {
            if (dsmNvl(deptSelectList[i].deptId, '') === deptId) {
                return deptSelectList[i];
            }
        }
        return null;
    }

    /**
     * 부서의 전체 경로명을 만든다.
     * @param {Object} dept 기준 부서
     * @returns {string} 부서 경로명
     */
    function buildDeptPath(dept) {
        var names = [];
        var current = dept;
        var guard = 0;
        while (current && guard < 20) {
            names.unshift(dsmNvl(current.deptNm, current.deptId));
            current = findDept(dsmNvl(current.upDeptId, ''));
            guard++;
        }
        return names.join(' > ');
    }

    /**
     * 인코딩된 부서 행 데이터를 복원해 현재 대상 입력폼에 반영한다.
     * @param {string} encodedDept URI 인코딩된 부서 JSON 문자열
     * @returns {void}
     */
    window.applySelectedDeptFromEncoded = function(encodedDept) {
        var dept = dsmDecodeRowData(encodedDept);
        var deptId = dsmNvl(dept.deptId, '');
        var deptPath = buildDeptPath(dept);
        $(deptSelectOptions.targetId || '#deptId').val(deptId);
        $(deptSelectOptions.targetName || '#deptNm').val(deptPath);
        if (typeof deptSelectOptions.onSelect === 'function') {
            deptSelectOptions.onSelect(dept);
        }
        window.closeDeptSelectModal();
    };

    $(document).on('keydown', '#deptSelectKeyword', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            window.loadDeptSelectList();
        }
    });
})(window, jQuery);
