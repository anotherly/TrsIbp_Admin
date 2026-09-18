<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>DevSync System Admin - 로그인</title>
<!-- Tailwind CSS (로컬 저장본) -->
<script src="<%=request.getContextPath()%>/protoType/saved_resource"></script>
<script>
    tailwind.config = {
        theme: {
            extend: {
                colors: {
                    brand: {
                        dark:    '#0b0f19',
                        card:    '#111827',
                        border:  '#1f2937',
                        accent:  '#3b82f6',
                        neonBlue:'#00d2ff',
                        neonGreen:'#10b981'
                    }
                },
                fontFamily: {
                    sans: ['Inter', 'Noto Sans KR', 'sans-serif']
                }
            }
        }
    }
</script>
<!-- Google Fonts & FontAwesome (로컬 저장본) -->
<link rel="preconnect" href="https://fonts.googleapis.com/">
<link rel="preconnect" href="https://fonts.gstatic.com/" crossorigin="">
<link href="<%=request.getContextPath()%>/protoType/css2" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<style>
    body {
        font-family: 'Inter', 'Noto Sans KR', sans-serif;
        background-color: #0b0f19;
        color: #f3f4f6;
    }
    /* 그리드 배경 패턴 */
    .grid-bg {
        background-image: linear-gradient(rgba(59,130,246,0.05) 1px, transparent 1px),
                          linear-gradient(90deg, rgba(59,130,246,0.05) 1px, transparent 1px);
        background-size: 40px 40px;
    }
    /* 입력 필드 포커스 효과 */
    .login-input:focus {
        outline: none;
        border-color: #3b82f6;
        box-shadow: 0 0 0 3px rgba(59,130,246,0.15);
    }
    /* 로그인 버튼 애니메이션 */
    .login-btn {
        background: linear-gradient(135deg, #3b82f6, #00d2ff);
        transition: all 0.3s ease;
    }
    .login-btn:hover {
        background: linear-gradient(135deg, #2563eb, #0ea5e9);
        transform: translateY(-1px);
        box-shadow: 0 8px 25px rgba(59,130,246,0.4);
    }
    .login-btn:active {
        transform: translateY(0);
    }
    /* 오류 메시지 */
    .error-box {
        background: rgba(239,68,68,0.1);
        border: 1px solid rgba(239,68,68,0.3);
        border-radius: 8px;
        color: #f87171;
        padding: 10px 14px;
        font-size: 0.875rem;
        display: flex;
        align-items: center;
        gap: 8px;
    }
</style>
</head>
<body class="min-h-screen flex items-center justify-center grid-bg">

    <!-- 배경 글로우 효과 -->
    <div class="fixed inset-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-40 -right-40 w-96 h-96 bg-brand-accent opacity-5 rounded-full blur-3xl"></div>
        <div class="absolute -bottom-40 -left-40 w-96 h-96 bg-cyan-500 opacity-5 rounded-full blur-3xl"></div>
    </div>

    <!-- 로그인 카드 -->
    <div class="relative z-10 w-full max-w-md mx-4">

        <!-- 로고 -->
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-tr from-brand-accent to-cyan-400 mb-4 shadow-2xl shadow-brand-accent/30">
                <i class="fa-solid fa-shield-halved text-2xl text-white"></i>
            </div>
            <h1 class="text-3xl font-extrabold text-white tracking-wider">DevSync</h1>
            <p class="text-cyan-400 text-sm font-semibold tracking-widest uppercase mt-1">System Admin</p>
        </div>

        <!-- 로그인 폼 카드 -->
        <div class="bg-brand-card border border-brand-border rounded-2xl p-8 shadow-2xl shadow-brand-accent/10">
            <h2 class="text-lg font-semibold text-white mb-2 text-center">시스템관리자 로그인</h2>
            <p class="text-xs text-gray-500 mb-6 text-center">기업가입 승인과 서비스 운영을 위한 관리자 전용 화면입니다.</p>

            <%-- 오류 메시지 출력 (LoginController에서 redirect로 전달) --%>
            <c:if test="${not empty errorMsg}">
            <div class="error-box mb-5">
                <i class="fa-solid fa-circle-exclamation"></i>
                <span>${errorMsg}</span>
            </div>
            </c:if>

            <%-- 세션 만료 메시지 --%>
            <c:if test="${not empty sessionMsg}">
            <div class="error-box mb-5" style="background:rgba(251,191,36,0.1);border-color:rgba(251,191,36,0.3);color:#fbbf24;">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span>${sessionMsg}</span>
            </div>
            </c:if>

            <form id="loginForm" action="<%=request.getContextPath()%>/login/loginAction.do" method="post">

                <!-- 아이디 -->
                <div class="mb-4">
                    <label for="userId" class="block text-sm font-medium text-gray-400 mb-2">
                        <i class="fa-solid fa-user mr-1.5 text-brand-accent"></i> 아이디
                    </label>
                    <input type="text" id="userId" name="userId"
                        class="login-input w-full bg-slate-900 border border-brand-border rounded-lg px-4 py-3 text-white text-sm placeholder-gray-600 transition"
                        placeholder="아이디를 입력하세요"
                        value="${not empty loginUserId ? loginUserId : (not empty param.userId ? param.userId : '')}"
                        required>
                </div>
				<!-- autocomplete="username" -->

                <!-- 비밀번호 -->
                <div class="mb-6">
                    <label for="userEnpswd" class="block text-sm font-medium text-gray-400 mb-2">
                        <i class="fa-solid fa-lock mr-1.5 text-brand-accent"></i> 비밀번호
                    </label>
                    <div class="relative">
                        <input type="password" id="userEnpswd" name="userEnpswd"
                            class="login-input w-full bg-slate-900 border border-brand-border rounded-lg px-4 py-3 pr-11 text-white text-sm placeholder-gray-600 transition"
                            placeholder="비밀번호를 입력하세요"
                            autocomplete="current-password"
                            required>
                        <button type="button" onclick="togglePw()"
                            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-300 transition">
                            <i id="pwEyeIcon" class="fa-solid fa-eye text-sm"></i>
                        </button>
                    </div>
                </div>

                <!-- 로그인 버튼 -->
				<div class="mt-4">
				    <button type="submit" class="w-full py-3 bg-brand-accent hover:bg-blue-600 text-white font-bold rounded-xl shadow-lg shadow-brand-accent/30 transition duration-200 text-sm">
				        <i class="fa-solid fa-right-to-bracket mr-2"></i>로그인
				    </button>
				</div>
            </form>

            <!-- 하단 안내 -->
            <div class="mt-6 pt-5 border-t border-brand-border/60 text-center">
                <p class="text-xs text-gray-600">
                    SYS_ADMIN 권한이 있는 계정만 접속할 수 있습니다
                </p>
                <p class="text-xs text-gray-700 mt-1">
                    DevSync v1.0 &nbsp;|&nbsp; eGovFramework 3.9 + Spring 4.0
                </p>
            </div>
        </div>

        <!-- 마이그레이션 실행 안내 -->
        <div class="mt-4 bg-slate-900/60 border border-brand-border/40 rounded-xl p-4 text-center">
            <p class="text-xs text-gray-500 mb-1">
                <i class="fa-solid fa-database text-yellow-500 mr-1"></i> 최초 실행
            </p>
            <p class="text-xs text-gray-600">관리자 DB 마이그레이션 실행 후 <span class="font-mono">sysadmin</span> 계정으로 로그인하세요.</p>
        </div>
    </div>

<script>
<c:if test="${not empty errorMsg}">
alert('<c:out value="${errorMsg}"/>');
</c:if>

// 비밀번호 표시/숨기기 토글
function togglePw() {
    var pwInput = document.getElementById('userEnpswd');
    var eyeIcon = document.getElementById('pwEyeIcon');
    if (pwInput.type === 'password') {
        pwInput.type = 'text';
        eyeIcon.className = 'fa-solid fa-eye-slash text-sm';
    } else {
        pwInput.type = 'password';
        eyeIcon.className = 'fa-solid fa-eye text-sm';
    }
}

// 엔터키로 로그인
document.getElementById('loginForm').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
        this.submit();
    }
});

// 페이지 로드 시 아이디 필드 포커스
window.onload = function() {
    var userIdField = document.getElementById('userId');
    if (userIdField && userIdField.value === '') {
        userIdField.focus();
    } else {
        document.getElementById('userEnpswd').focus();
    }
};
</script>
</body>
</html>
