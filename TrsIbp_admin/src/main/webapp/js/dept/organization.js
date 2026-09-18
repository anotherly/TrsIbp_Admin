/**
 * 회사 관리 > 조직 관리
 * 단일 조직도에서 접기/펼치기, 하위 조직 추가, 상세 모달 CRUD를 처리한다.
 */
(function (window, $) {
    'use strict';

    var COMPANY_ID = '__COMPANY__';
    var typeLabels = { COMPANY: '회사', HQ: '본부', DEPT: '부서', TEAM: '팀' };
    var managerLabels = { HQ: '본부장', DEPT: '부서장', TEAM: '팀장' };
    var organizations = [], members = [], summary = {}, expanded = {};
    var selectedId = COMPANY_ID, detailId = null, modalParentId = COMPANY_ID, toastTimer = null;

    window.initOrganizationPage = function () {
        bindEvents();
        loadOrganizationData();
    };

    function contextPath() { return window.dsContextPath || ''; }

    function bindEvents() {
        $('#orgAddBtn').on('click', function () { openAddModal(COMPANY_ID, true); });
        $('#orgResetViewBtn').on('click', resetView);
        $('#orgExpandBtn').on('click', toggleAll);
        $('#orgKeyword').on('input', renderChart);
        $(window).on('resize', scheduleCompanyLines);
        $('#orgDeptSeCd').on('change', function () {
            fillParentOptions(this.value, modalParentId);
            updateManagerLabel(this.value);
        });
        $('#orgDeptId').on('input', function () { this.value = this.value.toUpperCase().replace(/[^A-Z0-9-]/g, ''); });
        $('#orgModalCloseBtn, #orgModalCancelBtn').on('click', closeEditModal);
        $('[data-org-detail-close]').on('click', closeDetailModal);
        $('#orgSaveBtn').on('click', saveOrganization);
        $('#orgManagerSelectBtn').on('click', function () { openUserSelectModal('orgManager'); });
        $('#orgManagerClearBtn').on('click', clearManager);
        $('#orgDetailEditBtn').on('click', function () {
            var editingId = detailId;
            if (!editingId) return;
            closeDetailModal();
            openEditModal(editingId);
        });
        $('#orgDetailDeleteBtn').on('click', function () { if (detailId) deleteOrganization(detailId); });

        $(document).on('click', '[data-org-card]', function (event) {
            if ($(event.target).closest('[data-org-add],[data-org-detail],[data-org-toggle]').length) return;
            toggleNode($(this).attr('data-org-card'));
        });
        $(document).on('click', '[data-org-toggle]', function (event) {
            event.stopPropagation();
            toggleNode($(this).attr('data-org-toggle'));
        });
        $(document).on('click', '[data-org-add]', function (event) {
            event.stopPropagation();
            openAddModal($(this).attr('data-org-add'), false);
        });
        $(document).on('click', '[data-org-detail]', function (event) {
            event.stopPropagation();
            openDetailModal($(this).attr('data-org-detail'));
        });
        $(document).on('keydown', function (event) {
            if (event.key !== 'Escape') return;
            if (!$('#orgEditModal').hasClass('hidden')) closeEditModal();
            else if (!$('#orgDetailModal').hasClass('hidden')) closeDetailModal();
        });
    }

    function loadOrganizationData(preferredId) {
        $.ajax({
            url: contextPath() + '/dept/organizationData.ajax', type: 'GET', dataType: 'json',
            success: function (response) {
                if (response.result !== 'OK') { showToast(response.msg || '조직 정보를 불러오지 못했습니다.', true); return; }
                summary = response.summary || {};
                organizations = response.organizationList || [];
                members = response.memberList || [];
                organizations.forEach(function (item) {
                    item.sortDeptSeq = numberValue(item.sortDeptSeq);
                    item.memberCnt = numberValue(item.memberCnt);
                    item.deptSeCd = item.deptSeCd || (item.upDeptId ? 'TEAM' : 'HQ');
                    if (expanded[item.deptId] == null) expanded[item.deptId] = true;
                });
                organizations.sort(compareOrganizations);
                applyRollupMemberCounts();
                expanded[COMPANY_ID] = expanded[COMPANY_ID] !== false;
                selectedId = preferredId && findOrganization(preferredId) ? preferredId : selectedId;
                renderSummary();
                renderChart();
            },
            error: function () { showToast('조직 정보 조회 중 오류가 발생했습니다.', true); }
        });
    }

    function renderSummary() {
        $('#orgCompanyName').text(summaryValue('coNm') || '-');
        $('#orgCount').text(numberValue(summaryValue('orgCnt')));
        $('#orgMemberCount').text(numberValue(summaryValue('memberCnt')) + '명');
        $('#orgUnassignedCount').text(numberValue(summaryValue('unassignedCnt')) + '명');
    }

    function renderChart() {
        var keyword = $.trim($('#orgKeyword').val()).toLowerCase();
        var company = companyNode();
        var topNodes = childrenOf(COMPANY_ID).filter(function (node) { return nodeVisible(node, keyword); });
        var branches = topNodes.map(function (node) {
            return '<section class="ds-org-branch">' + chartCard(node) + chartChildren(node, keyword) + '</section>';
        }).join('');
        var rootOpen = keyword || expanded[COMPANY_ID] !== false;
        $('#orgChart').html('<svg class="ds-org-company-lines" aria-hidden="true"></svg>'
            + '<div class="ds-org-root-wrap">' + chartCard(company) + '</div>'
            + (topNodes.length && rootOpen
                ? '<div class="ds-org-branches">' + branches + '</div>'
                : (!topNodes.length && !keyword ? '<div class="ds-empty ds-org-chart-empty">등록된 조직이 없습니다. 상단의 조직 추가 버튼으로 시작해 주세요.</div>' : '')));
        updateExpandButton();
        scheduleCompanyLines();
    }

    function scheduleCompanyLines() {
        window.clearTimeout(scheduleCompanyLines.timer);
        scheduleCompanyLines.timer = window.setTimeout(drawCompanyLines, 20);
    }

    function drawCompanyLines() {
        var chart = document.getElementById('orgChart');
        if (!chart) return;
        var svg = chart.querySelector('.ds-org-company-lines');
        var root = chart.querySelector('.ds-org-root-card');
        var branches = Array.prototype.slice.call(chart.querySelectorAll('.ds-org-branch'));
        if (!svg || !root || !branches.length) {
            if (svg) svg.innerHTML = '';
            return;
        }

        var chartRect = chart.getBoundingClientRect();
        var rootRect = root.getBoundingClientRect();
        var startX = rootRect.left + rootRect.width / 2 - chartRect.left;
        var startY = rootRect.bottom - chartRect.top;
        var rows = [];

        branches.forEach(function (branch) {
            var card = branch.querySelector(':scope > .ds-org-node-card');
            if (!card) return;
            var rect = card.getBoundingClientRect();
            var top = Math.round(rect.top - chartRect.top);
            var row = null;
            for (var i = 0; i < rows.length; i++) {
                if (Math.abs(rows[i].top - top) < 4) { row = rows[i]; break; }
            }
            if (!row) { row = { top: top, points: [] }; rows.push(row); }
            row.points.push({ x: rect.left + rect.width / 2 - chartRect.left, y: rect.top - chartRect.top });
        });

        rows.sort(function (a, b) { return a.top - b.top; });
        svg.setAttribute('viewBox', '0 0 ' + chart.scrollWidth + ' ' + chart.scrollHeight);
        svg.setAttribute('width', chart.scrollWidth);
        svg.setAttribute('height', chart.scrollHeight);
        svg.innerHTML = '';

        rows.forEach(function (row, rowIndex) {
            row.points.sort(function (a, b) { return a.x - b.x; });
            var first = row.points[0], last = row.points[row.points.length - 1];
            var busY = row.top - 24;
            var pathData;
            if (rowIndex === 0) {
                pathData = 'M ' + startX + ' ' + startY + ' V ' + busY
                    + ' M ' + first.x + ' ' + busY + ' H ' + last.x;
            } else {
                var gutterX = 18 + ((rowIndex - 1) * 9);
                var departY = startY + 14 + ((rowIndex - 1) * 7);
                pathData = 'M ' + startX + ' ' + startY + ' V ' + departY
                    + ' H ' + gutterX + ' V ' + busY + ' H ' + last.x;
            }
            row.points.forEach(function (point) {
                pathData += ' M ' + point.x + ' ' + busY + ' V ' + point.y;
            });
            var path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            path.setAttribute('d', pathData);
            svg.appendChild(path);
        });
    }

    function chartChildren(node, keyword) {
        var children = childrenOf(node.deptId).filter(function (child) { return nodeVisible(child, keyword); });
        if (!children.length || (!keyword && expanded[node.deptId] === false)) return '';
        return '<div class="ds-org-chart-children">' + children.map(function (child) {
            return '<div class="ds-org-chart-child">' + chartCard(child) + chartChildren(child, keyword) + '</div>';
        }).join('') + '</div>';
    }

    function chartCard(node) {
        var children = childrenOf(node.deptId);
        var canAdd = node.deptSeCd !== 'TEAM';
        var leader = node.deptSeCd === 'COMPANY' ? '회사 조직도' : (node.mngrUserNm || (managerLabels[node.deptSeCd] || '조직장') + ' 미지정');
        var open = expanded[node.deptId] !== false;
        return '<article class="ds-org-node-card ds-org-node-' + String(node.deptSeCd || 'TEAM').toLowerCase() + (node.deptSeCd === 'COMPANY' ? ' ds-org-root-card' : '') + (selectedId === node.deptId ? ' is-selected' : '') + '" data-org-card="' + attr(node.deptId) + '">'
            + '<span class="ds-org-type-badge">' + html(typeLabels[node.deptSeCd] || '조직') + '</span>'
            + '<strong>' + html(node.deptNm) + '</strong><small>' + html(leader) + ' · ' + numberValue(node.memberCnt) + '명</small>'
            + '<span class="ds-org-card-actions">'
            + (canAdd ? '<button type="button" class="ds-org-card-btn" data-org-add="' + attr(node.deptId) + '" title="하위 조직 추가"><i class="fa-solid fa-plus"></i></button>' : '')
            + (children.length ? '<button type="button" class="ds-org-card-btn is-toggle" data-org-toggle="' + attr(node.deptId) + '" aria-expanded="' + open + '" title="하위 조직 접기/펼치기"><i class="fa-solid fa-chevron-down"></i></button>' : '')
            + '</span>'
            + (node.deptSeCd !== 'COMPANY' ? '<button type="button" class="ds-org-card-detail" data-org-detail="' + attr(node.deptId) + '">상세 <i class="fa-solid fa-chevron-right"></i></button>' : '')
            + '</article>';
    }

    function nodeVisible(node, keyword) {
        if (!keyword) return true;
        if (String(node.deptNm || '').toLowerCase().indexOf(keyword) >= 0 || String(node.deptId || '').toLowerCase().indexOf(keyword) >= 0) return true;
        return childrenOf(node.deptId).some(function (child) { return nodeVisible(child, keyword); });
    }

    function toggleNode(id) {
        if (!childrenOf(id).length) return;
        selectedId = id;
        expanded[id] = expanded[id] === false;
        renderChart();
    }

    function toggleAll() {
        var allOpen = expanded[COMPANY_ID] !== false && organizations.every(function (item) { return expanded[item.deptId] !== false; });
        expanded[COMPANY_ID] = !allOpen;
        organizations.forEach(function (item) { expanded[item.deptId] = !allOpen; });
        selectedId = COMPANY_ID;
        renderChart();
    }

    function resetView() {
        $('#orgKeyword').val('');
        expanded[COMPANY_ID] = true;
        organizations.forEach(function (item) { expanded[item.deptId] = true; });
        selectedId = COMPANY_ID;
        renderChart();
        $('.ds-org-chart-scroll').scrollTop(0).scrollLeft(0);
    }

    function updateExpandButton() {
        var allOpen = expanded[COMPANY_ID] !== false && organizations.every(function (item) { return expanded[item.deptId] !== false; });
        $('#orgExpandBtn').text(allOpen ? '전체 접기' : '전체 펼치기');
    }

    function openDetailModal(id) {
        var node = findOrganization(id);
        if (!node) return;
        detailId = id;
        selectedId = id;
        renderChart();
        renderDetailModal(node);
        $('#orgDetailModal').removeClass('hidden').attr('aria-hidden', 'false');
    }

    function renderDetailModal(node) {
        var nodeMembers = members.filter(function (member) { return member.deptId === node.deptId; });
        var parent = node.upDeptId ? findOrganization(node.upDeptId) : companyNode();
        var memberHtml = nodeMembers.length ? nodeMembers.map(function (member) {
            var manager = node.mngrUserId && node.mngrUserId === member.userId;
            return '<div class="ds-org-member"><span class="ds-org-member-avatar">' + html(String(member.userNm || '?').substring(0, 1)) + '</span>'
                + '<div><strong>' + html(member.userNm || member.userId) + '</strong><small>' + html(member.jbpsNm || '직위 미지정') + '</small></div>'
                + (manager ? '<em>' + html(managerLabels[node.deptSeCd] || '조직장') + '</em>' : '') + '</div>';
        }).join('') : '<div class="ds-empty ds-org-member-empty">소속 사용자가 없습니다.</div>';
        $('#orgDetailModalTitle').text(typeLabels[node.deptSeCd] + ' 상세');
        $('#orgDetailModalBody').html('<div class="ds-org-detail-title"><span class="ds-org-type-badge">' + html(typeLabels[node.deptSeCd]) + '</span><h3>' + html(node.deptNm) + '</h3><p>' + html(node.deptExpln || '등록된 조직 설명이 없습니다.') + '</p></div>'
            + '<dl class="ds-org-kv"><dt>조직 코드</dt><dd>' + html(node.deptId) + '</dd><dt>상위 조직</dt><dd>' + html(parent ? parent.deptNm : '-') + '</dd>'
            + '<dt>전체 경로</dt><dd>' + html(organizationPath(node)) + '</dd><dt>' + html(managerLabels[node.deptSeCd] || '조직장') + '</dt><dd>' + html(node.mngrUserNm || '미지정') + '</dd><dt>사용 여부</dt><dd class="is-use">사용</dd></dl>'
            + '<div class="ds-org-member-head"><span>소속 구성원</span><b>' + nodeMembers.length + '명</b></div><div class="ds-org-members">' + memberHtml + '</div>'
            + '<p class="ds-org-detail-hint">저장한 내용은 사용자 등록·수정 화면의 <b>부서 선택</b> 모달에 바로 반영됩니다.</p>');
    }

    function closeDetailModal() {
        $('#orgDetailModal').addClass('hidden').attr('aria-hidden', 'true');
        detailId = null;
    }

    function openAddModal(parentId, globalAdd) {
        var parent = parentId === COMPANY_ID ? companyNode() : findOrganization(parentId);
        if (!parent) parent = companyNode();
        var allowed = allowedChildTypes(parent.deptSeCd);
        if (!allowed.length) { showToast('팀 아래에는 하위 조직을 추가할 수 없습니다.', true); return; }
        modalParentId = parent.deptId;
        $('#orgForm')[0].reset();
        $('#orgFormMode').val('insert');
        $('#orgModalTitle').text(globalAdd ? '조직 추가' : '하위 조직 추가');
        $('#orgModalDesc').text(globalAdd ? '조직 구분과 상위 조직을 선택해 등록합니다.' : parent.deptNm + ' 아래에 새 조직을 등록합니다.');
        setTypeOptions(globalAdd ? ['HQ', 'DEPT', 'TEAM'] : allowed);
        var type = globalAdd ? 'HQ' : allowed[0];
        $('#orgDeptSeCd').val(type).prop('disabled', false);
        updateManagerLabel(type);
        $('#orgDeptId').prop('readonly', false);
        fillParentOptions(type, globalAdd ? COMPANY_ID : parent.deptId);
        $('#orgSortDeptSeq').val(childrenOf(parent.deptId).length + 1);
        setManager('', '');
        openEditForm();
    }

    function openEditModal(id) {
        var node = findOrganization(id);
        if (!node) return;
        modalParentId = node.upDeptId || COMPANY_ID;
        $('#orgForm')[0].reset();
        $('#orgFormMode').val('update');
        $('#orgModalTitle').text('조직 수정');
        $('#orgModalDesc').text('조직명, 상위 조직, 조직장 등 기본정보를 수정합니다.');
        setTypeOptions([node.deptSeCd]);
        $('#orgDeptSeCd').val(node.deptSeCd).prop('disabled', true);
        updateManagerLabel(node.deptSeCd);
        fillParentOptions(node.deptSeCd, node.upDeptId || COMPANY_ID, node.deptId);
        $('#orgDeptId').val(node.deptId).prop('readonly', true);
        $('#orgDeptNm').val(node.deptNm);
        $('#orgSortDeptSeq').val(node.sortDeptSeq);
        $('#orgDeptExpln').val(node.deptExpln || '');
        setManager(node.mngrUserId || '', node.mngrUserNm || '');
        openEditForm();
    }

    function setTypeOptions(allowed) {
        $('#orgDeptSeCd option').each(function () { this.disabled = allowed.indexOf(this.value) < 0; });
    }

    function fillParentOptions(type, preferredId, editingId) {
        var options = [];
        if (type === 'HQ' || type === 'DEPT') options.push(companyNode());
        organizations.forEach(function (item) {
            if (item.deptId === editingId) return;
            if (type === 'DEPT' && item.deptSeCd === 'HQ') options.push(item);
            if (type === 'TEAM' && item.deptSeCd === 'DEPT') options.push(item);
        });
        $('#orgUpDeptId').html(options.map(function (item) {
            return '<option value="' + attr(item.deptId === COMPANY_ID ? '' : item.deptId) + '">' + html(organizationPath(item)) + '</option>';
        }).join(''));
        $('#orgUpDeptId').val(preferredId === COMPANY_ID ? '' : preferredId);
        modalParentId = preferredId || COMPANY_ID;
    }

    function updateManagerLabel(type) {
        $('#orgMngrLabel').text(managerLabels[type] || '조직장');
    }

    function setManager(userId, userNm) {
        $('#orgMngrUserId').val(userId || '');
        $('#orgMngrUserNm').val(userNm || '');
    }

    function clearManager() {
        setManager('', '');
    }

    function saveOrganization() {
        var mode = $('#orgFormMode').val();
        var data = { deptId: $.trim($('#orgDeptId').val()).toUpperCase(), deptNm: $.trim($('#orgDeptNm').val()), deptSeCd: $('#orgDeptSeCd').val(), upDeptId: $('#orgUpDeptId').val(), mngrUserId: $('#orgMngrUserId').val(), sortDeptSeq: $('#orgSortDeptSeq').val() || 0, deptExpln: $.trim($('#orgDeptExpln').val()) };
        if (!/^[A-Z0-9-]{2,20}$/.test(data.deptId)) { showToast('조직 코드는 영문 대문자, 숫자, 하이픈 2~20자로 입력해 주세요.', true); $('#orgDeptId').focus(); return; }
        if (!data.deptNm) { showToast('조직명을 입력해 주세요.', true); $('#orgDeptNm').focus(); return; }
        $('#orgSaveBtn').prop('disabled', true);
        $.ajax({
            url: contextPath() + (mode === 'insert' ? '/dept/insertDept.ajax' : '/dept/updateDept.ajax'), type: 'POST', dataType: 'json', data: data,
            success: function (response) {
                if (response.result !== 'OK') { showToast(response.msg || '조직 저장에 실패했습니다.', true); return; }
                closeEditModal(); showToast(mode === 'insert' ? '조직을 등록했습니다.' : '조직 정보를 수정했습니다.');
                loadOrganizationData(data.deptId);
            },
            error: function () { showToast('조직 저장 중 오류가 발생했습니다.', true); },
            complete: function () { $('#orgSaveBtn').prop('disabled', false); }
        });
    }

    function deleteOrganization(id) {
        var node = findOrganization(id);
        if (!node) return;
        var deleteIds = descendantIds(id);
        var affectedMemberCnt = members.filter(function (member) {
            return deleteIds.indexOf(member.deptId) >= 0;
        }).length;
        var childCnt = deleteIds.length - 1;
        var messages = [];
        if (affectedMemberCnt > 0) {
            messages.push('해당 조직과 하위 조직에 소속된 사용자 ' + affectedMemberCnt + '명은 소속 없음으로 변경됩니다.');
        }
        if (childCnt > 0) {
            messages.push('하위 조직 ' + childCnt + '개도 함께 삭제됩니다.');
        }
        messages.push(node.deptNm + ' 조직을 삭제하시겠습니까?');
        if (!window.confirm(messages.join('\n\n'))) return;
        $.ajax({
            url: contextPath() + '/dept/deleteDept.ajax', type: 'POST', dataType: 'json', data: { deptId: id },
            success: function (response) {
                if (response.result !== 'OK') { showToast(response.msg || '조직 삭제에 실패했습니다.', true); return; }
                closeDetailModal(); selectedId = node.upDeptId || COMPANY_ID; showToast('조직을 삭제했습니다.'); loadOrganizationData(selectedId);
            },
            error: function () { showToast('조직 삭제 중 오류가 발생했습니다.', true); }
        });
    }

    function openEditForm() { $('#orgEditModal').removeClass('hidden').attr('aria-hidden', 'false'); window.setTimeout(function () { $('#orgDeptNm').focus(); }, 30); }
    function closeEditModal() { $('#orgEditModal').addClass('hidden').attr('aria-hidden', 'true'); $('#orgDeptSeCd').prop('disabled', false); }
    function companyNode() { return { deptId: COMPANY_ID, deptNm: summaryValue('coNm') || '회사', deptSeCd: 'COMPANY', memberCnt: numberValue(summaryValue('memberCnt')) }; }
    function findOrganization(id) { for (var i = 0; i < organizations.length; i++) if (organizations[i].deptId === id) return organizations[i]; return null; }
    function childrenOf(parentId) { return organizations.filter(function (item) { return parentId === COMPANY_ID ? !item.upDeptId : item.upDeptId === parentId; }).sort(compareOrganizations); }
    function descendantIds(id) {
        var result = [id];
        for (var i = 0; i < result.length; i++) {
            childrenOf(result[i]).forEach(function (child) {
                if (result.indexOf(child.deptId) < 0) result.push(child.deptId);
            });
        }
        return result;
    }
    function applyRollupMemberCounts() {
        organizations.forEach(function (organization) {
            var ids = descendantIds(organization.deptId);
            organization.memberCnt = members.filter(function (member) {
                return ids.indexOf(member.deptId) >= 0;
            }).length;
        });
    }
    function compareOrganizations(a, b) { return numberValue(a.sortDeptSeq) - numberValue(b.sortDeptSeq) || String(a.deptNm || '').localeCompare(String(b.deptNm || ''), 'ko'); }
    function allowedChildTypes(type) { return type === 'COMPANY' ? ['HQ', 'DEPT'] : type === 'HQ' ? ['DEPT'] : type === 'DEPT' ? ['TEAM'] : []; }
    function organizationPath(node) {
        var names = [], current = node, guard = 0;
        while (current && guard++ < 10) { names.unshift(current.deptNm); if (current.deptSeCd === 'COMPANY') break; current = current.upDeptId ? findOrganization(current.upDeptId) : companyNode(); }
        return names.join(' > ');
    }
    function summaryValue(key) { if (summary[key] != null) return summary[key]; var upper = key.toUpperCase(); return summary[upper] != null ? summary[upper] : null; }
    function numberValue(value) { var n = Number(value); return isNaN(n) ? 0 : n; }
    function html(value) { return String(value == null ? '' : value).replace(/[&<>"']/g, function (c) { return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]; }); }
    function attr(value) { return html(value); }
    function showToast(message, error) {
        var toast = $('#orgToast');
        toast.toggleClass('is-error', !!error).find('span').text(message);
        toast.addClass('is-show'); window.clearTimeout(toastTimer);
        toastTimer = window.setTimeout(function () { toast.removeClass('is-show'); }, 3600);
    }
})(window, window.jQuery);
