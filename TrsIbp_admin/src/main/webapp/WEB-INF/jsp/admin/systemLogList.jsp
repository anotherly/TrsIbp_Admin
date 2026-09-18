<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync System Admin - 시스템 로그"/></jsp:include>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin.css">
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen min-w-0">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="시스템 로그"/></jsp:include>
    <main class="admin-main">
        <div class="admin-page-heading"><div><h1>시스템 로그</h1><p>관리자 로그인 실패, 권한 오류와 관리자 기능 처리 중 발생한 오류를 조회합니다.</p></div></div>
        <form class="admin-card admin-filter" method="get" action="<%=request.getContextPath()%>/admin/systemLogList.do">
            <div class="admin-filter-grid" style="grid-template-columns:160px 180px minmax(260px,1fr) auto">
                <div class="admin-filter-field">
                    <label for="logLevelCd">등급</label>
                    <select class="admin-select" id="logLevelCd" name="logLevelCd">
                        <option value="">전체</option>
                        <option value="ERROR" ${search.logLevelCd eq 'ERROR' ? 'selected' : ''}>ERROR</option>
                        <option value="WARN" ${search.logLevelCd eq 'WARN' ? 'selected' : ''}>WARN</option>
                        <option value="INFO" ${search.logLevelCd eq 'INFO' ? 'selected' : ''}>INFO</option>
                    </select>
                </div>
                <div class="admin-filter-field">
                    <label for="logSeCd">구분</label>
                    <select class="admin-select" id="logSeCd" name="logSeCd">
                        <option value="">전체</option>
                        <option value="LOGIN_FAIL" ${search.logSeCd eq 'LOGIN_FAIL' ? 'selected' : ''}>로그인 실패</option>
                        <option value="LOGIN" ${search.logSeCd eq 'LOGIN' ? 'selected' : ''}>로그인</option>
                        <option value="AUTH_ERROR" ${search.logSeCd eq 'AUTH_ERROR' ? 'selected' : ''}>권한 오류</option>
                        <option value="SERVER_ERROR" ${search.logSeCd eq 'SERVER_ERROR' ? 'selected' : ''}>서버 오류</option>
                        <option value="BATCH_ERROR" ${search.logSeCd eq 'BATCH_ERROR' ? 'selected' : ''}>배치 오류</option>
                    </select>
                </div>
                <div class="admin-filter-field">
                    <label for="searchValue">제목·내용·사용자·IP</label>
                    <input class="admin-input" id="searchValue" name="searchValue" value="<c:out value="${search.searchValue}"/>" placeholder="검색어를 입력하세요">
                </div>
                <div class="admin-filter-actions">
                    <button class="admin-btn primary" type="submit">조회</button>
                    <a class="admin-btn ghost" href="<%=request.getContextPath()%>/admin/systemLogList.do">초기화</a>
                </div>
            </div>
        </form>
        <article class="admin-card">
            <div class="admin-card-header"><div><h2>로그 목록</h2><small>최대 500건 표시</small></div></div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead><tr><th>발생시각</th><th>등급</th><th>구분</th><th>제목</th><th>상세내용</th><th>사용자</th><th>요청 URI</th><th>접속 IP</th></tr></thead>
                    <tbody>
                        <c:forEach var="row" items="${list}">
                            <tr>
                                <td><c:out value="${row.REG_DT}"/></td>
                                <td><span class="admin-status ${row.LOG_LEVEL_CD eq 'ERROR' ? 'error' : row.LOG_LEVEL_CD eq 'WARN' ? 'warn' : 'info'}"><c:out value="${row.LOG_LEVEL_CD}"/></span></td>
                                <td><c:out value="${row.LOG_SE_CD}"/></td>
                                <td><strong class="text-slate-200"><c:out value="${row.LOG_TITLE}"/></strong></td>
                                <td><span class="admin-log-message" title="<c:out value="${row.LOG_CN}"/>"><c:out value="${row.LOG_CN}" default="-"/></span></td>
                                <td><c:out value="${row.USER_ID}" default="-"/></td>
                                <td><c:out value="${row.REQUEST_URI}" default="-"/></td>
                                <td><c:out value="${row.CLIENT_IP_ADDR}" default="-"/></td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty list}"><tr><td colspan="8" class="admin-empty">조회된 시스템 로그가 없습니다.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </article>
    </main>
</div>
</body>
</html>
