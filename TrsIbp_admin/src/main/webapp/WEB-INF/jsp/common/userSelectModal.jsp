<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div id="userSelectModal" class="ds-modal hidden" aria-hidden="true">
    <div class="ds-modal-dim" onclick="closeUserSelectModal();"></div>
    <div class="ds-modal-panel ds-user-modal-panel" role="dialog" aria-modal="true" aria-labelledby="userSelectModalTitle">
        <div class="ds-modal-head">
            <div>
                <h3 id="userSelectModalTitle" class="ds-modal-title">사용자 선택</h3>
                <p class="ds-modal-desc">로그인 사용자 회사의 부서와 사용자를 조회합니다.</p>
            </div>
            <button type="button" class="ds-modal-close" onclick="closeUserSelectModal();" title="닫기">×</button>
        </div>
        <div class="ds-user-search-row">
            <input type="text" id="userSelectKeyword" class="ds-input" placeholder="사용자명, 사용자ID, 부서명 검색">
            <button type="button" class="ds-btn ds-btn-outline" onclick="loadUserSelectList();">검색</button>
        </div>
        <div class="ds-user-picker">
            <div class="ds-user-dept-box">
                <div class="ds-user-box-title">부서</div>
                <div id="userSelectDeptList" class="ds-user-dept-list"></div>
            </div>
            <div class="ds-user-list-box">
                <div class="ds-user-box-title">사용자</div>
                <div id="userSelectUserList" class="ds-user-list"></div>
            </div>
        </div>
        <div id="userSelectMultiFooter" class="ds-modal-actions ds-user-multi-actions hidden">
            <div id="userSelectMultiSummary" class="ds-modal-summary">선택된 사용자 0명</div>
            <button type="button" class="ds-btn ds-btn-primary" onclick="applyMultiSelectedUsers();">선택완료</button>
        </div>
    </div>
</div>
