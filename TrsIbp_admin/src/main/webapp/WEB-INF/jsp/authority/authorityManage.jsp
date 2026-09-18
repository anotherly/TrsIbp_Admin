<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync - 역할·권한 관리"/>
    </jsp:include>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/authority/authority.css">
</head>
<body class="ds-body min-h-screen flex">
    <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
    <div class="flex-grow flex flex-col min-h-screen">
        <jsp:include page="/WEB-INF/jsp/common/header.jsp">
            <jsp:param name="dsPageTitle" value="역할·권한 관리"/>
        </jsp:include>
        <main class="ds-authority-page">
            <section class="ds-authority-heading">
                <div>
                    <p class="ds-dashboard-eyebrow">System Settings</p>
                    <h1><i class="fa-solid fa-shield-halved"></i> 역할·권한 관리</h1>
                    <p>역할별 업무공간과 목록·상세·등록·수정·삭제 기능을 설정합니다.</p>
                </div>
                <button type="button" id="btnAuthoritySave" class="ds-btn ds-btn-primary">
                    <i class="fa-solid fa-floppy-disk"></i> 권한 저장
                </button>
            </section>

            <section class="ds-authority-panel">
                <aside class="ds-authority-roles">
                    <div class="ds-authority-section-head">
                        <strong>사용자 권한</strong>
                        <div>
                            <button type="button" id="btnAuthorityEdit" class="ds-text-btn">수정</button>
                            <button type="button" id="btnAuthorityDelete" class="ds-text-btn is-danger">삭제</button>
                        </div>
                    </div>
                    <div id="authorityRoleList" class="ds-authority-role-list"></div>
                    <button type="button" id="btnAuthorityAdd" class="ds-authority-add">
                        <i class="fa-solid fa-plus"></i> 신규 권한 추가
                    </button>
                </aside>

                <section class="ds-authority-menus">
                    <div class="ds-authority-menu-head">
                        <div>
                            <strong id="selectedAuthorityName">권한을 선택해 주세요.</strong>
                            <span id="selectedAuthorityCount">0개 기능 허용</span>
                        </div>
                        <label class="ds-check-label">
                            <input type="checkbox" id="checkAllAuthority"> 전체 선택
                        </label>
                    </div>
                    <div id="authorityMenuList" class="ds-authority-menu-list">
                        <div class="ds-empty">권한 목록을 불러오는 중입니다.</div>
                    </div>
                </section>
            </section>
        </main>
    </div>

    <div id="authorityModal" class="ds-modal-backdrop hidden">
        <section class="ds-modal-panel ds-authority-modal" role="dialog" aria-modal="true" aria-labelledby="authorityModalTitle">
            <div class="ds-modal-header">
                <h2 id="authorityModalTitle">신규 권한 추가</h2>
                <button type="button" id="btnAuthorityModalClose" class="ds-icon-btn"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <form id="authorityForm" class="ds-authority-form">
                <input type="hidden" id="authorityFormMode" value="insert">
                <div class="ds-form-row">
                    <label for="authorityId">권한ID <em>*</em></label>
                    <input type="text" id="authorityId" maxlength="20" placeholder="예: PROJECT_PM">
                </div>
                <div class="ds-form-row">
                    <label for="authorityName">권한명 <em>*</em></label>
                    <input type="text" id="authorityName" maxlength="50" placeholder="예: 프로젝트 관리자">
                </div>
                <div class="ds-form-row">
                    <label for="authorityDescription">권한설명</label>
                    <textarea id="authorityDescription" rows="3" maxlength="200"></textarea>
                </div>
                <div class="ds-modal-actions">
                    <button type="button" id="btnAuthorityModalCancel" class="ds-btn ds-btn-outline">취소</button>
                    <button type="submit" class="ds-btn ds-btn-primary">저장</button>
                </div>
            </form>
        </section>
    </div>

    <script>
        var ctxPath = '<%=request.getContextPath()%>';
    </script>
    <script src="<%=request.getContextPath()%>/js/authority/authorityManage.js"></script>
</body>
</html>
