package kr.co.TRSolution.trsIbp.attend.web;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import kr.co.TRSolution.trsIbp.attend.service.AttendService;
import kr.co.TRSolution.trsIbp.attend.vo.AttendVO;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

/**
 * 근태관리 컨트롤러
 *
 * [API 목록]
 *  POST /attend/checkIn.ajax   - 출근 처리
 *  POST /attend/checkOut.ajax  - 퇴근 처리
 *  GET  /attend/todayStatus.ajax - 오늘 출퇴근 현황 조회 (대시보드 로드 시)
 *  POST /attend/powkNm.ajax - 근무지 변경
 *
 * 모든 API는 JSON 응답 (jsonView)
 * 세션에서 userId를 꺼내 처리하므로 프론트에서 userId 파라미터 불필요
 *
 * @author DevSync
 * @since 2026-05-28
 */
@Controller
public class AttendController {

    public static final Logger logger = LoggerFactory.getLogger(AttendController.class);

    @Resource(name = "attendService")
    private AttendService attendService;

    /**
     * 오늘 출퇴근 현황 조회 (대시보드 로드 시 호출)
     * Response: { gtwkDt, lvwkDt, powkNm, workMinutes }
     */
    @RequestMapping(value = "/attend/todayStatus.ajax", method = RequestMethod.GET)
    @ResponseBody
    public ModelAndView todayStatus(HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
            if (loginUser == null) {
                mav.addObject("result", "NO_SESSION");
                return mav;
            }

            AttendVO param = new AttendVO();
            param.setUserId(loginUser.getUserId());
            param.setCoId(loginUser.getCoId());
            param.setDeptId(loginUser.getDeptId());

            AttendVO todayAttend = attendService.selectTodayAttend(param);
            AttendVO scheduleStatus = attendService.selectTodayScheduleStatus(param);
            List<AttendVO> powkCodeList = attendService.selectPowkCodeList();
            String effectiveStatusCd = scheduleStatus == null
                    ? (todayAttend == null || todayAttend.getPowkNm() == null
                            ? attendService.selectDefaultPowkSeCd() : todayAttend.getPowkNm())
                    : scheduleStatus.getStatusCd();
            String effectiveStatusNm = scheduleStatus == null
                    ? findPowkCodeName(powkCodeList, effectiveStatusCd) : scheduleStatus.getStatusNm();

            mav.addObject("powkNm", effectiveStatusCd);
            mav.addObject("powkSeNm", effectiveStatusNm);
            mav.addObject("scheduleLinkedYn", scheduleStatus == null ? "N" : "Y");
            mav.addObject("scheduleNm", scheduleStatus == null ? "" : scheduleStatus.getSchdlNm());
            mav.addObject("powkCodeList", powkCodeList);

            if (todayAttend != null) {
                mav.addObject("result", "OK");
                mav.addObject("gtwkDt",  todayAttend.getGtwkDt());
                mav.addObject("lvwkDt", todayAttend.getLvwkDt());
                mav.addObject("workMinutes",  todayAttend.getWorkMinutes());
            } else {
                mav.addObject("result", "NO_RECORD");
                mav.addObject("gtwkDt",  "");
                mav.addObject("lvwkDt", "");
                mav.addObject("workMinutes",  "0");
            }
        } catch (Exception e) {
            logger.error("▶ todayStatus 오류", e);
            mav.addObject("result", "ERROR");
            mav.addObject("msg", e.getMessage());
        }
        return mav;
    }

    /**
     * 로그인 사용자와 같은 부서의 현재 근무/일정 상태를 조회한다.
     */
    @RequestMapping(value = "/attend/teamStatus.ajax", method = RequestMethod.GET)
    @ResponseBody
    public ModelAndView teamStatus(HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
            if (loginUser == null) {
                mav.addObject("result", "NO_SESSION");
                return mav;
            }
            AttendVO param = new AttendVO();
            param.setCoId(loginUser.getCoId());
            param.setDeptId(loginUser.getDeptId());
            List<AttendVO> teamList = attendService.selectTeamStatusList(param);
            mav.addObject("result", "OK");
            mav.addObject("teamList", teamList);
        } catch (Exception e) {
            logger.error("▶ teamStatus 오류", e);
            mav.addObject("result", "ERROR");
            mav.addObject("msg", "부서원 상태를 조회하지 못했습니다.");
        }
        return mav;
    }

    /**
     * 출근 처리
     * Request: powkNm (POWK_SE_CD 공통코드)
     * Response: { result, gtwkDt }
     */
    @RequestMapping(value = "/attend/checkIn.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView checkIn(
            @ModelAttribute AttendVO attendVO,
            HttpServletRequest request) {

        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
            if (loginUser == null) {
                mav.addObject("result", "NO_SESSION");
                return mav;
            }

            attendVO.setUserId(loginUser.getUserId());

            // 이미 출근 기록이 있는지 확인
            AttendVO existing = attendService.selectTodayAttend(attendVO);
            if (existing != null && existing.getGtwkDt() != null && !existing.getGtwkDt().isEmpty()) {
                mav.addObject("result", "ALREADY_CHECKED_IN");
                mav.addObject("gtwkDt", existing.getGtwkDt());
                return mav;
            }

            // 근무장소구분 기본값
            if (attendVO.getPowkNm() == null || attendVO.getPowkNm().isEmpty()) {
                attendVO.setPowkNm(attendService.selectDefaultPowkSeCd());
            }

            attendService.checkIn(attendVO);

            // 저장 후 다시 조회
            AttendVO saved = attendService.selectTodayAttend(attendVO);
            mav.addObject("result", "OK");
            mav.addObject("gtwkDt", saved != null ? saved.getGtwkDt() : "");
            logger.debug("▶ 출근 처리 완료: userId={}, location={}", loginUser.getUserId(), attendVO.getPowkNm());

        } catch (Exception e) {
            logger.error("▶ checkIn 오류", e);
            mav.addObject("result", "ERROR");
            mav.addObject("msg", "출근 처리 중 오류가 발생했습니다.");
        }
        return mav;
    }

    /**
     * 퇴근 처리
     * Response: { result, lvwkDt, workMinutes }
     */
    @RequestMapping(value = "/attend/checkOut.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView checkOut(HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
            if (loginUser == null) {
                mav.addObject("result", "NO_SESSION");
                return mav;
            }

            AttendVO param = new AttendVO();
            param.setUserId(loginUser.getUserId());

            // 출근 기록 확인
            AttendVO existing = attendService.selectTodayAttend(param);
            if (existing == null || existing.getGtwkDt() == null || existing.getGtwkDt().isEmpty()) {
                mav.addObject("result", "NO_CHECK_IN");
                return mav;
            }
            if (existing.getLvwkDt() != null && !existing.getLvwkDt().isEmpty()) {
                mav.addObject("result", "ALREADY_CHECKED_OUT");
                mav.addObject("lvwkDt", existing.getLvwkDt());
                mav.addObject("workMinutes",  existing.getWorkMinutes());
                return mav;
            }

            attendService.checkOut(param);

            // 저장 후 다시 조회
            AttendVO saved = attendService.selectTodayAttend(param);
            mav.addObject("result",       "OK");
            mav.addObject("lvwkDt", saved != null ? saved.getLvwkDt() : "");
            mav.addObject("workMinutes",  saved != null ? saved.getWorkMinutes()  : "0");
            logger.debug("▶ 퇴근 처리 완료: userId={}", loginUser.getUserId());

        } catch (Exception e) {
            logger.error("▶ checkOut 오류", e);
            mav.addObject("result", "ERROR");
            mav.addObject("msg", "퇴근 처리 중 오류가 발생했습니다.");
        }
        return mav;
    }

    /**
     * 근무지 변경 (출근 전/후 모두 허용)
     * Request: powkNm (POWK_SE_CD 공통코드)
     * Response: { result, powkNm }
     */
    @RequestMapping(value = "/attend/powkNm.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView updatePowkNm(
            @ModelAttribute AttendVO attendVO,
            HttpServletRequest request) {

        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
            if (loginUser == null) {
                mav.addObject("result", "NO_SESSION");
                return mav;
            }
            attendVO.setUserId(loginUser.getUserId());
            attendVO.setCoId(loginUser.getCoId());
            AttendVO scheduleStatus = attendService.selectTodayScheduleStatus(attendVO);
            if (scheduleStatus != null) {
                mav.addObject("result", "FAIL");
                mav.addObject("msg", "현재 [" + scheduleStatus.getStatusNm() + "] "
                        + scheduleStatus.getSchdlNm() + " 일정과 연동되어 근무상태를 직접 변경할 수 없습니다.");
                return mav;
            }
            if (!isValidPowkCode(attendVO.getPowkNm(), attendService.selectPowkCodeList())) {
                mav.addObject("result", "FAIL");
                mav.addObject("msg", "근무장소 값이 올바르지 않습니다.");
                return mav;
            }
            int updatedCount = attendService.updatePowkNm(attendVO);
            if (updatedCount == 0) {
                mav.addObject("result", "FAIL");
                mav.addObject("msg", "오늘 출근기록이 없어 근무상태를 변경하지 못했습니다.");
                return mav;
            }
            mav.addObject("result", "OK");
            mav.addObject("powkNm", attendVO.getPowkNm());
            logger.debug("▶ 근무지 변경: userId={}, location={}", loginUser.getUserId(), attendVO.getPowkNm());

        } catch (Exception e) {
            logger.error("▶ updatePowkNm 오류", e);
            mav.addObject("result", "ERROR");
            mav.addObject("msg", "근무상태 변경 중 오류가 발생했습니다.");
        }
        return mav;
    }

    private String findPowkCodeName(List<AttendVO> codeList, String code) {
        if (codeList != null) {
            for (AttendVO item : codeList) {
                if (code != null && code.equals(item.getPowkNm())) {
                    return item.getStatusNm();
                }
            }
        }
        return code == null ? "" : code;
    }

    private boolean isValidPowkCode(String code, List<AttendVO> codeList) {
        if (code == null || codeList == null) {
            return false;
        }
        for (AttendVO item : codeList) {
            if (code.equals(item.getPowkNm())) {
                return true;
            }
        }
        return false;
    }
}
