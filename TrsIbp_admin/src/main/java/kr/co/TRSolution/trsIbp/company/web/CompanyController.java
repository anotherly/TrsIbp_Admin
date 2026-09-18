package kr.co.TRSolution.trsIbp.company.web;

import java.util.List;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import kr.co.TRSolution.trsIbp.company.service.CompanyService;
import kr.co.TRSolution.trsIbp.company.vo.CompanyVO;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

@Controller
public class CompanyController {

    public static final Logger logger = LoggerFactory.getLogger(CompanyController.class);

    @Resource(name = "companyService")
    private CompanyService companyService;

    public String url="";
	
	//주소에 맞게 매핑
	@RequestMapping("/company/**/*.do")
	public String urlMapping(HttpSession httpSession, HttpServletRequest request,Model model
			) throws Exception{
		logger.debug("▶▶▶▶▶▶▶.단말기 최초 컨트롤러");
		url = request.getRequestURI().substring(request.getContextPath().length()).split(".do")[0];
		logger.debug("▶▶▶▶▶▶▶.보내려는 url : "+url);
		return url;
	}
    
    // 회사 통합검색
    @RequestMapping(value = {"/login/searchCompany.ajax","/company/searchCompany.ajax"}, method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView searchCompany(@ModelAttribute CompanyVO companyVO) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            List<CompanyVO> list = companyService.selectCompanyList(companyVO);
            mav.addObject("result", "OK");
            mav.addObject("list", list);
        } catch (Exception e) {
            logger.error("▶ 회사 검색 에러: {}", e.toString());
            mav.addObject("result", "ERROR");
        }
        return mav;
    }

    @RequestMapping(value = "/company/registerCompany.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView registerCompany(@ModelAttribute CompanyVO companyVO, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            String generatedCoId = companyService.insertCompany(companyVO);
            mav.addObject("result", "OK");
            mav.addObject("coId", generatedCoId);
            mav.addObject("msg", "회사 등록이 성공적으로 완료되었습니다.");
        } catch (Exception e) {
            logger.error("▶ 회사 등록 에러: {}", e.toString());
            mav.addObject("result", "ERROR");
        }
        return mav;
    }

    // ====================================================================
    // [신규 통합 병합 구역] 도입 신청/승인 이관 라우터
    // ====================================================================


    /**
     * 외부 대표자용: 화면에서 작성된 폼 데이터(텍스트 데이터 + Multipart 파일) 수신 비동기 API
     */
    @RequestMapping(value = "/login/request/requestInsert.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView requestInsert(@ModelAttribute CompanyVO companyVO) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            logger.debug("▶ [통합 컨트롤러] 외부 기업 도입 신청서 유입 - 회사명: {}", companyVO.getCoNm());
            companyService.insertCompanyRequest(companyVO);
            mav.addObject("result", "OK");
        } catch (Exception e) {
            logger.error("▶ requestInsert 가동 장애: {}", e.toString());
            mav.addObject("result", "ERROR");
            mav.addObject("msg", "시스템 내부 장애로 도입 문의 접수가 실패했습니다.");
        }
        return mav;
    }

    /**
     * 내부 시스템 관리자 전용: 접수된 임시 신청 건 최종 승인 및 정식 마스터 자동 이관 AJAX
     */
    @RequestMapping(value = "/admin/approveCompany.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView approveCompany(@RequestParam("aplySn") int aplySn, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            // 최소한의 세션 권한 필터 가로채기 검증
            UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
            if (loginUser == null || !"ADMIN".equals(loginUser.getAuthrtId())) {
                mav.addObject("result", "FAIL");
                mav.addObject("msg", "최고 관리자(ADMIN) 권한이 필요한 비즈니스 통로입니다.");
                return mav;
            }

            // 트랜잭션 가동 및 자동 채번된 정식 회사 고유 ID 반환 처리
            String issuedCoId = companyService.approveCompanyRequest(aplySn);
            
            mav.addObject("result", "OK");
            mav.addObject("coId", issuedCoId);
            mav.addObject("msg", "성공적으로 승인 처리되었으며, 기업 정식 인프라 생성이 종료되었습니다.");
            
        } catch (Exception e) {
            logger.error("▶ admin approveCompany 마스터 이관 장애: {}", e.toString());
            mav.addObject("result", "ERROR");
            mav.addObject("msg", "데이터 오류가 발생하여 안전하게 실행취소 되었습니다.");
        }
        return mav;
    }
}