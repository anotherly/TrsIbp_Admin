<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String mode = request.getParameter("mode");
    if (mode == null) mode = "insert";
%>
<input type="hidden" id="frmBizId" name="bizId" value="<%=request.getParameter("bizId") == null ? "" : request.getParameter("bizId")%>">
<div class="ds-form-grid ds-form-12 biz-basic-form">
    <div class="ds-field ds-col-6">
        <label for="frmBizCd" class="required">사업코드</label>
        <input type="text" id="frmBizCd" class="ds-input" maxlength="30" placeholder="저장 시 자동 생성" readonly>
    </div>
    <div class="ds-field ds-col-6">
        <label for="frmCtrtNo">계약번호</label>
        <input type="text" id="frmCtrtNo" class="ds-input" maxlength="20">
    </div>

    <div class="ds-field ds-col-6">
        <label for="frmBizNm" class="required">사업명</label>
        <input type="text" id="frmBizNm" class="ds-input" maxlength="200">
    </div>
    <div class="ds-field ds-col-6">
        <label for="frmBizAbrvNm">사업약칭</label>
        <input type="text" id="frmBizAbrvNm" class="ds-input" maxlength="100">
    </div>

    <div class="ds-field ds-col-6">
        <label for="frmInstSeCd" class="required">민간/공공</label>
        <select id="frmInstSeCd" class="ds-select"><option value="">선택</option></select>
    </div>
    <div class="ds-field ds-col-6">
        <label for="frmBizKndCd" class="required">사업종류</label>
        <select id="frmBizKndCd" class="ds-select"><option value="">선택</option></select>
    </div>

    <div class="ds-field ds-col-6">
        <label for="frmBizSttsCd" class="required">사업상태</label>
        <select id="frmBizSttsCd" class="ds-select"><option value="">선택</option></select>
    </div>
    <div class="ds-field ds-col-6">
        <label for="frmBizSeCd" class="required">사업성격</label>
        <select id="frmBizSeCd" class="ds-select"><option value="">선택</option></select>
    </div>

    <div class="ds-field ds-col-12">
        <label for="frmOrdplNm">발주처</label>
        <input type="text" id="frmOrdplNm" class="ds-input" maxlength="100">
    </div>

    <div class="ds-field ds-col-4">
        <label for="frmCtrtYmd">계약일</label>
        <input type="text" id="frmCtrtYmd" class="ds-input ds-date-picker ready-disabled-field" readonly autocomplete="off">
    </div>
    <div class="ds-field ds-col-4">
        <label for="frmOtstYmd">착수일</label>
        <input type="text" id="frmOtstYmd" class="ds-input ds-date-picker ready-disabled-field" readonly autocomplete="off">
    </div>
    <div class="ds-field ds-col-4">
        <label for="frmBizEndYmd">사업종료일</label>
        <input type="text" id="frmBizEndYmd" class="ds-input ds-date-picker ready-disabled-field" readonly autocomplete="off">
    </div>
    
    <div class="ds-field ds-col-4">
        <label for="frmCtrtAmt">계약금액</label>
        <input type="text" id="frmCtrtAmt" class="ds-input ds-number-input ready-disabled-field" inputmode="numeric" autocomplete="off">
    </div>
    <div class="ds-field ds-col-4">
        <label for="frmVatInclYn">VAT구분</label>
        <select id="frmVatInclYn" class="ds-select ready-disabled-field">
            <option value="">선택</option>
            <option value="Y">VAT포함</option>
            <option value="N">VAT별도</option>
        </select>
    </div>
    <div class="ds-field ds-col-4">
        <label for="frmGiveDdtYmd">지급기일</label>
        <input type="text" id="frmGiveDdtYmd" class="ds-input ds-date-picker ready-disabled-field" readonly autocomplete="off">
    </div>

    <div class="ds-field ds-col-12 ready-disabled-field-wrap">
        <label>대금지급방법</label>
        <div class="ds-table-wrap">
            <table class="ds-table ds-table-compact ds-pay-table">
                <thead><tr><th>대금지급방법</th><th>대금지급방법상세</th><th>관리</th></tr></thead>
                <tbody id="bizGiveMthdEditBody"></tbody>
            </table>
        </div>
        <div class="ds-form-actions ds-form-actions-right ds-mt-10">
            <button type="button" class="ds-btn ds-btn-outline ready-disabled-field" onclick="addBizGiveMthdRow();">+ 추가</button>
        </div>
    </div>

    <div class="ds-field ds-col-6">
        <label for="frmDfrpGrnteBgngYmd">하자보증시작일</label>
        <input type="text" id="frmDfrpGrnteBgngYmd" class="ds-input ds-date-picker ready-disabled-field" readonly autocomplete="off">
    </div>
    <div class="ds-field ds-col-6">
        <label for="frmDfrpGrnteEndYmd">하자보증종료일</label>
        <input type="text" id="frmDfrpGrnteEndYmd" class="ds-input ds-date-picker ready-disabled-field" readonly autocomplete="off">
    </div>

    <div class="ds-field ds-col-12">
        <label for="frmRmrkCn">기타사항</label>
        <textarea id="frmRmrkCn" class="ds-textarea" maxlength="1000"></textarea>
    </div>
</div>
