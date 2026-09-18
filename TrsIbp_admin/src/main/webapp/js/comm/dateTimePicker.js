/**
 * 프로젝트 공통 jQuery DateTimePicker 초기화 모듈.
 * 날짜 필드는 yyyy-MM-dd, 날짜·시간 필드는 yyyy-MM-dd HH:mm 값을 유지한다.
 */
(function(window, $) {
    'use strict';

    var DATE_SELECTOR = '.ds-date-picker';
    var DATETIME_SELECTOR = '.ds-datetime-picker';

    /**
     * 시·분 선택 목록에 사용할 두 자리 숫자를 반환한다.
     * @param {number} value 숫자
     * @returns {string} 두 자리 숫자 문자열
     */
    function pad(value) {
        return value < 10 ? '0' + value : String(value);
    }

    /**
     * 날짜·시간 입력값에서 현재 시·분을 추출한다.
     * @param {string} value yyyy-MM-dd HH:mm 형식의 입력값
     * @returns {{hour:string, minute:string}} 시·분 값
     */
    function extractTime(value) {
        var matched = String(value || '').match(/(?:T|\s)(\d{2}):(\d{2})/);
        return matched
            ? { hour: matched[1], minute: matched[2] }
            : { hour: '09', minute: '00' };
    }

    /**
     * 분리된 시·분 선택값을 입력 요소의 날짜·시간 값에 즉시 반영한다.
     * @param {jQuery} $input DateTimePicker 대상 입력 요소
     * @param {jQuery} $selector 시·분 선택 영역
     * @returns {void}
     */
    function applySplitTime($input, $selector) {
        var datePart = String($input.val() || '').substring(0, 10);
        if (!/^\d{4}-\d{2}-\d{2}$/.test(datePart)) {
            return;
        }
        $input.val(datePart + ' ' + $selector.find('.ds-time-hour').val() + ':' + $selector.find('.ds-time-minute').val());
        $input.trigger('change');
    }

    /**
     * 날짜·시간 선택창에 시와 분을 분리한 선택 영역을 구성한다.
     * @param {jQuery} $input DateTimePicker 대상 입력 요소
     * @returns {void}
     */
    function renderSplitTimeSelector($input) {
        var $picker = $input.data('xdsoft_datetimepicker');
        if (!$picker || !$picker.length) {
            return;
        }
        $picker.addClass('ds-xdsoft-picker ds-xdsoft-datetime-picker');
        var $selector = $picker.children('.ds-split-time-selector');
        if (!$selector.length) {
            var hourOptions = '';
            var minuteOptions = '';
            for (var hour = 0; hour < 24; hour++) {
                hourOptions += '<option value="' + pad(hour) + '">' + pad(hour) + '</option>';
            }
            for (var minute = 0; minute < 60; minute++) {
                minuteOptions += '<option value="' + pad(minute) + '">' + pad(minute) + '</option>';
            }
            $selector = $('<div class="ds-split-time-selector">'
                + '<strong>시간 선택</strong>'
                + '<select class="ds-time-hour" aria-label="시 선택">' + hourOptions + '</select>'
                + '<i>:</i>'
                + '<select class="ds-time-minute" aria-label="분 선택">' + minuteOptions + '</select>'
                + '<button type="button" class="ds-time-confirm">선택</button>'
                + '</div>');
            $picker.append($selector);
        }

        var time = extractTime($input.val());
        $selector.find('.ds-time-hour').val(time.hour);
        $selector.find('.ds-time-minute').val(time.minute);
        $selector.off('.dsSplitTime').on('mousedown.dsSplitTime focusin.dsSplitTime', function(event) {
            $picker.data('dsSplitTimeInteracting', true);
            event.stopPropagation();
        });
        $selector.on('click.dsSplitTime', function(event) {
            event.stopPropagation();
        });
        $selector.on('focusout.dsSplitTime', function() {
            window.setTimeout(function() {
                $picker.data('dsSplitTimeInteracting', false);
            }, 150);
        });
        $selector.find('select').off('change.dsSplitTime').on('change.dsSplitTime', function() {
            applySplitTime($input, $selector);
        });
        $selector.find('.ds-time-confirm').off('click.dsSplitTime').on('click.dsSplitTime', function(event) {
            event.preventDefault();
            event.stopPropagation();
            applySplitTime($input, $selector);
            $picker.data('dsSplitTimeInteracting', false);
            $input.datetimepicker('hide');
        });
    }

    /**
     * 선택한 입력 요소의 기존 DateTimePicker 인스턴스를 제거한다.
     * @param {jQuery|string|Element} target 입력 요소 또는 선택자
     * @returns {void}
     */
    function destroy(target) {
        $(target).each(function() {
            var $input = $(this);
            if ($input.data('xdsoft_datetimepicker')) {
                $input.datetimepicker('destroy');
            }
        });
    }

    /**
     * 날짜 또는 날짜·시간 입력 요소에 공통 DateTimePicker를 설정한다.
     * @param {jQuery|string|Element} target 입력 요소 또는 선택자
     * @param {Object=} options dateTime, step 및 DateTimePicker 추가 설정
     * @returns {void}
     */
    function configure(target, options) {
        if (!$.fn || typeof $.fn.datetimepicker !== 'function') {
            return;
        }
        options = options || {};
        var dateTime = options.dateTime === true;
        var customPickerOptions = options.pickerOptions || {};
        var originalOnShow = customPickerOptions.onShow;
        var originalOnGenerate = customPickerOptions.onGenerate;
        var originalOnSelectDate = customPickerOptions.onSelectDate;
        var originalOnClose = customPickerOptions.onClose;
        var pickerOptions = $.extend({}, {
            format: dateTime ? 'Y-m-d H:i' : 'Y-m-d',
            formatDate: 'Y-m-d',
            formatTime: 'H:i',
            datepicker: true,
            timepicker: dateTime,
            closeOnDateSelect: !dateTime,
            closeOnTimeSelect: false,
            closeOnWithoutClick: true,
            dayOfWeekStart: 0,
            step: options.step || 1,
            scrollInput: false,
            scrollMonth: false,
            scrollTime: false,
            validateOnBlur: false
        }, customPickerOptions);

        destroy(target);
        $(target).each(function() {
            var $input = $(this);
            var inputPickerOptions = $.extend({}, pickerOptions, {
                onShow: function(currentTime, selectedInput, event) {
                    var $picker = selectedInput.data('xdsoft_datetimepicker');
                    if ($picker && $picker.length) {
                        $picker.addClass('ds-xdsoft-picker');
                    }
                    if (dateTime) {
                        renderSplitTimeSelector(selectedInput);
                    }
                    if (typeof originalOnShow === 'function') {
                        return originalOnShow.call(this, currentTime, selectedInput, event);
                    }
                },
                onGenerate: function(currentTime, selectedInput) {
                    var $picker = selectedInput.data('xdsoft_datetimepicker');
                    if ($picker && $picker.length) {
                        $picker.addClass('ds-xdsoft-picker');
                    }
                    if (dateTime) {
                        renderSplitTimeSelector(selectedInput);
                    }
                    if (typeof originalOnGenerate === 'function') {
                        originalOnGenerate.call(this, currentTime, selectedInput);
                    }
                },
                onSelectDate: function(currentTime, selectedInput, event) {
                    if (dateTime) {
                        var $picker = selectedInput.data('xdsoft_datetimepicker');
                        var $selector = $picker.children('.ds-split-time-selector');
                        $picker.data('dsSplitTimeInteracting', false);
                        applySplitTime(selectedInput, $selector);
                    }
                    if (typeof originalOnSelectDate === 'function') {
                        originalOnSelectDate.call(this, currentTime, selectedInput, event);
                    }
                },
                onClose: function(currentTime, selectedInput, event) {
                    var $picker = selectedInput.data('xdsoft_datetimepicker');
                    if (dateTime && $picker && $picker.data('dsSplitTimeInteracting')) {
                        return false;
                    }
                    if (typeof originalOnClose === 'function') {
                        return originalOnClose.call(this, currentTime, selectedInput, event);
                    }
                }
            });
            $input
                .attr('type', 'text')
                .attr('readonly', 'readonly')
                .attr('autocomplete', 'off')
                .datetimepicker(inputPickerOptions);
        });
    }

    /**
     * 화면에 선언된 모든 공통 날짜 및 날짜·시간 입력 요소를 초기화한다.
     * 남아 있는 브라우저 기본 date/datetime-local 입력도 방어적으로 변환한다.
     * @param {Document|Element=} root 초기화 범위. 생략 시 document
     * @returns {void}
     */
    function initialize(root) {
        var $root = $(root || document);
        $root.find('input[type="date"]').addClass('ds-date-picker');
        $root.find('input[type="datetime-local"]').addClass('ds-datetime-picker');
        configure($root.find(DATE_SELECTOR), { dateTime: false });
        configure($root.find(DATETIME_SELECTOR), { dateTime: true });
    }

    /**
     * 선택한 입력 요소에 열려 있는 DateTimePicker를 닫는다.
     * @param {jQuery|string|Element} target 입력 요소 또는 선택자
     * @returns {void}
     */
    function hide(target) {
        if ($.fn && typeof $.fn.datetimepicker === 'function') {
            $(target).datetimepicker('hide');
        }
    }

    if ($.datetimepicker && typeof $.datetimepicker.setLocale === 'function') {
        $.datetimepicker.setLocale('ko');
    }

    window.DsDateTimePicker = {
        initialize: initialize,
        configure: configure,
        destroy: destroy,
        hide: hide
    };

    $(function() {
        initialize(document);
    });
})(window, jQuery);
