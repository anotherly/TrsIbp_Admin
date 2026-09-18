<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync - 사용자 관리"/>
    </jsp:include>
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>
<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp">
        <jsp:param name="dsPageTitle" value="사용자 관리"/>
    </jsp:include>
    <main class="ds-page">
        <div class="ds-breadcrumb">회사 관리 &gt; 사용자 관리</div>
        <div class="ds-page-head">
            <div>
                <h1 class="ds-page-title">사용자 관리</h1>
                <p class="ds-page-desc">로그인 사용자 회사의 직원 계정을 조회하고 등록, 상세, 수정, 삭제 작업을 수행합니다.</p>
            </div>
            <div class="ds-actions">
                <button type="button" class="ds-btn ds-btn-outline" onclick="resetEmpSearch();">검색 초기화</button>
                <button type="button" class="ds-btn ds-btn-primary" data-authority-code="MANAGEMENT_USER_REG_SCREEN" onclick="goEmpInsert();">+ 사용자 등록</button>
            </div>
        </div>

        <section class="ds-card ds-card-inner ds-mb-20">
            <div class="ds-section-head">
                <div>
                    <h2 class="ds-section-title">검색 조건</h2>
                    <p class="ds-section-desc">사용자ID, 사용자명, 부서, 직위, 전화번호 기준으로 검색합니다.</p>
                </div>
            </div>
            <form id="empSearchForm" onsubmit="loadEmpList(); return false;">
                <div class="ds-form-12">
                    <div class="ds-field ds-col-6">
                        <label for="empSearchKeyword">통합검색</label>
                        <input type="text" id="empSearchKeyword" name="searchKeyword" class="ds-input" placeholder="사용자ID, 사용자명, 부서, 직위, 전화번호">
                    </div>
                    <div class="ds-field ds-col-3">
                        <label for="empSearchDeptId">부서</label>
                        <select id="empSearchDeptId" name="deptId" class="ds-select"><option value="">전체</option></select>
                    </div>
                    <div class="ds-field ds-col-2">
                        <label for="empSearchUseYn">사용여부</label>
                        <select id="empSearchUseYn" name="useYn" class="ds-select">
                            <option value="">전체</option>
                            <option value="Y">사용</option>
                            <option value="N">미사용</option>
                        </select>
                    </div>
                    <div class="ds-search-actions ds-col-1">
                        <button type="submit" class="ds-btn ds-btn-primary">검색</button>
                    </div>
                </div>
            </form>
        </section>

        <section class="ds-card ds-card-inner">
            <div class="ds-section-head">
                <div>
                    <h2 class="ds-section-title">사용자 목록</h2>
                    <p class="ds-section-desc">사용자명을 클릭하면 상세 화면으로 이동합니다.</p>
                </div>
            </div>
            <div class="ds-table-wrap">
                <table id="empTable" class="ds-table">
                    <thead>
                    <tr>
                        <th>사용자ID</th>
                        <th>사용자명</th>
                        <th>부서</th>
                        <th>직위</th>
                        <th>권한</th>
                        <th>전화번호</th>
                        <th>사용여부</th>
                        <th>등록일</th>
                        <th>관리</th>
                    </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </section>
    </main>
</div>
<script src="<%=request.getContextPath()%>/js/user/userManage.js"></script>
<script>$(function(){ initEmpListPage(); });</script>
</body>
</html>
