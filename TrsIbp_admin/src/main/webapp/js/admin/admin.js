(function(window, document, $) {
    'use strict';

    function post(url, data, onSuccess) {
        $.ajax({
            url: window.ctxPath + url,
            type: 'POST',
            data: data,
            dataType: 'json'
        }).done(function(response) {
            if (response && response.result === 'OK') {
                if (typeof onSuccess === 'function') {
                    onSuccess(response);
                }
                return;
            }
            alert(response && response.msg ? response.msg : '처리 중 오류가 발생했습니다.');
        }).fail(function(xhr) {
            var message = '처리 중 오류가 발생했습니다.';
            if (xhr.responseJSON && xhr.responseJSON.msg) {
                message = xhr.responseJSON.msg;
            }
            alert(message);
        });
    }

    function openModal(id) {
        var modal = document.getElementById(id);
        if (modal) {
            modal.classList.add('is-open');
        }
    }

    function closeModal(id) {
        var modal = document.getElementById(id);
        if (modal) {
            modal.classList.remove('is-open');
        }
    }

    function text(value) {
        return value === null || typeof value === 'undefined' || value === '' ? '-' : String(value);
    }

    window.adminPost = post;
    window.openAdminModal = openModal;
    window.closeAdminModal = closeModal;
    window.adminText = text;

    document.addEventListener('click', function(event) {
        if (event.target.classList.contains('admin-modal')) {
            event.target.classList.remove('is-open');
        }
    });

    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            var modals = document.querySelectorAll('.admin-modal.is-open');
            Array.prototype.forEach.call(modals, function(modal) {
                modal.classList.remove('is-open');
            });
        }
    });
})(window, document, window.jQuery);
