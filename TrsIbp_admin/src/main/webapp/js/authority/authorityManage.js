(function($) {
    'use strict';

    var state = {
        authorityList: [],
        menuList: [],
        selectedAuthrtId: ''
    };

    $(function() {
        bindEvents();
        loadAuthorityData('');
    });

    function bindEvents() {
        $('#authorityRoleList').on('click', '.ds-authority-role', function() {
            state.selectedAuthrtId = String($(this).data('authrt-id'));
            loadAuthorityData(state.selectedAuthrtId);
        });
        $('#authorityMenuList').on('change', '.authority-menu-check', updateSelectionCount);
        $('#authorityMenuList').on('change', '.authority-group-check', function() {
            $(this).closest('.ds-authority-group').find('.authority-menu-check')
                .prop('checked', this.checked);
            updateSelectionCount();
        });
        $('#checkAllAuthority').on('change', function() {
            $('.authority-menu-check, .authority-group-check').prop('checked', this.checked);
            updateSelectionCount();
        });
        $('#btnAuthoritySave').on('click', saveMenuAuthority);
        $('#btnAuthorityAdd').on('click', function() { openAuthorityModal('insert'); });
        $('#btnAuthorityEdit').on('click', function() { openAuthorityModal('update'); });
        $('#btnAuthorityDelete').on('click', deleteAuthority);
        $('#btnAuthorityModalClose, #btnAuthorityModalCancel').on('click', closeAuthorityModal);
        $('#authorityForm').on('submit', saveAuthority);
    }

    function loadAuthorityData(authrtId) {
        $.getJSON(ctxPath + '/authority/authorityData.ajax', { authrtId: authrtId })
            .done(function(data) {
                if (data.result !== 'OK') {
                    showAuthorityToast(data.msg || '권한 정보를 조회하지 못했습니다.', 'error');
                    return;
                }
                state.authorityList = data.authorityList || [];
                if (!state.selectedAuthrtId && state.authorityList.length) {
                    state.selectedAuthrtId = state.authorityList[0].authrtId;
                    loadAuthorityData(state.selectedAuthrtId);
                    return;
                }
                state.menuList = data.menuList || [];
                renderAuthorityList();
                renderMenuList();
            })
            .fail(function() {
                showAuthorityToast('권한 정보를 조회하는 중 통신 오류가 발생했습니다.', 'error');
            });
    }

    function renderAuthorityList() {
        var html = state.authorityList.map(function(item, index) {
            var active = item.authrtId === state.selectedAuthrtId ? ' is-active' : '';
            return '<button type="button" class="ds-authority-role' + active + '" data-authrt-id="'
                + escapeHtml(item.authrtId) + '"><b>' + (index + 1) + '</b><strong>'
                + escapeHtml(item.authrtNm) + '</strong><small>' + numberFormat(item.userCount) + '명</small></button>';
        }).join('');
        $('#authorityRoleList').html(html || '<div class="ds-empty">등록된 권한이 없습니다.</div>');
    }

    function renderMenuList() {
        var selected = findSelectedAuthority();
        $('#selectedAuthorityName').text(selected ? selected.authrtNm + ' 접근 메뉴' : '권한을 선택해 주세요.');
        if (!state.menuList.length) {
            $('#authorityMenuList').html('<div class="ds-empty">표시할 메뉴가 없습니다.</div>');
            updateSelectionCount();
            return;
        }

        var workspaces = {};
        state.menuList.forEach(function(item) {
            if (!workspaces[item.workspcId]) {
                workspaces[item.workspcId] = { name: item.workspcNm, groups: [] };
            }
            if (!item.upMenuSn && item.menuTypeNm === 'GROUP') {
                workspaces[item.workspcId].groups.push({
                    menuSn: String(item.menuSn),
                    name: item.menuNm,
                    icon: item.menuIconNm,
                    children: []
                });
            }
        });
        state.menuList.forEach(function(item) {
            if (!item.upMenuSn) return;
            var workspace = workspaces[item.workspcId];
            if (!workspace) return;
            workspace.groups.forEach(function(group) {
                if (String(item.upMenuSn) === group.menuSn) group.children.push(item);
            });
        });

        var html = Object.keys(workspaces).map(function(workspcId) {
            var workspace = workspaces[workspcId];
            var groups = workspace.groups.map(renderGroup).join('');
            return '<section class="ds-authority-workspace"><h3 class="ds-authority-workspace-title">'
                + '<i class="fa-solid fa-layer-group"></i>' + escapeHtml(workspace.name)
                + '</h3>' + groups + '</section>';
        }).join('');
        $('#authorityMenuList').html(html);
        var adminFixed = state.selectedAuthrtId === 'ADMIN';
        $('#btnAuthoritySave').prop('disabled', adminFixed)
            .attr('title', adminFixed ? '최고관리자는 전체 기능으로 고정됩니다.' : '');
        $('.authority-menu-check, .authority-group-check, #checkAllAuthority')
            .prop('disabled', adminFixed);
        syncGroupChecks();
        updateSelectionCount();
    }

    function renderGroup(group) {
        var children = group.children;
        var childHtml = children.map(function(item) {
            var checked = item.authrtGrntYn === 'Y' ? ' checked' : '';
            return '<label class="ds-authority-menu-item"><input type="checkbox" class="authority-menu-check" value="'
                + item.menuSn + '"' + checked + '><span><strong>' + escapeHtml(item.menuNm)
                + '</strong><small>' + escapeHtml(item.menuUrlAddr || item.menuCd) + '</small></span></label>';
        }).join('');
        return '<section class="ds-authority-group"><div class="ds-authority-group-head"><label>'
            + '<input type="checkbox" class="authority-group-check"><i class="fa-solid '
            + escapeHtml(group.icon || 'fa-folder') + '"></i>' + escapeHtml(group.name)
            + '</label><small>' + children.length + '</small></div><div class="ds-authority-group-grid">'
            + childHtml + '</div></section>';
    }

    function saveMenuAuthority() {
        if (!state.selectedAuthrtId) {
            showAuthorityToast('저장할 권한을 선택해 주세요.', 'error');
            return;
        }
        var data = [{ name: 'authrtId', value: state.selectedAuthrtId }];
        $('.authority-menu-check:checked').each(function() {
            data.push({ name: 'menuSn', value: this.value });
        });
        $.ajax({
            url: ctxPath + '/authority/authoritySave.ajax',
            type: 'POST',
            data: data,
            dataType: 'json'
        }).done(function(result) {
            if (result.result === 'OK') {
                showAuthorityToast('권한을 저장했습니다.', 'success');
                loadAuthorityData(state.selectedAuthrtId);
                return;
            }
            showAuthorityToast(result.msg || '권한을 저장하지 못했습니다.', 'error');
        }).fail(function(xhr) {
            showAuthorityToast(readErrorMessage(xhr, '권한 저장 중 통신 오류가 발생했습니다.'), 'error');
        });
    }

    function openAuthorityModal(mode) {
        var selected = findSelectedAuthority();
        if (mode === 'update' && !selected) {
            showAuthorityToast('수정할 권한을 선택해 주세요.', 'error');
            return;
        }
        $('#authorityFormMode').val(mode);
        $('#authorityModalTitle').text(mode === 'insert' ? '신규 권한 추가' : '권한 수정');
        $('#authorityId').val(mode === 'insert' ? '' : selected.authrtId)
            .prop('readonly', mode === 'update');
        $('#authorityName').val(mode === 'insert' ? '' : selected.authrtNm);
        $('#authorityDescription').val(mode === 'insert' ? '' : (selected.authrtExpln || ''));
        $('#authorityModal').removeClass('hidden');
    }

    function closeAuthorityModal() {
        $('#authorityModal').addClass('hidden');
    }

    function saveAuthority(event) {
        event.preventDefault();
        var mode = $('#authorityFormMode').val();
        var payload = {
            authrtId: $.trim($('#authorityId').val()).toUpperCase(),
            authrtNm: $.trim($('#authorityName').val()),
            authrtExpln: $.trim($('#authorityDescription').val())
        };
        $.post(ctxPath + '/authority/authority' + (mode === 'insert' ? 'Insert' : 'Update') + '.ajax', payload)
            .done(function(result) {
                if (result.result !== 'OK') {
                    showAuthorityToast(result.msg || '권한 정보를 저장하지 못했습니다.', 'error');
                    return;
                }
                state.selectedAuthrtId = payload.authrtId;
                closeAuthorityModal();
                loadAuthorityData(state.selectedAuthrtId);
                showAuthorityToast('권한 정보를 저장했습니다.', 'success');
            })
            .fail(function(xhr) {
                showAuthorityToast(readErrorMessage(xhr, '권한 정보 저장 중 통신 오류가 발생했습니다.'), 'error');
            });
    }

    function deleteAuthority() {
        var selected = findSelectedAuthority();
        if (!selected) {
            showAuthorityToast('삭제할 권한을 선택해 주세요.', 'error');
            return;
        }
        if (!window.confirm(selected.authrtNm + ' 권한을 삭제하시겠습니까?')) return;
        $.post(ctxPath + '/authority/authorityDelete.ajax', { authrtId: selected.authrtId })
            .done(function(result) {
                if (result.result !== 'OK') {
                    showAuthorityToast(result.msg || '권한을 삭제하지 못했습니다.', 'error');
                    return;
                }
                state.selectedAuthrtId = '';
                loadAuthorityData('');
                showAuthorityToast('권한을 삭제했습니다.', 'success');
            })
            .fail(function(xhr) {
                showAuthorityToast(readErrorMessage(xhr, '권한 삭제 중 통신 오류가 발생했습니다.'), 'error');
            });
    }

    function updateSelectionCount() {
        var total = $('.authority-menu-check').length;
        var checked = $('.authority-menu-check:checked').length;
        $('#selectedAuthorityCount').text(checked + '개 기능 허용');
        $('#checkAllAuthority').prop('checked', total > 0 && total === checked);
        syncGroupChecks();
    }

    function syncGroupChecks() {
        $('.ds-authority-group').each(function() {
            var $checks = $(this).find('.authority-menu-check');
            $(this).find('.authority-group-check')
                .prop('checked', $checks.length > 0 && $checks.filter(':checked').length === $checks.length);
        });
    }

    function findSelectedAuthority() {
        var result = null;
        state.authorityList.some(function(item) {
            if (item.authrtId === state.selectedAuthrtId) {
                result = item;
                return true;
            }
            return false;
        });
        return result;
    }

    function readErrorMessage(xhr, fallback) {
        return xhr.responseJSON && xhr.responseJSON.msg ? xhr.responseJSON.msg : fallback;
    }

    function numberFormat(value) {
        return Number(value || 0).toLocaleString('ko-KR');
    }

    function escapeHtml(value) {
        return String(value === null || value === undefined ? '' : value)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }

    function showAuthorityToast(message, type) {
        if (typeof showToast === 'function') {
            showToast(message, type);
            return;
        }
        window.alert(message);
    }
})(jQuery);
