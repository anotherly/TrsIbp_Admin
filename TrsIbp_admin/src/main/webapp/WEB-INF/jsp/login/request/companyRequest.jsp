<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevSync - 서비스 도입 문의 및 신청</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="bg-[#0b0f19] text-[#f3f4f6] min-h-screen flex items-center justify-center p-4">

    <div class="bg-[#111827] border border-[#1f2937] rounded-2xl w-full max-w-lg p-8 shadow-2xl relative">
        <div class="text-center mb-6">
            <h3 class="text-xl font-bold text-white mb-2">
                <i class="fa-solid fa-building-circle-check text-blue-500 mr-2"></i>DevSync 도입 신청하기
            </h3>
            <p class="text-xs text-gray-400">정보를 입력해주시면 시스템 관리자 검토 후 최고관리자 계정을 발급해 드립니다.</p>
        </div>
        
        <form id="requestForm" method="POST" enctype="multipart/form-data" class="space-y-4">
            
            <div>
                <label class="block text-xs font-bold text-gray-400 mb-1.5">회사명 <span class="text-red-500">*</span></label>
                <input type="text" name="coNm" maxlength="15" required class="w-full bg-slate-900 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-100 focus:outline-none focus:border-blue-500 transition" placeholder="예: (주)쓰리알솔루션">
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-400 mb-1.5">사업자등록번호 <span class="text-red-500">*</span></label>
                <input type="text" name="brno" maxlength="12" required class="w-full bg-slate-900 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-100 focus:outline-none focus:border-blue-500 transition" placeholder="하이픈(-)을 제외하고 입력">
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-400 mb-1.5">회사 주소 / 우편번호 <span class="text-red-500">*</span></label>
                <div class="flex gap-2 mb-2">
                    <input type="text" id="zipCode" name="zipCode" readonly required class="w-1/3 bg-slate-950 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-400 focus:outline-none" placeholder="우편번호">
                    <button type="button" onclick="openKakaoPostcode()" class="px-4 py-2 bg-slate-800 hover:bg-slate-700 border border-[#1f2937] text-xs font-bold rounded-lg text-gray-200 transition">주소 검색</button>
                </div>
                <input type="text" id="coAddr" name="coAddr" readonly required class="w-full bg-slate-900 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-100 focus:outline-none mb-2" placeholder="기본 주소 (주소 검색 시 자동완성)">
                <input type="text" id="addrDetail" name="addrDetail" maxlength="100" class="w-full bg-slate-900 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-100 focus:outline-none focus:border-blue-500 transition" placeholder="상세 주소를 입력하세요">
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold text-gray-400 mb-1.5">신청자명 <span class="text-red-500">*</span></label>
                    <input type="text" name="aplcntNm" maxlength="15" required class="w-full bg-slate-900 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-100 focus:outline-none focus:border-blue-500 transition" placeholder="홍길동">
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-400 mb-1.5">대표성함 <span class="text-red-500">*</span></label>
                    <input type="text" name="rprsvNm" maxlength="15" required class="w-full bg-slate-900 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-100 focus:outline-none focus:border-blue-500 transition" placeholder="대표자성명">
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-400 mb-1.5">신청자 연락처 <span class="text-red-500">*</span></label>
                <input type="tel" name="picTelno" data-valid="phone" required class="w-full bg-slate-900 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-100 focus:outline-none focus:border-blue-500 transition" placeholder="지역번호 또는 휴대폰 번호 (하이픈 제외)">
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-400 mb-1.5">담당자 이메일 <span class="text-red-500">*</span></label>
                <input type="email" name="picEmlAddr" maxlength="50" required class="w-full bg-slate-900 border border-[#1f2937] text-sm rounded-lg p-2.5 text-gray-100 focus:outline-none focus:border-blue-500 transition" placeholder="name@company.com">
            </div>

            <div>
                <label class="block text-xs font-bold text-gray-400 mb-1.5">사업자등록증 첨부 <span class="text-red-500">*</span></label>
                <input type="file" name="bizFile" id="bizFile" required class="w-full bg-slate-900 border border-[#1f2937] text-xs rounded-lg p-2 text-gray-400 file:mr-4 file:py-1 file:px-3 file:rounded-md file:border-0 file:text-xs file:font-semibold file:bg-blue-500 file:text-white hover:file:bg-blue-600 transition">
                <p class="text-[10px] text-gray-500 mt-1">* pdf, png, jpg, jpeg 파일만 허용 (최대 10MB)</p>
            </div>

            <button type="button" onclick="submitRequest()" class="w-full mt-2 py-3 bg-blue-500 hover:bg-blue-600 text-white rounded-xl text-sm font-bold shadow-lg shadow-blue-500/20 transition flex items-center justify-center gap-2">
                <i class="fa-solid fa-paper-plane"></i> 도입 신청서 제출하기
            </button>
        </form>
    </div>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script src="${pageContext.request.contextPath}/js/comm/validation-engine.js"></script>
    <script>
        var ctxPath = '${pageContext.request.contextPath}';

        // [카카오 주소 연동 API 엔진]
        function openKakaoPostcode() {
            new daum.Postcode({
                oncomplete: function(data) {
                    var fullAddr = data.userSelectedType === 'R' ? data.roadAddress : data.jibunAddress;
                    
                    if(data.userSelectedType === 'R'){
                        var extraAddr = '';
                        if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){ extraAddr += data.bname; }
                        if(data.buildingName !== '' && data.apartment === 'Y'){ extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName); }
                        fullAddr += (extraAddr !== '' ? ' ('+ extraAddr +')' : '');
                    }

                    $('#zipCode').val(data.zonecode);
                    $('#coAddr').val(fullAddr);
                    $('#addrDetail').focus(); 
                }
            }).open();
        }

        function submitRequest() {
            var form = $('#requestForm')[0];
            if (!form.checkValidity()) { form.reportValidity(); return; }

            // 공통 엔진 가동
            if (!ValidEngine.validateForm('#requestForm')) { return; }

            // 파일 확장자 및 용량 자바스크립트 1차 보안 체크
            var fileInput = $('#bizFile')[0];
            if (fileInput.files.length > 0) {
                var file = fileInput.files[0];
                var ext = file.name.split('.').pop().toLowerCase();
                var allowExt = ['pdf', 'png', 'jpg', 'jpeg'];
                if ($.inArray(ext, allowExt) == -1) {
                    alert('허용되지 않는 파일 확장자입니다. (pdf, png, jpg, jpeg만 가능)');
                    return;
                }
                if (file.size > 10 * 1024 * 1024) {
                    alert('첨부파일 용량은 10MB를 초과할 수 없습니다.');
                    return;
                }
            }

            var formData = new FormData(form);
            $.ajax({
                url: ctxPath + '/login/request/requestInsert.ajax',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                dataType: 'json',
                success: function(data) {
                    if (data.result === 'OK') {
                        alert('도입 신청이 정상적으로 접수되었습니다. 관리자 검토 후 이메일로 회신해 드립니다.');
                        window.location.href = ctxPath + '/login/login.do';
                    } else {
                        alert(data.msg || '신청 중 오류가 발생했습니다.');
                    }
                },
                error: function() { alert('서버 통신 중 오류가 발생했습니다.'); }
            });
        }
    </script>
</body>
</html>