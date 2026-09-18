/**
 * DevSync 전사 공통 유효성 검사 라이브러리 v1.3 (이메일 정규식 가드 추가)
 */
const ValidEngine = {
    
    regex: {
        password: /^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?&])[A-Za-z\d$@$!%*#?&]{8,15}$/,
        phone: /^(010|02|03[1-3]|04[1-4]|05[1-5]|06[1-4]|070|080|15[0-9]{2}|16[0-9]{2})[-]?([0-9]{3,4})[-]?([0-9]{4})$/,
        userId: /^(?=.*[a-z])[a-z0-9]{6,20}$/,
        // ★ [신규 추가] 글로벌 표준 이메일 정규식 명세
        email: /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/
    },

    initMaxLength: function() {
        $(document).on('input', 'input[maxlength], textarea[maxlength]', function() {
            const maxLen = parseInt($(this).attr('maxlength'), 10);
            const currentVal = $(this).val();
            if (currentVal.length > maxLen) {
                alert(`최대 ${maxLen}자까지만 입력 가능합니다.`);
                $(this).val(currentVal.substring(0, maxLen)); 
            }
        });
    },

    validateForm: function(formId) {
        let isAllValid = true;

        $(`${formId} input, ${formId} select`).each(function() {
            const $this = $(this);
            const val = $this.val().trim();
            const labelName = $this.closest('div').find('label').text().replace('*', '').trim() || '항목';
            const validTypes = $this.data('valid') ? $this.data('valid').split(' ') : [];

            // 필수값 기본 검증
            if ($this.prop('required') && !val) {
                alert(`[${labelName}] 항목은 필수 입력 사항입니다.`);
                $this.focus();
                isAllValid = false;
                return false; 
            }

            if (val && validTypes.length > 0) {
                // ★ [신규 추가] 이메일 형식 최종 제출 방어벽 가동
                if (validTypes.includes('email') && !ValidEngine.regex.email.test(val)) {
                    alert(`[${labelName}] 올바른 이메일 주소 형식이 아닙니다.\n(예: user@company.com)`);
                    $this.focus();
                    isAllValid = false;
                    return false;
                }

                if (validTypes.includes('userid') && !ValidEngine.regex.userId.test(val)) {
                    alert(`[${labelName}] 영문 소문자와 숫자 6~20자로 입력하고 영문 소문자를 포함해 주세요.`);
                    $this.focus();
                    isAllValid = false;
                    return false;
                }

                if (validTypes.includes('password') && !ValidEngine.regex.password.test(val)) {
                    alert(`[${labelName}] 영문, 숫자, 특수문자를 혼합하여 8~15자리로 입력해 주세요.`);
                    $this.focus();
                    isAllValid = false;
                    return false;
                }

                if (validTypes.includes('phone') && !ValidEngine.regex.phone.test(val)) {
                    alert(`[${labelName}] 올바른 전화번호 형식이 아닙니다.\n(예: 01012345678 또는 0212345678)`);
                    $this.focus();
                    isAllValid = false;
                    return false;
                }
            }
        });

        return isAllValid;
    }
};

$(document).ready(function() {
    ValidEngine.initMaxLength();
});
