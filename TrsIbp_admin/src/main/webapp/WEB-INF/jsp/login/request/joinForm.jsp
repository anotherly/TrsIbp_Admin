<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevSync - 일반회원가입</title>
    <script src="${pageContext.request.contextPath}/protoType/saved_resource"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: {
                            dark: '#0b0f19',
                            card: '#111827',
                            border: '#1f2937',
                            accent: '#3b82f6',
                            neonBlue: '#00d2ff',
                            neonGreen: '#10b981'
                        }
                    }
                }
            }
        }
    </script>
    <style>
        .input-style:focus {
            outline: none;
            border-color: #00d2ff;
            box-shadow: 0 0 0 3px rgba(0, 210, 255, 0.15);
        }
        /* 커스텀 스크롤바 */
        .company-list-box::-webkit-scrollbar { width: 4px; }
        .company-list-box::-webkit-scrollbar-thumb { background: #1f2937; border-radius: 2px; }
    </style>
</head>
<body class="bg-[#0b0f19] text-[#f3f4f6] min-h-screen flex items-center justify-center p-4">

    <div class="bg-[#111827] border border-[#1f2937] rounded-2xl w-full max-w-lg p-8 shadow-2xl relative">
        
        <a href="${pageContext.request.contextPath}/login/gateway.do" class="absolute top-6 left-6 text-xs text-gray-400 hover:text-brand-neonBlue transition">
            <i class="fa-solid fa-arrow-left mr-1"></i> 이전 단계로
        </a>

        <div class="text-center mb-8 mt-4">
            <h3 class="text-xl font-bold text-white mb-2">
                <i class="fa-solid fa-user-plus text-brand-accent mr-2"></i>일반회원가입
            </h3>
            <p class="text-xs text-gray-400">소속 회사를 인증한 후 사원 계정 정보를 입력해 주세요.</p>
        </div>

        <form id="joinForm" method="POST" class="space-y-4">
            
            <div class="p-4 bg-slate-950/40 border border-brand-border rounded-xl space-y-3">
                <label class="block text-xs font-bold text-brand-neonBlue uppercase tracking-wider">
                    <i class="fa-solid fa-magnifying-glass-location mr-1"></i> 소속 회사 검색 및 선택 *
                </label>
                <div class="flex gap-2">
                    <input type="text" id="searchValue"
                           onkeyup="if(window.event.keyCode==13){searchCompany()}"
                           class="input-style flex-grow bg-slate-900 border border-brand-border text-xs rounded-lg p-2.5 text-gray-100"
                           placeholder="회사명을 입력하세요 (예: 쓰리알솔루션)">
                           
                    <button type="button" onclick="searchCompany()"
                            class="px-4 py-2.5 bg-slate-800 hover:bg-slate-700 border border-brand-border text-xs font-bold rounded-lg transition text-gray-200">
                        검색
                    </button>
                </div>
        
                <div id="companyListContainer" class="company-list-box hidden max-h-40 overflow-y-auto bg-slate-900 border border-brand-border rounded-lg p-1 space-y-1"></div>
                
                <div id="selectedCompanyCard" class="hidden p-3 bg-brand-accent/5 border border-brand-accent/30 rounded-lg flex items-center justify-between">
                    <div>
                        <span id="selectedCoNm" class="text-xs font-bold text-white block"></span>
                        <span id="selectedCoIdDisplay" class="text-[10px] text-gray-500 block font-mono"></span>
                    </div>
                    <span class="text-[10px] bg-brand-accent/20 text-brand-neonBlue px-2 py-0.5 rounded font-bold">선택완료</span>
                </div>

                <input type="hidden" id="coId" name="coId" required>
            </div>

            <div class="space-y-4">
                <div>
				    <label class="block text-xs font-bold text-gray-400 mb-1.5">사용자 ID *</label>
                    <div class="flex gap-2">
				        <input type="text" name="userId" id="userId" data-valid="userid" maxlength="20" required autocomplete="one-time-code" class="input-style flex-grow bg-slate-900 border border-brand-border text-xs rounded-lg p-2.5 text-gray-100" placeholder="영문 소문자·숫자 6~20자">
                        <button type="button" id="btnJoinUserIdCheck" onclick="checkJoinUserId()" class="px-4 py-2.5 bg-slate-800 hover:bg-slate-700 border border-brand-border text-xs font-bold rounded-lg transition text-gray-200">중복확인</button>
                    </div>
                    <p id="joinUserIdCheckMessage" class="mt-1 text-[11px] text-gray-400"></p>
				</div>

                <div>
                    <label class="block text-xs font-bold text-gray-400 mb-1.5">비밀번호 *</label>
                    <input type="password" name="userEnpswd" id="userEnpswd" data-valid="password" required class="input-style w-full bg-slate-900 border border-brand-border text-xs rounded-lg p-2.5 text-gray-100" placeholder="비밀번호(영문,특수,숫자 조합 8~15자)">
                </div>

                <div>
                    <label class="block text-xs font-bold text-gray-400 mb-1.5">성명 (이름) *</label>
                    <input type="text" name="userNm" id="userNm" maxlength="20" required class="input-style w-full bg-slate-900 border border-brand-border text-xs rounded-lg p-2.5 text-gray-100" placeholder="홍길동">
                </div>

                <div>
                    <label class="block text-xs font-bold text-gray-400 mb-1.5">소속 부서 *</label>
                    <input type="hidden" name="deptId" id="deptId" required>
                    <div class="flex gap-2">
                        <input type="text" id="deptNm" readonly required class="input-style flex-grow bg-slate-900 border border-brand-border text-xs rounded-lg p-2.5 text-gray-100" placeholder="소속 회사를 선택한 후 부서를 선택하세요">
                        <button type="button" onclick="openJoinDeptSelectModal()" class="px-4 py-2.5 bg-slate-800 hover:bg-slate-700 border border-brand-border text-xs font-bold rounded-lg transition text-gray-200">부서선택</button>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-gray-400 mb-1.5">직급 / 직책</label>
                    <input type="text" name="jbpsNm" id="jbpsNm" maxlength="15" class="input-style w-full bg-slate-900 border border-brand-border text-xs rounded-lg p-2.5 text-gray-100" placeholder="예: 대리 / 팀원">
                </div>

                <div>
                    <label class="block text-xs font-bold text-gray-400 mb-1.5">연락처 번호</label>
                    <input type="tel" name="userTelno" id="userTelno" data-valid="phone" maxlength="11" class="input-style w-full bg-slate-900 border border-brand-border text-xs rounded-lg p-2.5 text-gray-100" placeholder="01012345678">
                </div>
            </div>

            <button type="button" onclick="submitJoinForm()" class="w-full mt-4 py-3 bg-brand-accent hover:bg-blue-600 text-white rounded-xl text-sm font-bold shadow-lg shadow-brand-accent/20 transition duration-200 flex items-center justify-center gap-2">
                <i class="fa-solid fa-user-check"></i> 일반회원가입 완료하기
            </button>
        </form>
    </div>

    <jsp:include page="/WEB-INF/jsp/common/deptSelectModal.jsp"/>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/comm/validation-engine.js"></script>
    <script src="${pageContext.request.contextPath}/js/comm/deptSelectModal.js"></script>
    <script>
        var ctxPath = '${pageContext.request.contextPath}';
        var joinUserIdCheckedValue = '';

        /**
         * 회원가입 사용자ID 입력이 바뀌면 기존 중복확인 결과를 초기화한다.
         * @returns {void}
         */
        function resetJoinUserIdCheck() {
            joinUserIdCheckedValue = '';
            $('#joinUserIdCheckMessage').text('');
        }

        /**
         * 일반회원가입 사용자ID의 형식과 중복 여부를 서버에서 확인한다.
         * @returns {void}
         */
        function checkJoinUserId() {
            var userId = $.trim($('#userId').val());
            if (!/^(?=.*[a-z])[a-z0-9]{6,20}$/.test(userId)) {
                resetJoinUserIdCheck();
                alert('사용자ID는 영문 소문자와 숫자 6~20자로 입력하고 영문 소문자를 포함해야 합니다.');
                $('#userId').focus();
                return;
            }
            $.ajax({
                url: ctxPath + '/login/userIdCheck.ajax',
                type: 'POST',
                data: { userId: userId },
                dataType: 'json',
                success: function(data) {
                    if (data.result !== 'OK') {
                        resetJoinUserIdCheck();
                        alert(data.msg || '사용자ID를 확인하지 못했습니다.');
                        return;
                    }
                    if (Number(data.cnt || 0) > 0) {
                        resetJoinUserIdCheck();
                        $('#joinUserIdCheckMessage').text('이미 사용 중인 사용자ID입니다.');
                        return;
                    }
                    joinUserIdCheckedValue = userId;
                    $('#joinUserIdCheckMessage').text('사용할 수 있는 사용자ID입니다.');
                },
                error: function() {
                    resetJoinUserIdCheck();
                    alert('사용자ID 중복확인 중 오류가 발생했습니다.');
                }
            });
        }

        function searchCompany() {
            var keyword = $('#searchValue').val().trim();
            if(!keyword) { alert('회사명을 기입해 주세요.'); return; }

            $.ajax({
                url: ctxPath + '/login/searchCompany.ajax',
                type: 'POST',
                data: { searchValue: keyword },
                dataType: 'json',
                success: function(data) {
                    var container = $('#companyListContainer');
                    container.empty().removeClass('hidden');

                    if(data.result === 'OK' && data.list && data.list.length > 0) {
                        $.each(data.list, function(idx, item) {
                            var btn = $('<button type="button" class="w-full text-left text-xs text-gray-300 p-2 hover:bg-brand-accent/20 rounded transition block"></button>');
                            btn.text(item.coNm + ' (코드: ' + item.coId + ')');
                            btn.attr('onclick', 'selectCompany("' + item.coId + '", "' + item.coNm + '")');
                            container.append(btn);
                        });
                    } else {
                        container.html('<span class="text-xs text-gray-500 p-2 block">검색된 승인 기업이 없습니다.</span>');
                    }
                },
                error: function() { alert('회사 풀 조회 중 통신 에러가 발생했습니다.'); }
            });
        }

        function selectCompany(id, name) {
            $('#coId').val(id);
            $('#selectedCoNm').text(name);
            $('#selectedCoIdDisplay').text('ID: ' + id);
            
            $('#companyListContainer').addClass('hidden');
            $('#selectedCompanyCard').removeClass('hidden');

            clearSelectedDepartment();
        }

        function clearSelectedDepartment() {
            $('#deptId').val('');
            $('#deptNm').val('');
        }

        function openJoinDeptSelectModal() {
            var coId = $('#coId').val();
            if (!coId) {
                alert('소속 회사를 먼저 선택해 주세요.');
                return;
            }
            openDeptSelectModal({
                url: ctxPath + '/login/selectDeptList.ajax',
                type: 'POST',
                coId: function() { return $('#coId').val(); },
                targetId: '#deptId',
                targetName: '#deptNm'
            });
        }


        function submitJoinForm() {
            var form = $('#joinForm')[0];
            if (!form.checkValidity()) { form.reportValidity(); return; }

            // 공통 벨리데이션 체크 엔진 작동
            if (!ValidEngine.validateForm('#joinForm')) { return; }
            if (joinUserIdCheckedValue !== $.trim($('#userId').val())) {
                alert('사용자ID 중복확인을 해 주세요.');
                $('#btnJoinUserIdCheck').focus();
                return;
            }

            $.ajax({
                url: ctxPath + '/login/insertUserJoin.ajax',
                type: 'POST',
                data: $('#joinForm').serialize(),
                dataType: 'json',
                success: function(data) {
                    if(data.result === 'OK') {
                        alert('회원가입이 성공적으로 완료되었습니다! 로그인 화면으로 이동합니다.');
                        window.location.href = ctxPath + '/login/login.do';
                    } else {
                        alert(data.msg || '가입 처리 중 오류가 발생했습니다.');
                    }
                },
                error: function() { alert('서버 원격 가입 엔진 통신 오류'); }
            });
        }

        $('#userId').on('input', resetJoinUserIdCheck);
    </script>
</body>
</html>
