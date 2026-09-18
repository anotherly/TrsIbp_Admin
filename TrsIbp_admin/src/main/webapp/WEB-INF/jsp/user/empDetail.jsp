<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head><jsp:include page="/WEB-INF/jsp/common/head.jsp"><jsp:param name="dsTitle" value="DevSync - 사용자 상세"/></jsp:include></head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp"><jsp:param name="dsPageTitle" value="사용자 상세"/></jsp:include>
    <main class="ds-page">
        <div class="ds-breadcrumb">회사 관리 &gt; 사용자 관리 &gt; 상세</div>
        <div class="ds-page-head"><div><h1 class="ds-page-title">사용자 상세</h1><p class="ds-page-desc">직원 계정 정보를 조회합니다.</p></div><div class="ds-actions"><button type="button" class="ds-btn ds-btn-outline" data-authority-code="MANAGEMENT_USER_SCREEN" onclick="goEmpList();">목록</button><button type="button" class="ds-btn ds-btn-outline" data-authority-code="MANAGEMENT_USER_DEL" onclick="deleteEmp('${userId}');">삭제</button><button type="button" class="ds-btn ds-btn-primary" data-authority-code="MANAGEMENT_USER_MDFCN_SCREEN" onclick="goEmpUpdate('${userId}');">수정</button></div></div>
        <section class="ds-card ds-card-inner">
            <div class="ds-section-head"><div><h2 class="ds-section-title">기본 정보</h2><p class="ds-section-desc">등록·수정 화면과 같은 배치로 표시되며 상세 화면에서는 변경할 수 없습니다.</p></div></div>
            <div class="ds-emp-form-layout ds-emp-detail-layout">
                <aside class="ds-emp-profile-column">
                    <div class="ds-field">
                        <label>프로필 사진</label>
                        <div class="ds-profile-upload-box">
                            <div id="dispProfilePhoto" class="ds-profile-detail"></div>
                        </div>
                    </div>
                </aside>
                <div class="ds-emp-form-main">
                    <div class="ds-form-12">
                        <div class="ds-field ds-col-6"><label>사용자ID</label><input type="text" id="dispUserId" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-6"><label>사용자명</label><input type="text" id="dispUserNm" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-4"><label>부서</label><input type="text" id="dispDeptNm" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-4"><label>직위</label><input type="text" id="dispJbpsNm" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-4"><label>권한</label><input type="text" id="dispAuthrtNm" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-4"><label>회사</label><input type="text" id="dispCoNm" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-4"><label>전화번호</label><input type="text" id="dispUserTelno" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-4"><label>사용여부</label><input type="text" id="dispUseYn" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-4"><label>등록일</label><input type="text" id="dispRegDt" class="ds-input" readonly></div>
                        <div class="ds-field ds-col-12"><label>메모</label><textarea id="dispMemoCn" class="ds-textarea" readonly></textarea></div>
                    </div>
                    <div class="ds-field ds-emp-attachment-field">
                        <label>증빙 첨부파일</label>
                        <div class="ds-file-upload-box"><div id="dispAttachmentList" class="ds-file-list"></div></div>
                    </div>
                </div>
            </div>
        </section>
    </main>
</div>
<script src="<%=request.getContextPath()%>/js/user/userManage.js"></script>
<script>$(function(){ initEmpDetailPage('${userId}'); });</script>
</body>
</html>
