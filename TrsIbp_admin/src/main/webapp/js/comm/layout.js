/**
 * 공통 레이아웃 JavaScript
 * - 업무화면 공통 메뉴/헤더에서 사용하는 기능을 제공한다.
 */

/**
 * 사이드바 하위 메뉴를 펼치거나 접는다.
 * @param {string} id 토글할 하위 메뉴 DOM id
 * @returns 없음
 */
function toggleSubmenu(id) {
    var submenu = document.getElementById(id);
    var arrow = document.getElementById('arrow-' + id);

    if (!submenu) {
        return;
    }

    submenu.classList.toggle('hidden');

    if (arrow) {
        arrow.classList.toggle('fa-chevron-down');
        arrow.classList.toggle('fa-chevron-up');
        arrow.classList.toggle('text-gray-500');
        arrow.classList.toggle('text-cyan-400');
    }
}

/**
 * 헤더 업무공간 전환 메뉴를 바깥 영역 클릭 또는 ESC 입력 시 닫는다.
 */
(function initWorkspaceSwitcher() {
    document.addEventListener('click', function(event) {
        var switcher = document.querySelector('.ds-workspace-switcher[open]');
        if (switcher && !switcher.contains(event.target)) {
            switcher.removeAttribute('open');
        }
    });

    document.addEventListener('keydown', function(event) {
        if (event.key !== 'Escape') {
            return;
        }
        var switcher = document.querySelector('.ds-workspace-switcher[open]');
        if (switcher) {
            switcher.removeAttribute('open');
            var summary = switcher.querySelector('summary');
            if (summary) {
                summary.focus();
            }
        }
    });
})();

/**
 * 현재 화면의 업무공간을 로그인 사용자의 기본값으로 저장한다.
 */
function setDefaultWorkspace(workspace) {
    var contextPath = typeof ctxPath !== 'undefined' ? ctxPath : '';
    if (!contextPath) {
        var pathParts = window.location.pathname.split('/');
        contextPath = pathParts.length > 2 ? '/' + pathParts[1] : '';
    }
    jQuery.ajax({
        url: contextPath + '/main/defaultWorkspace.ajax',
        type: 'POST',
        dataType: 'json',
        data: { workspace: workspace }
    }).done(function(data) {
        if (data.result === 'OK') {
            window.location.reload();
            return;
        }
        window.alert(data.msg || '기본 업무공간을 저장하지 못했습니다.');
    }).fail(function(xhr) {
        var message = xhr.responseJSON && xhr.responseJSON.msg
            ? xhr.responseJSON.msg : '기본 업무공간 저장 중 통신 오류가 발생했습니다.';
        window.alert(message);
    });
}
