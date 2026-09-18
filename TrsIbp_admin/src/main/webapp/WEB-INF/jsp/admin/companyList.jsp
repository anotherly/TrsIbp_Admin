<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync System Admin - 기업 관리"/></jsp:include>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin.css">
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen min-w-0">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="기업 관리"/></jsp:include>
    <main class="admin-main">
        <div class="admin-page-heading"><div><h1>전체 기업 관리</h1><p>서비스 이용 기업과 소속 회원 수를 조회하고 사용상태를 관리합니다.</p></div></div>
        <form class="admin-card admin-filter" method="get" action="<%=request.getContextPath()%>/admin/companyList.do">
            <div class="admin-filter-grid">
                <div class="admin-filter-field">
                    <label for="useYn">사용상태</label>
                    <select class="admin-select" id="useYn" name="useYn">
                        <option value="">전체</option>
                        <option value="Y" ${search.useYn eq 'Y' ? 'selected' : ''}>이용</option>
                        <option value="N" ${search.useYn eq 'N' ? 'selected' : ''}>중지</option>
                    </select>
                </div>
                <div class="admin-filter-field">
                    <label for="searchValue">기업ID·기업명·사업자번호</label>
                    <input class="admin-input" id="searchValue" name="searchValue" value="<c:out value="${search.searchValue}"/>" placeholder="검색어를 입력하세요">
                </div>
                <div class="admin-filter-actions">
                    <button class="admin-btn primary" type="submit"><i class="fa-solid fa-magnifying-glass"></i> 조회</button>
                    <a class="admin-btn ghost" href="<%=request.getContextPath()%>/admin/companyList.do">초기화</a>
                </div>
            </div>
        </form>
        <article class="admin-card">
            <div class="admin-card-header"><div><h2>기업 목록</h2><small>최대 200건 표시</small></div></div>
            <div class="admin-table-wrap">
                <table class="admin-table">
                    <thead><tr><th>기업ID</th><th>기업명</th><th>사업자번호</th><th>대표자</th><th>담당자</th><th>전체 회원</th><th>활성 회원</th><th>등록일</th><th>상태</th><th class="is-right">관리</th></tr></thead>
                    <tbody>
                        <c:forEach var="row" items="${list}">
                            <tr>
                                <td><c:out value="${row.CO_ID}"/></td>
                                <td><strong class="text-slate-200"><c:out value="${row.CO_NM}"/></strong></td>
                                <td><c:out value="${row.BRNO}" default="-"/></td>
                                <td><c:out value="${row.RPRSV_NM}" default="-"/></td>
                                <td><c:out value="${row.PIC_NM}" default="-"/></td>
                                <td><c:out value="${row.USER_CNT}"/></td>
                                <td><c:out value="${row.ACTIVE_USER_CNT}"/></td>
                                <td><c:out value="${row.REG_DT}"/></td>
                                <td><span class="admin-status ${row.USE_YN eq 'Y' ? 'y' : 'n'}">${row.USE_YN eq 'Y' ? '이용' : '중지'}</span></td>
                                <td class="is-right">
                                    <button type="button" class="admin-btn ${row.USE_YN eq 'Y' ? 'danger' : 'success'}"
                                            onclick="changeCompanyUse('<c:out value="${row.CO_ID}"/>','${row.USE_YN eq 'Y' ? 'N' : 'Y'}')">
                                        ${row.USE_YN eq 'Y' ? '이용중지' : '이용재개'}
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty list}"><tr><td colspan="10" class="admin-empty">조회된 기업이 없습니다.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </article>
    </main>
</div>
<script>window.ctxPath = '<%=request.getContextPath()%>';</script>
<script src="<%=request.getContextPath()%>/js/admin/admin.js"></script>
<script>
function changeCompanyUse(coId, useYn) {
    var message = useYn === 'Y' ? '이 기업의 서비스 이용을 재개하시겠습니까?' : '이 기업의 서비스 이용을 중지하시겠습니까?';
    if (!confirm(message)) return;
    adminPost('/admin/companyUseUpdate.ajax', {coId: coId, useYn: useYn}, function(response) {
        alert(response.msg);
        location.reload();
    });
}
</script>
</body>
</html>
