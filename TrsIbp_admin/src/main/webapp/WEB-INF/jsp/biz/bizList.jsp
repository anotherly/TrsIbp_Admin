<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/common/head.jsp">
        <jsp:param name="dsTitle" value="DevSync - 사업 현황"/>
    </jsp:include>
</head>
<body class="ds-body min-h-screen flex">
<jsp:include page="/WEB-INF/jsp/common/sidebar.jsp"/>

<div class="flex-grow flex flex-col min-h-screen">
    <jsp:include page="/WEB-INF/jsp/common/header.jsp">
        <jsp:param name="dsPageTitle" value="전사 사업 현황판"/>
    </jsp:include>

    <main class="ds-page">
        <div class="ds-breadcrumb">프로젝트/사업 &gt; 전사 사업 현황판</div>

        <div class="ds-page-head">
            <div>
                <h1 class="ds-page-title">사업 현황</h1>
                <p class="ds-page-desc">사업 목록을 조회하고 등록, 수정, 삭제 작업을 수행합니다.</p>
            </div>
            <div class="ds-actions">
                <button type="button" class="ds-btn ds-btn-outline" onclick="resetBizSearch();">검색 초기화</button>
                <button type="button" class="ds-btn ds-btn-primary" data-authority-code="PROJECT_BIZ_REG_SCREEN" onclick="goBizRegist();">+ 사업 등록</button>
            </div>
        </div>

        <section class="ds-summary-grid">
            <div class="ds-summary-card">
                <div class="ds-summary-label">전체 사업 수</div>
                <div id="summaryTotalCnt" class="ds-summary-value">0</div>
                <div class="ds-summary-hint">조회 조건 기준 전체 건수</div>
            </div>
            <div class="ds-summary-card">
                <div class="ds-summary-label">준비</div>
                <div id="summaryReadyCnt" class="ds-summary-value">0</div>
                <div class="ds-summary-hint">공통코드 사업상태 기준</div>
            </div>
            <div class="ds-summary-card">
                <div class="ds-summary-label">진행</div>
                <div id="summaryPrgrsCnt" class="ds-summary-value">0</div>
                <div class="ds-summary-hint">공통코드 사업상태 기준</div>
            </div>
            <div class="ds-summary-card">
                <div class="ds-summary-label">완료</div>
                <div id="summaryCmptnCnt" class="ds-summary-value">0</div>
                <div class="ds-summary-hint">공통코드 사업상태 기준</div>
            </div>
        </section>

        <section class="ds-card ds-card-inner ds-mb-20">
            <div class="ds-section-head">
                <div>
                    <h2 class="ds-section-title">검색 조건</h2>
                    <p class="ds-section-desc">사업코드, 사업명, 발주처, 기관구분, 상태, 착수/종료일로 목록을 필터링합니다.</p>
                </div>
            </div>

            <form id="bizSearchForm" onsubmit="loadBizList(); return false;">
                <div class="ds-search-grid" style="grid-template-columns: minmax(260px, 2fr) repeat(4, minmax(120px, 0.8fr)) repeat(2, minmax(145px, 0.9fr)) minmax(90px, auto) minmax(100px, auto); gap: 14px; align-items: end;">
                    <div class="ds-field">
                        <label for="searchKeyword">통합검색</label>
                        <input type="text" id="searchKeyword" name="searchKeyword" class="ds-input" placeholder="사업코드, 사업명, 발주처">
                    </div>
                    <div class="ds-field">
                        <label for="searchInstSeCd">기관구분</label>
                        <select id="searchInstSeCd" name="searchInstSeCd" class="ds-select">
                            <option value="">전체</option>
                        </select>
                    </div>
                    <div class="ds-field">
                        <label for="searchBizKndCd">사업종류</label>
                        <select id="searchBizKndCd" name="searchBizKndCd" class="ds-select">
                            <option value="">전체</option>
                        </select>
                    </div>
                    <div class="ds-field">
                        <label for="searchBizSeCd">사업성격</label>
                        <select id="searchBizSeCd" name="searchBizSeCd" class="ds-select">
                            <option value="">전체</option>
                        </select>
                    </div>
                    <div class="ds-field">
                        <label for="searchBizSttsCd">상태</label>
                        <select id="searchBizSttsCd" name="searchBizSttsCd" class="ds-select">
                            <option value="">전체</option>
                        </select>
                    </div>
                    <div class="ds-field">
                        <label for="sDate">착수일</label>
                        <input type="text" id="sDate" name="sDate" class="ds-input ds-date-picker" readonly autocomplete="off">
                    </div>
                    <div class="ds-field">
                        <label for="eDate">종료일</label>
                        <input type="text" id="eDate" name="eDate" class="ds-input ds-date-picker" readonly autocomplete="off">
                    </div>
                    <div class="ds-search-actions">
                        <button type="submit" class="ds-btn ds-btn-primary ds-btn-full">검색</button>
                    </div>
                    <div class="ds-search-actions">
                        <button type="button" class="ds-btn ds-btn-outline ds-btn-full" onclick="resetBizSearch();">초기화</button>
                    </div>
                </div>
            </form>
        </section>

        <section class="ds-card ds-card-inner">
            <div class="ds-section-head">
                <div>
                    <h2 class="ds-section-title">사업 목록</h2>
                    <p class="ds-section-desc">데이터가 없어도 테이블 구조는 유지됩니다.</p>
                </div>
            </div>

            <div class="ds-table-wrap">
                <table id="bizTable" class="ds-table display">
                    <thead>
                    <tr>
                        <th>사업코드</th>
                        <th>사업명</th>
                        <th>기관구분</th>
                        <th>발주처</th>
                        <th>사업종류</th>
                        <th>사업성격</th>
                        <th>상태</th>
                        <th>계약금액</th>
                        <th>계약일</th>
                        <th>사업기간</th>
                        <th>관리</th>
                    </tr>
                    </thead>
                    <tbody id="bizListBody"></tbody>
                </table>
            </div>
        </section>
    </main>
</div>

<script>
    var ctxPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/biz/biz.js"></script>
<script>
    $(function() {
        initBizListPage();
    });
</script>
</body>
</html>
