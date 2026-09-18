<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync System Admin - 기업가입 승인"/>
    </jsp:include>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin/admin.css">
</head>
<body class="ds-body min-h-screen flex">
    <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
    <div class="flex-grow flex flex-col min-h-screen min-w-0">
        <jsp:include page="/WEB-INF/jsp/common/header.jsp">
            <jsp:param name="dsPageTitle" value="기업가입 승인"/>
        </jsp:include>
        <main class="admin-main">
            <div class="admin-page-heading">
                <div><h1>기업가입 신청 관리</h1><p>DB에 접수된 기업 사용신청을 검토하고 승인 또는 반려합니다.</p></div>
            </div>

            <div class="admin-notice">
                <i class="fa-solid fa-circle-info mt-0.5"></i>
                <span>승인 시 기업 마스터가 생성됩니다. 로그인 계정은 임의 생성하지 않으며, 승인된 기업의 사용자가 별도 회원 등록 절차를 진행합니다.</span>
            </div>

            <form class="admin-card admin-filter" method="get" action="<%=request.getContextPath()%>/admin/companyRequestList.do">
                <div class="admin-filter-grid">
                    <div class="admin-filter-field">
                        <label for="prcsSttsCd">처리상태</label>
                        <select class="admin-select" id="prcsSttsCd" name="prcsSttsCd">
                            <option value="">전체</option>
                            <option value="WAIT" ${search.prcsSttsCd eq 'WAIT' ? 'selected' : ''}>승인 대기</option>
                            <option value="APPR" ${search.prcsSttsCd eq 'APPR' ? 'selected' : ''}>승인</option>
                            <option value="REJECT" ${search.prcsSttsCd eq 'REJECT' ? 'selected' : ''}>반려</option>
                        </select>
                    </div>
                    <div class="admin-filter-field">
                        <label for="searchValue">기업명·사업자번호·신청자·이메일</label>
                        <input class="admin-input" id="searchValue" name="searchValue" value="<c:out value="${search.searchValue}"/>" placeholder="검색어를 입력하세요">
                    </div>
                    <div class="admin-filter-actions">
                        <button class="admin-btn primary" type="submit"><i class="fa-solid fa-magnifying-glass"></i> 조회</button>
                        <a class="admin-btn ghost" href="<%=request.getContextPath()%>/admin/companyRequestList.do">초기화</a>
                    </div>
                </div>
            </form>

            <article class="admin-card">
                <div class="admin-card-header"><div><h2>기업가입 신청 목록</h2><small>최대 200건 표시</small></div></div>
                <div class="admin-table-wrap">
                    <table class="admin-table">
                        <thead>
                            <tr><th>신청번호</th><th>기업명</th><th>사업자번호</th><th>신청자</th><th>대표자</th><th>신청일</th><th>상태</th><th>처리자</th><th class="is-right">상세/처리</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="row" items="${list}">
                                <tr>
                                    <td><c:out value="${row.APLY_SN}"/></td>
                                    <td><strong class="text-slate-200"><c:out value="${row.CO_NM}"/></strong></td>
                                    <td><c:out value="${row.BRNO}"/></td>
                                    <td><c:out value="${row.APLCNT_NM}"/></td>
                                    <td><c:out value="${row.RPRSV_NM}"/></td>
                                    <td><c:out value="${row.REG_DT}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${row.PRCS_STTS_CD eq 'APPR'}"><span class="admin-status appr">승인</span></c:when>
                                            <c:when test="${row.PRCS_STTS_CD eq 'REJECT'}"><span class="admin-status reject">반려</span></c:when>
                                            <c:otherwise><span class="admin-status wait">대기</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><c:out value="${row.PRCS_USER_ID}" default="-"/></td>
                                    <td class="is-right"><button type="button" class="admin-btn" onclick="showRequestDetail('${row.APLY_SN}')">상세/처리</button></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty list}">
                                <tr><td colspan="9" class="admin-empty">조회된 기업가입 신청이 없습니다.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </article>
        </main>
    </div>

    <div class="admin-modal" id="requestDetailModal">
        <div class="admin-modal-panel">
            <div class="admin-modal-header">
                <h3>기업가입 신청 상세</h3>
                <button type="button" class="admin-btn ghost" onclick="closeAdminModal('requestDetailModal')"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="admin-modal-body">
                <dl class="admin-detail-grid" id="requestDetailBody"></dl>
            </div>
            <div class="admin-modal-footer" id="requestDetailActions"></div>
        </div>
    </div>

    <div class="admin-modal" id="rejectModal">
        <div class="admin-modal-panel" style="max-width:560px">
            <div class="admin-modal-header">
                <h3>기업가입 신청 반려</h3>
                <button type="button" class="admin-btn ghost" onclick="closeAdminModal('rejectModal')"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="admin-modal-body">
                <label class="block text-xs font-bold text-slate-400 mb-2" for="rejectReason">반려사유 <span class="text-red-400">*</span></label>
                <textarea class="admin-textarea" id="rejectReason" maxlength="500" placeholder="신청자가 보완해야 할 내용을 구체적으로 입력하세요."></textarea>
            </div>
            <div class="admin-modal-footer">
                <button type="button" class="admin-btn ghost" onclick="closeAdminModal('rejectModal')">취소</button>
                <button type="button" class="admin-btn danger" onclick="submitReject()">반려 처리</button>
            </div>
        </div>
    </div>

    <script>window.ctxPath = '<%=request.getContextPath()%>'; var selectedAplySn = null;</script>
    <script src="<%=request.getContextPath()%>/js/admin/admin.js"></script>
    <script>
        function detailItem(label, value, wide) {
            var item = document.createElement('div');
            item.className = 'admin-detail-item' + (wide ? ' is-wide' : '');
            var dt = document.createElement('dt');
            var dd = document.createElement('dd');
            dt.textContent = label;
            dd.textContent = adminText(value);
            item.appendChild(dt);
            item.appendChild(dd);
            return item;
        }

        function showRequestDetail(aplySn) {
            selectedAplySn = aplySn;
            adminPost('/admin/companyRequestDetail.ajax', {aplySn: aplySn}, function(response) {
                var detail = response.detail;
                var body = document.getElementById('requestDetailBody');
                body.innerHTML = '';
                body.appendChild(detailItem('기업명', detail.CO_NM));
                body.appendChild(detailItem('사업자등록번호', detail.BRNO));
                body.appendChild(detailItem('신청자', detail.APLCNT_NM));
                body.appendChild(detailItem('대표자', detail.RPRSV_NM));
                body.appendChild(detailItem('담당자 연락처', detail.PIC_TELNO));
                body.appendChild(detailItem('담당자 이메일', detail.PIC_EML_ADDR));
                body.appendChild(detailItem('신청일시', detail.REG_DT));
                body.appendChild(detailItem('처리상태', detail.PRCS_STTS_CD));
                if (detail.RJCT_RSN) body.appendChild(detailItem('반려사유', detail.RJCT_RSN, true));
                if (detail.ORGNL_FILE_NM) {
                    var fileItem = detailItem('첨부서류', detail.ORGNL_FILE_NM, true);
                    var link = document.createElement('a');
                    link.className = 'admin-btn ghost mt-2';
                    link.href = window.ctxPath + '/admin/companyRequestFile.do?aplySn=' + encodeURIComponent(aplySn);
                    link.textContent = '첨부서류 다운로드';
                    fileItem.querySelector('dd').appendChild(document.createElement('br'));
                    fileItem.querySelector('dd').appendChild(link);
                    body.appendChild(fileItem);
                }

                var actions = document.getElementById('requestDetailActions');
                actions.innerHTML = '';
                var closeButton = document.createElement('button');
                closeButton.type = 'button';
                closeButton.className = 'admin-btn ghost';
                closeButton.textContent = '닫기';
                closeButton.onclick = function() { closeAdminModal('requestDetailModal'); };
                actions.appendChild(closeButton);
                if (detail.PRCS_STTS_CD === 'WAIT') {
                    var rejectButton = document.createElement('button');
                    rejectButton.type = 'button';
                    rejectButton.className = 'admin-btn danger';
                    rejectButton.textContent = '반려';
                    rejectButton.onclick = openReject;
                    actions.appendChild(rejectButton);
                    var approveButton = document.createElement('button');
                    approveButton.type = 'button';
                    approveButton.className = 'admin-btn success';
                    approveButton.textContent = '승인';
                    approveButton.onclick = submitApprove;
                    actions.appendChild(approveButton);
                }
                openAdminModal('requestDetailModal');
            });
        }

        function submitApprove() {
            if (!confirm('이 신청을 승인하고 기업 마스터를 생성하시겠습니까?')) return;
            adminPost('/admin/companyRequestApprove.ajax', {aplySn: selectedAplySn}, function(response) {
                alert(response.msg + '\n생성 기업ID: ' + response.coId);
                location.reload();
            });
        }

        function openReject() {
            document.getElementById('rejectReason').value = '';
            closeAdminModal('requestDetailModal');
            openAdminModal('rejectModal');
        }

        function submitReject() {
            var reason = document.getElementById('rejectReason').value.trim();
            if (!reason) {
                alert('반려사유를 입력해 주세요.');
                return;
            }
            if (!confirm('이 신청을 반려하시겠습니까?')) return;
            adminPost('/admin/companyRequestReject.ajax', {
                aplySn: selectedAplySn,
                rjctRsn: reason
            }, function(response) {
                alert(response.msg);
                location.reload();
            });
        }
    </script>
</body>
</html>
