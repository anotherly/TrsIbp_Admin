<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String dsPageTitle = request.getParameter("dsPageTitle");
    if (dsPageTitle == null || dsPageTitle.trim().isEmpty()) {
        dsPageTitle = "시스템 대시보드";
    }
%>
<header class="h-16 border-b border-brand-border bg-brand-card/30 backdrop-blur-md flex items-center justify-between px-8 sticky top-0 z-20">
    <div class="flex items-center gap-2 text-sm text-gray-400">
        <span>DevSync 시스템 운영</span>
        <i class="fa-solid fa-angle-right text-xs"></i>
        <span class="text-gray-100 font-semibold"><%=dsPageTitle%></span>
    </div>
    <div class="flex items-center gap-4">
        <span class="text-xs text-gray-400">
            <i class="fa-solid fa-user-shield text-cyan-400 mr-1"></i>
            <strong class="text-gray-200">${sessionScope.login.userNm}</strong>
        </span>
        <a href="<%=request.getContextPath()%>/login/logout.do"
           class="text-xs text-gray-500 hover:text-red-400 transition px-2 py-1 rounded hover:bg-red-500/10"
           onclick="return confirm('로그아웃 하시겠습니까?')">
            <i class="fa-solid fa-right-from-bracket"></i>
        </a>
    </div>
</header>
