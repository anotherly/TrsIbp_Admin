<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div id="deptSelectModal" class="ds-modal hidden" aria-hidden="true">
    <div class="ds-modal-dim" onclick="closeDeptSelectModal();"></div>
    <div class="ds-modal-panel ds-user-modal-panel" role="dialog" aria-modal="true" aria-labelledby="deptSelectModalTitle">
        <div class="ds-modal-head">
            <div>
                <h3 id="deptSelectModalTitle" class="ds-modal-title">부서 선택</h3>
                <p class="ds-modal-desc">회사 조직 구조에서 실제 소속 부서를 선택합니다.</p>
            </div>
            <button type="button" class="ds-modal-close" onclick="closeDeptSelectModal();" title="닫기">×</button>
        </div>
        <div class="ds-user-search-row">
            <input type="text" id="deptSelectKeyword" class="ds-input" placeholder="본부, 부서, 팀명 검색">
            <button type="button" class="ds-btn ds-btn-outline" onclick="loadDeptSelectList();">검색</button>
        </div>
        <div class="ds-user-picker ds-dept-picker">
            <div class="ds-user-dept-box">
                <div class="ds-user-box-title">상위 조직</div>
                <div id="deptSelectTreeList" class="ds-user-dept-list"></div>
            </div>
            <div class="ds-user-list-box">
                <div class="ds-user-box-title">선택 가능 부서</div>
                <div id="deptSelectLeafList" class="ds-user-list"></div>
            </div>
        </div>
    </div>
</div>
