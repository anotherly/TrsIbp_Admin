<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync System Admin - 대시보드"/>
    </jsp:include>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin.css">
</head>
<body class="ds-body min-h-screen flex">
    <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
    <div class="flex-grow flex flex-col min-h-screen min-w-0">
        <jsp:include page="/WEB-INF/jsp/common/header.jsp">
            <jsp:param name="dsPageTitle" value="시스템 대시보드"/>
        </jsp:include>

        <main class="admin-main">
            <div class="admin-page-heading">
                <div>
                    <h1>서비스 운영 현황</h1>
                    <p>기업가입 신청, 전체 기업·회원 상태와 최근 시스템 이상을 확인합니다.</p>
                </div>
                <a class="admin-btn primary" href="<%=request.getContextPath()%>/admin/companyRequestList.do?prcsSttsCd=WAIT">
                    <i class="fa-solid fa-building-circle-check"></i> 승인 대기 처리
                </a>
            </div>

            <section class="admin-kpi-grid">
                <article class="admin-kpi">
                    <div><div class="admin-kpi-label">승인 대기 기업</div><div class="admin-kpi-value"><c:out value="${summary.PENDING_COMPANY_CNT}"/></div></div>
                    <div class="admin-kpi-icon blue"><i class="fa-solid fa-hourglass-half"></i></div>
                </article>
                <article class="admin-kpi">
                    <div><div class="admin-kpi-label">오늘 가입 회원</div><div class="admin-kpi-value"><c:out value="${summary.TODAY_USER_CNT}"/></div></div>
                    <div class="admin-kpi-icon cyan"><i class="fa-solid fa-user-plus"></i></div>
                </article>
                <article class="admin-kpi">
                    <div><div class="admin-kpi-label">이용 기업</div><div class="admin-kpi-value"><c:out value="${summary.ACTIVE_COMPANY_CNT}"/></div></div>
                    <div class="admin-kpi-icon green"><i class="fa-solid fa-building"></i></div>
                </article>
                <article class="admin-kpi">
                    <div><div class="admin-kpi-label">오늘 오류·경고</div><div class="admin-kpi-value"><c:out value="${summary.TODAY_ERROR_CNT}"/></div></div>
                    <div class="admin-kpi-icon red"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </article>
            </section>

            <section class="admin-dashboard-grid">
                <article class="admin-card">
                    <div class="admin-card-header">
                        <div><h2>기업 승인 대기 목록</h2><small>접수일이 오래된 순서입니다.</small></div>
                        <a class="admin-btn ghost" href="<%=request.getContextPath()%>/admin/companyRequestList.do?prcsSttsCd=WAIT">전체 보기</a>
                    </div>
                    <div class="admin-table-wrap">
                        <table class="admin-table">
                            <thead>
                                <tr><th>기업명</th><th>사업자번호</th><th>신청자</th><th>신청일</th><th>상태</th><th class="is-right">처리</th></tr>
                            </thead>
                            <tbody>
                                <c:forEach var="row" items="${pendingList}">
                                    <c:url var="requestDetailUrl" value="/admin/companyRequestList.do">
                                        <c:param name="prcsSttsCd" value="WAIT"/>
                                        <c:param name="searchValue" value="${row.BRNO}"/>
                                    </c:url>
                                    <tr>
                                        <td><strong class="text-slate-200"><c:out value="${row.CO_NM}"/></strong></td>
                                        <td><c:out value="${row.BRNO}"/></td>
                                        <td><c:out value="${row.APLCNT_NM}"/></td>
                                        <td><c:out value="${row.REG_DT}"/></td>
                                        <td><span class="admin-status wait">대기</span></td>
                                        <td class="is-right"><a class="admin-btn" href="${requestDetailUrl}">상세/처리</a></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty pendingList}">
                                    <tr><td colspan="6" class="admin-empty">승인 대기 중인 기업 신청이 없습니다.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </article>

                <div class="admin-stack">
                    <article class="admin-card">
                        <div class="admin-card-header">
                            <div><h2>최근 시스템 이상</h2><small>오류·경고 로그</small></div>
                            <a class="admin-btn ghost" href="<%=request.getContextPath()%>/admin/systemLogList.do">전체 보기</a>
                        </div>
                        <div class="admin-table-wrap">
                            <table class="admin-table">
                                <tbody>
                                    <c:forEach var="row" items="${systemLogList}">
                                        <tr>
                                            <td><span class="admin-status ${row.LOG_LEVEL_CD eq 'ERROR' ? 'error' : 'warn'}"><c:out value="${row.LOG_LEVEL_CD}"/></span></td>
                                            <td><strong class="text-slate-300"><c:out value="${row.LOG_TITLE}"/></strong><small class="block text-slate-600 mt-1"><c:out value="${row.REG_DT}"/></small></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty systemLogList}">
                                        <tr><td class="admin-empty">최근 오류·경고가 없습니다.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </article>

                    <article class="admin-card">
                        <div class="admin-card-header">
                            <div><h2>최근 관리자 처리 이력</h2><small>승인·반려·상태변경</small></div>
                            <a class="admin-btn ghost" href="<%=request.getContextPath()%>/admin/actionHistoryList.do">전체 보기</a>
                        </div>
                        <div class="admin-table-wrap">
                            <table class="admin-table">
                                <tbody>
                                    <c:forEach var="row" items="${historyList}">
                                        <tr>
                                            <td><strong class="text-slate-300"><c:out value="${row.ADMIN_NM}"/></strong></td>
                                            <td><c:out value="${row.ACTION_CN}"/><small class="block text-slate-600 mt-1"><c:out value="${row.REG_DT}"/></small></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty historyList}">
                                        <tr><td class="admin-empty">관리자 처리 이력이 없습니다.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </article>
                </div>
            </section>
        </main>
    </div>
    <script>window.ctxPath = '<%=request.getContextPath()%>';</script>
    <script src="<%=request.getContextPath()%>/js/admin/admin.js"></script>
</body>
</html>
