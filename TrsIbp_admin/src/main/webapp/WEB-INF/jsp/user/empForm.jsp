<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Object modeAttribute = request.getAttribute("mode");
    String mode = modeAttribute == null ? request.getParameter("mode") : String.valueOf(modeAttribute);
    boolean insert = "insert".equals(mode);
    Object updateTokenAttribute = request.getAttribute("updateToken");
    String updateToken = updateTokenAttribute == null ? request.getParameter("updateToken") : String.valueOf(updateTokenAttribute);
    if (updateToken == null) {
        updateToken = "";
    }
%>
<section class="ds-card ds-card-inner">
    <div class="ds-section-head"><div><h2 class="ds-section-title">기본 정보</h2><p class="ds-section-desc">필수값은 빨간색 * 항목입니다.</p></div></div>
    <form id="empForm" enctype="multipart/form-data" onsubmit="saveEmp(); return false;">
        <input type="hidden" id="frmSaveMode" name="saveMode" value="<%=mode%>">
        <input type="hidden" id="frmUpdateToken" name="updateToken" value="<%=updateToken%>">
        <div class="ds-emp-form-layout">
            <aside class="ds-emp-profile-column">
                <div class="ds-field">
                <label>프로필 사진</label>
                <div class="ds-profile-upload-box">
                    <div class="ds-profile-preview-wrap">
                        <img id="empProfilePreview" class="ds-profile-preview" src="<%=request.getContextPath()%>/images/default-profile.svg" alt="프로필 사진 미리보기">
                    </div>
                    <div class="ds-profile-upload-actions">
                        <input type="file" id="frmProfileFile" name="profileFile" class="ds-file-input-hidden" accept="image/jpeg,image/png,image/gif">
                        <button type="button" class="ds-btn ds-btn-outline ds-upload-select-btn" onclick="document.getElementById('frmProfileFile').click();"><i class="fa-solid fa-camera"></i> 사진 선택</button>
                        <span id="empProfileFileName" class="ds-upload-file-summary">선택된 파일 없음</span>
                        <button type="button" id="btnDeleteProfileFile" class="ds-mini-btn ds-mini-btn-danger hidden" onclick="deleteCurrentEmpProfile();">기존 사진 삭제</button>
                    </div>
                </div>
                <p class="ds-field-help">JPG·PNG·GIF, 5MB 이하</p>
                </div>
            </aside>
            <div class="ds-emp-form-main">
                <div class="ds-form-12">
                    <div class="ds-field ds-col-6"><label class="required">사용자ID</label><div class="ds-input-button ds-user-id-check-row"><input type="text" id="frmUserId" name="userId" class="ds-input" maxlength="20" <%=insert ? "" : "readonly"%> placeholder="영문 소문자·숫자 6~20자"><% if (insert) { %><button type="button" id="btnEmpIdCheck" class="ds-btn ds-btn-outline" onclick="checkEmpUserId();">중복확인</button><span id="empIdCheckMessage" class="ds-id-check-message" aria-live="polite"></span><% } %></div></div>
                    <div class="ds-field ds-col-6"><label class="required">사용자명</label><input type="text" id="frmUserNm" name="userNm" class="ds-input" maxlength="100"></div>
                    <div class="ds-field ds-col-4"><label class="ds-field-label-row"><span>부서</span><span class="ds-label-help">소속 조직이 정해지지 않은 사용자는 비워둘 수 있습니다.</span></label><input type="hidden" id="frmDeptId" name="deptId"><div class="ds-input-button"><input type="text" id="frmDeptNm" class="ds-input" readonly placeholder="미지정"><button type="button" class="ds-btn ds-btn-outline" onclick="openEmpDeptSelectModal();">선택</button><button type="button" class="ds-btn ds-btn-outline" onclick="clearEmpDeptSelection();">해제</button></div></div>
                    <div class="ds-field ds-col-4"><label>직위</label><input type="text" id="frmJbpsNm" name="jbpsNm" class="ds-input" maxlength="50" placeholder="과장, 차장 등"></div>
                    <div class="ds-field ds-col-4"><label class="required">권한</label><select id="frmAuthrtId" name="authrtId" class="ds-select"><option value="">선택</option></select></div>
                    <div class="ds-field ds-col-4"><label class="<%=insert ? "required" : ""%>"><%=insert ? "초기 비밀번호" : "비밀번호 변경"%></label><input type="password" id="frmUserEnpswd" name="userEnpswd" class="ds-input" maxlength="100" autocomplete="new-password" placeholder="<%=insert ? "필수 입력" : "변경 시에만 입력"%>"></div>
                    <div class="ds-field ds-col-4"><label>전화번호</label><input type="text" id="frmUserTelno" name="userTelno" class="ds-input" maxlength="20" placeholder="01012345678"></div>
                    <div class="ds-field ds-col-4"><label>사용여부</label><select id="frmUseYn" name="useYn" class="ds-select"><option value="Y">사용</option><option value="N">미사용</option></select></div>
                    <div class="ds-field ds-col-12"><label>메모</label><textarea id="frmMemoCn" name="memoCn" class="ds-textarea" maxlength="500"></textarea></div>
                </div>
                <div class="ds-field ds-emp-attachment-field">
                    <label>증빙 첨부파일</label>
                    <div class="ds-file-upload-box">
                        <div class="ds-upload-toolbar">
                            <input type="file" id="frmUserFiles" name="userFiles" class="ds-file-input-hidden" multiple>
                            <button type="button" class="ds-btn ds-btn-outline ds-upload-select-btn" onclick="document.getElementById('frmUserFiles').click();"><i class="fa-solid fa-paperclip"></i> 파일 선택</button>
                            <span id="empUserFileSummary" class="ds-upload-file-summary">선택된 파일 없음</span>
                        </div>
                        <p class="ds-field-help">통장사본, 졸업증명서, 주민등록등본 등 기존 파일 포함 최대 10개 · 파일당 10MB 이하</p>
                        <div id="empSelectedFileList" class="ds-file-list"></div>
                        <div id="empExistingFileList" class="ds-file-list"></div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</section>
