<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync System Admin - 공통코드·운영정책"/></jsp:include>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin.css">
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen min-w-0">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="공통코드·운영정책"/></jsp:include>
    <main class="admin-main">
        <div class="admin-page-heading"><div><h1>공통코드·운영정책</h1><p>전사 공통코드의 사용여부와 관리자 사이트 운영문구·기준값을 관리합니다.</p></div></div>
        <div class="admin-notice">
            <i class="fa-solid fa-triangle-exclamation mt-0.5"></i>
            <span>사용 중인 공통코드를 중지하면 기존 업무 화면의 선택값에 영향을 줄 수 있습니다. 변경 전 해당 코드의 사용 위치를 확인해 주세요.</span>
        </div>

        <section class="admin-two-column">
            <article class="admin-card">
                <div class="admin-card-header"><div><h2>공통코드</h2><small>코드그룹을 선택해 조회합니다.</small></div></div>
                <form method="get" action="<%=request.getContextPath()%>/admin/operationPolicy.do" class="p-4 border-b border-slate-800">
                    <div class="admin-filter-grid" style="grid-template-columns:minmax(240px,1fr) auto">
                        <div class="admin-filter-field">
                            <label for="cdGroupId">코드그룹</label>
                            <select class="admin-select" id="cdGroupId" name="cdGroupId">
                                <c:forEach var="group" items="${groupList}">
                                    <option value="<c:out value="${group.CD_GROUP_ID}"/>" ${search.cdGroupId eq group.CD_GROUP_ID ? 'selected' : ''}>
                                        <c:out value="${group.CD_GROUP_NM}"/> (<c:out value="${group.CD_GROUP_ID}"/>)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="admin-filter-actions"><button class="admin-btn primary" type="submit">조회</button></div>
                    </div>
                </form>
                <div class="admin-table-wrap">
                    <table class="admin-table">
                        <thead><tr><th>코드</th><th>코드명</th><th>설명</th><th>기본</th><th>상태</th><th class="is-right">관리</th></tr></thead>
                        <tbody>
                            <c:forEach var="row" items="${codeList}">
                                <tr>
                                    <td><c:out value="${row.CD}"/></td>
                                    <td><strong class="text-slate-200"><c:out value="${row.CD_NM}"/></strong></td>
                                    <td><c:out value="${row.CD_EXPLN}" default="-"/></td>
                                    <td><c:out value="${row.DFLT_YN}"/></td>
                                    <td><span class="admin-status ${row.USE_YN eq 'Y' ? 'y' : 'n'}">${row.USE_YN eq 'Y' ? '사용' : '중지'}</span></td>
                                    <td class="is-right">
                                        <button type="button" class="admin-btn ${row.USE_YN eq 'Y' ? 'danger' : 'success'}"
                                            onclick="changeCodeUse('<c:out value="${row.CD_GROUP_ID}"/>','<c:out value="${row.CD}"/>','${row.USE_YN eq 'Y' ? 'N' : 'Y'}')">
                                            ${row.USE_YN eq 'Y' ? '중지' : '사용'}
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty codeList}"><tr><td colspan="6" class="admin-empty">조회된 공통코드가 없습니다.</td></tr></c:if>
                        </tbody>
                    </table>
                </div>
            </article>

            <article class="admin-card">
                <div class="admin-card-header"><div><h2>운영정책</h2><small>각 항목을 독립적으로 저장합니다.</small></div></div>
                <div class="admin-policy-list">
                    <c:forEach var="row" items="${policyList}">
                        <div class="admin-policy-item">
                            <div class="admin-policy-copy">
                                <strong><c:out value="${row.POLICY_NM}"/></strong>
                                <small><c:out value="${row.POLICY_EXPLN}"/></small>
                            </div>
                            <div class="admin-filter-field">
                                <label for="policy_${row.POLICY_ID}">정책값</label>
                                <input class="admin-input" id="policy_${row.POLICY_ID}" maxlength="1000" value="<c:out value="${row.POLICY_VALUE}"/>">
                            </div>
                            <div class="admin-filter-actions">
                                <button type="button" class="admin-btn primary"
                                    onclick="savePolicy('<c:out value="${row.POLICY_ID}"/>')">저장</button>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </article>
        </section>
    </main>
</div>
<script>window.ctxPath = '<%=request.getContextPath()%>';</script>
<script src="<%=request.getContextPath()%>/js/admin/admin.js"></script>
<script>
function changeCodeUse(cdGroupId, cd, useYn) {
    if (!confirm('공통코드 사용상태를 변경하시겠습니까?')) return;
    adminPost('/admin/commonCodeUseUpdate.ajax', {
        cdGroupId: cdGroupId,
        cd: cd,
        useYn: useYn
    }, function(response) {
        alert(response.msg);
        location.reload();
    });
}

function savePolicy(policyId) {
    var input = document.getElementById('policy_' + policyId);
    if (!input) return;
    if (!confirm('이 운영정책 값을 저장하시겠습니까?')) return;
    adminPost('/admin/operationPolicyUpdate.ajax', {
        policyId: policyId,
        policyValue: input.value
    }, function(response) {
        alert(response.msg);
        location.reload();
    });
}
</script>
</body>
</html>
