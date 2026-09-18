package kr.co.TRSolution.trsIbp.comm.util;

import java.util.regex.Pattern;

public class PasswordPolicy {

    // 8~15 / 영문+숫자+특수 / 공백불가
    private static final Pattern PW_POLICY =
        Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d)(?=.*[~!@#$%^&*()_+\\-={}\\[\\]|\\\\:;\"'<>,.?/`]).{8,15}$");

    public static boolean isStrong(String pw) {
        if (pw == null) return false;
        if (pw.contains(" ")) return false;
        return PW_POLICY.matcher(pw).matches();
    }

    public static String failMessage() {
        return "비밀번호는 영문+숫자+특수문자 조합 8~15자(공백 불가)로 입력해야 합니다.";
    }
}
