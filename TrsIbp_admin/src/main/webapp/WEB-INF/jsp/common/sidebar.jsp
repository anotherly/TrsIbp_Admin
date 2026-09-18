<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String adminUri = request.getRequestURI();
    String adminCtx = request.getContextPath();
    if (adminCtx != null && !adminCtx.isEmpty() && adminUri.startsWith(adminCtx)) {
        adminUri = adminUri.substring(adminCtx.length());
    }
%>
<aside class="ds-sidebar w-64 bg-slate-950 border-r border-brand-border flex flex-col justify-between h-screen sticky top-0 z-30">
    <div class="ds-sidebar-scroll">
        <div class="ds-brand">
            <a href="<%=adminCtx%>/admin/dashboard.do" class="flex items-center gap-3">
                <div class="ds-brand-mark"><i class="fa-solid fa-shield-halved text-xl"></i></div>
                <div>
                    <span class="font-extrabold text-xl text-white tracking-wider">DevSync</span>
                    <span class="text-xs block text-cyan-400 font-semibold tracking-widest uppercase">System Admin</span>
                </div>
            </a>
        </div>

        <div class="ds-user-card">
            <div class="w-10 h-10 rounded-full border border-cyan-400 bg-slate-800 flex items-center justify-center">
                <i class="fa-solid fa-user-shield text-cyan-300"></i>
            </div>
            <div class="flex-grow overflow-hidden">
                <h4 class="font-bold text-sm text-gray-100 truncate">${sessionScope.login.userNm}</h4>
                <span class="text-xs text-gray-400">시스템관리자</span>
            </div>
        </div>

        <nav class="px-4 space-y-1">
            <div class="ds-workspace-caption">
                <i class="fa-solid fa-server"></i>
                <span>서비스 운영 관리</span>
            </div>

            <a href="<%=adminCtx%>/admin/dashboard.do"
               class="ds-menu-item <%="/admin/dashboard.do".equals(adminUri) || "/main/main.do".equals(adminUri) ? "is-active" : ""%>">
                <i class="fa-solid fa-gauge-high w-5"></i><span>시스템 대시보드</span>
            </a>
            <a href="<%=adminCtx%>/admin/companyRequestList.do"
               class="ds-menu-item <%=adminUri.startsWith("/admin/companyRequest") ? "is-active" : ""%>">
                <i class="fa-solid fa-building-circle-check w-5"></i><span>기업가입 승인</span>
            </a>
            <a href="<%=adminCtx%>/admin/companyList.do"
               class="ds-menu-item <%="/admin/companyList.do".equals(adminUri) ? "is-active" : ""%>">
                <i class="fa-solid fa-building w-5"></i><span>기업 관리</span>
            </a>
            <a href="<%=adminCtx%>/admin/userList.do"
               class="ds-menu-item <%="/admin/userList.do".equals(adminUri) ? "is-active" : ""%>">
                <i class="fa-solid fa-users-gear w-5"></i><span>전체 회원 관리</span>
            </a>

            <div class="ds-menu-divider"><span>운영·감사</span></div>
            <a href="<%=adminCtx%>/admin/systemLogList.do"
               class="ds-menu-item <%="/admin/systemLogList.do".equals(adminUri) ? "is-active" : ""%>">
                <i class="fa-solid fa-triangle-exclamation w-5"></i><span>시스템 로그</span>
            </a>
            <a href="<%=adminCtx%>/admin/actionHistoryList.do"
               class="ds-menu-item <%="/admin/actionHistoryList.do".equals(adminUri) ? "is-active" : ""%>">
                <i class="fa-solid fa-clipboard-list w-5"></i><span>관리자 처리 이력</span>
            </a>
            <a href="<%=adminCtx%>/admin/operationPolicy.do"
               class="ds-menu-item <%="/admin/operationPolicy.do".equals(adminUri) ? "is-active" : ""%>">
                <i class="fa-solid fa-sliders w-5"></i><span>공통코드·운영정책</span>
            </a>
        </nav>
    </div>

    <div class="ds-sidebar-footer">
        <span><i class="fa-solid fa-circle text-emerald-500 text-[8px] mr-1"></i>Admin Console</span>
        <a href="<%=adminCtx%>/login/logout.do" class="hover:text-red-400 transition"
           title="로그아웃" onclick="return confirm('로그아웃 하시겠습니까?')">
            <i class="fa-solid fa-right-from-bracket text-sm"></i>
        </a>
    </div>
</aside>
