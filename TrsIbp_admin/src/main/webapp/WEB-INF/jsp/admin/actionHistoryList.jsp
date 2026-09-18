<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync System Admin - 관리자 처리 이력"/></jsp:include>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin.css">
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen min-w-0">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="관리자 처리 이력"/></jsp:include>
    <main class="admin-main">
        <div class="admin-page-heading"><div><h1>관리자 처리 이력</h1><p>기업 승인·반려, 기업·회원 상태 변경, 공통코드와 운영정책 변경을 추적합니다.</p></div></div>
        <form class="admin-card admin-filter" method="get" action="<%=request.getContextPath()%>/admin/actionHistoryList.do">
            <div class="admin-filter-grid" style="grid-template-columns:minmax(320px,1fr) auto">
                <div class="admin-filter-field">
                    <label for="searchValue">처리자·대상·처리내용</label>
                    <input class="admin-input" id="searchValue" name="searchValue" value="<c:out value="${search.searchValue}"/>" placeholder="검색어를 입력하세요">
                </div>
                <div class="admin-filter-actions">
                    <button class="admin-btn primary" type="submit"><i class="fa-solid fa-magnifying-glass"></i> 조회</button>
                    <a class="admin-btn ghost" href="<%=request.getContextPath()%>/admin/actionHistoryList.do">초기화</a>
                </div>
            </div>
        </form>
        <article class="admin-card">
            <div class="admin-card-header"><div><h2>처리 이력 목록</h2><small>최대 500건 표시</small></div></div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead><tr><th>처리시각</th><th>처리자</th><th>처리구분</th><th>대상구분</th><th>대상ID</th><th>처리내용</th></tr></thead>
                    <tbody>
                        <c:forEach var="row" items="${list}">
                            <tr>
                                <td><c:out value="${row.REG_DT}"/></td>
                                <td><strong class="text-slate-200"><c:out value="${row.ADMIN_NM}"/></strong><small class="block text-slate-600 mt-1"><c:out value="${row.ADMIN_ID}"/></small></td>
                                <td><span class="admin-status info"><c:out value="${row.ACTION_SE_CD}"/></span></td>
                                <td><c:out value="${row.TARGET_SE_CD}"/></td>
                                <td><c:out value="${row.TARGET_ID}" default="-"/></td>
                                <td><c:out value="${row.ACTION_CN}"/></td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty list}"><tr><td colspan="6" class="admin-empty">조회된 관리자 처리 이력이 없습니다.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </article>
    </main>
</div>
</body>
</html>
