<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevSync - 시작하기</title>
    <script src="${pageContext.request.contextPath}/protoType/saved_resource"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: {
                            dark:    '#0b0f19',
                            card:    '#111827',
                            border:  '#1f2937',
                            accent:  '#3b82f6',
                            neonBlue:'#00d2ff',
                            neonGreen:'#10b981'
                        }
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-[#0b0f19] text-[#f3f4f6] min-h-screen flex items-center justify-center p-4">

    <div class="bg-[#111827] border border-[#1f2937] rounded-2xl w-full max-w-2xl p-8 shadow-2xl relative">
        
        <a href="${pageContext.request.contextPath}/login/login.do" class="absolute top-6 left-6 text-xs text-gray-400 hover:text-brand-neonBlue transition">
            <i class="fa-solid fa-arrow-left mr-1"></i> 로그인으로 돌아가기
        </a>

        <div class="text-center mb-10 mt-4">
            <div class="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-brand-accent/10 border border-brand-accent/30 mb-3">
                <i class="fa-solid fa-cubes text-xl text-brand-neonBlue"></i>
            </div>
            <h3 class="text-xl font-bold text-white mb-2">DevSync 서비스 시작하기</h3>
            <p class="text-xs text-gray-400">원하시는 이용 목적에 맞는 가입 유형을 선택해 주세요.</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            
            <a href="${pageContext.request.contextPath}/login/request/joinForm.do" 
               class="group relative bg-[#1f2937]/40 hover:bg-[#1f2937]/90 border border-brand-border hover:border-brand-accent rounded-xl p-6 transition duration-200 flex flex-col justify-between hover:shadow-lg hover:shadow-brand-accent/10">
                <div>
                    <div class="w-10 h-10 rounded-lg bg-blue-500/10 border border-blue-500/20 flex items-center justify-center mb-4 group-hover:bg-brand-accent/20 transition">
                        <i class="fa-solid fa-users text-lg text-brand-neonBlue"></i>
                    </div>
                    <h4 class="text-sm font-bold text-white mb-2 flex items-center">
						일반 직원용 가입
                        <i class="fa-solid fa-circle-arrow-right ml-1.5 text-xs text-gray-500 group-hover:text-brand-neonBlue transition transform group-hover:translate-x-0.5"></i>
                    </h4>
                    <p class="text-xs text-gray-400 leading-relaxed">
						우리 회사가 이미 DevSync를 <span class="text-brand-neonBlue font-semibold">도입하여 사용 중</span>인 경우, 소속 사원으로 계정을 생성합니다.
                    </p>
                </div>
                <div class="mt-6 text-[11px] text-gray-500 group-hover:text-gray-300 transition">
                    <i class="fa-solid fa-check mr-1 text-brand-neonBlue"></i>회사 검색 후 가입 가능
                </div>
            </a>

            <a href="${pageContext.request.contextPath}/login/request/companyRequest.do" 
               class="group relative bg-[#1f2937]/40 hover:bg-[#1f2937]/90 border border-brand-border hover:border-brand-neonGreen rounded-xl p-6 transition duration-200 flex flex-col justify-between hover:shadow-lg hover:shadow-brand-neonGreen/10">
                <div>
                    <div class="w-10 h-10 rounded-lg bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center mb-4 group-hover:bg-emerald-500/20 transition">
                        <i class="fa-solid fa-building-circle-check text-lg text-brand-neonGreen"></i>
                    </div>
                    <h4 class="text-sm font-bold text-white mb-2 flex items-center">
                        서비스 도입 신청 (조직 신청)
                        <i class="fa-solid fa-circle-arrow-right ml-1.5 text-xs text-gray-500 group-hover:text-brand-neonGreen transition transform group-hover:translate-x-0.5"></i>
                    </h4>
                    <p class="text-xs text-gray-400 leading-relaxed">
                        DevSync를 새롭게 도입하고자 하는 <span class="text-brand-neonGreen font-semibold">기업 대표자 및 운영진</span> 전용입니다. 서류 검토 후 조직 코드가 발급됩니다.
                    </p>
                </div>
                <div class="mt-6 text-[11px] text-gray-500 group-hover:text-gray-300 transition">
                    <i class="fa-solid fa-file-invoice mr-1 text-brand-neonGreen"></i>사업자등록증 첨부 필요
                </div>
            </a>

        </div>

        <div class="mt-10 text-center border-t border-brand-border/40 pt-4">
            <p class="text-[10px] text-gray-600 font-mono">DevSync Authentication Gateway v1.0</p>
        </div>
    </div>

</body>
</html>