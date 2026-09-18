package kr.co.TRSolution.trsIbp.schedule.controller;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import kr.co.TRSolution.trsIbp.biz.service.BizService;
import kr.co.TRSolution.trsIbp.biz.vo.BizVO;
import kr.co.TRSolution.trsIbp.schedule.service.ScheduleService;
import kr.co.TRSolution.trsIbp.schedule.vo.ScheduleVO;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

/**
 * 종합 일정 캘린더 Controller
 */
@Controller
public class ScheduleController {

    @Resource(name = "scheduleService")
    private ScheduleService scheduleService;

    @Resource(name = "bizService")
    private BizService bizService;

    /**
     * 종합 일정 캘린더 화면으로 이동한다.
     * @return 일정 캘린더 JSP 경로
     */
    @RequestMapping(value = "/schedule/scheduleList.do")
    public ModelAndView scheduleListPage() {
        return new ModelAndView("/schedule/scheduleList");
    }

    /**
     * 일정 화면 초기 구분코드 목록을 조회한다.
     * @param scheduleVO 조회조건 VO
     * @param request 로그인 사용자 세션 확인용 요청 객체
     * @return jsonView: result, codeList, bizList
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/schedule/scheduleMeta.ajax")
    public ModelAndView selectScheduleMeta(@ModelAttribute("scheduleVO") ScheduleVO scheduleVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        applyLoginUser(scheduleVO, request, false);
        mav.addObject("result", "OK");
        mav.addObject("codeList", scheduleService.selectScheduleCodeList(scheduleVO));
        mav.addObject("bizList", selectScheduleProjectList(scheduleVO.getCoId()));
        UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
        mav.addObject("loginUserId", loginUser.getUserId());
        mav.addObject("loginUserNm", loginUser.getUserNm());
        return mav;
    }

    /**
     * 월간 달력 표시용 일정 요약과 선택일자의 일정 목록을 조회한다.
     * @param scheduleVO selectedYmd, viewType 등 조회조건 VO
     * @param request 로그인 사용자 세션 확인용 요청 객체
     * @return jsonView: result, monthList, dayList
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/schedule/scheduleList.ajax")
    public ModelAndView selectScheduleList(@ModelAttribute("scheduleVO") ScheduleVO scheduleVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        applyLoginUser(scheduleVO, request, false);
        normalizeDateRange(scheduleVO);
        List<ScheduleVO> monthList = scheduleService.selectMonthScheduleSummaryList(scheduleVO);
        List<ScheduleVO> dayList = scheduleService.selectDayScheduleList(scheduleVO);
        mav.addObject("result", "OK");
        mav.addObject("monthList", monthList);
        mav.addObject("dayList", dayList);
        return mav;
    }

    /**
     * 대시보드 일정 위젯용 월간/일간 일정 데이터를 조회한다.
     * @param scheduleVO selectedYmd, viewType 등 조회조건 VO
     * @param request 로그인 사용자 세션 확인용 요청 객체
     * @return jsonView: result, monthList, dayList
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/schedule/dashboardSchedule.ajax")
    public ModelAndView selectDashboardSchedule(@ModelAttribute("scheduleVO") ScheduleVO scheduleVO, HttpServletRequest request) throws Exception {
        return selectScheduleList(scheduleVO, request);
    }

    /**
     * 일정 단건 상세정보를 조회한다.
     * @param scheduleVO schdlSn을 포함한 조회조건 VO
     * @param request 로그인 사용자 세션 확인용 요청 객체
     * @return jsonView: result, schedule
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/schedule/scheduleDetail.ajax")
    public ModelAndView selectSchedule(@ModelAttribute("scheduleVO") ScheduleVO scheduleVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        applyLoginUser(scheduleVO, request, false);
        mav.addObject("result", "OK");
        mav.addObject("schedule", scheduleService.selectSchedule(scheduleVO));
        return mav;
    }

    /**
     * 선택일자에 로그인 작성자가 이미 등록된 일정을 조회한다.
     * 신규 일정의 09:00~18:00 최초 빈 시간대 계산에 사용한다.
     * @param scheduleVO 선택일자와 수정 시 제외할 일정 순번
     * @param request 로그인 사용자 세션 확인용 요청 객체
     * @return jsonView: result, busyList
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/schedule/userWorkHourSchedule.ajax")
    public ModelAndView selectUserWorkHourSchedule(@ModelAttribute("scheduleVO") ScheduleVO scheduleVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        applyLoginUser(scheduleVO, request, false);
        if (!isValidYmd(scheduleVO.getSelectedYmd())) {
            mav.addObject("result", "FAIL");
            mav.addObject("message", "선택일자 형식이 올바르지 않습니다.");
            return mav;
        }
        mav.addObject("result", "OK");
        mav.addObject("busyList", scheduleService.selectUserDayScheduleList(scheduleVO));
        return mav;
    }

    /**
     * 일정을 등록하거나 수정한다.
     * @param scheduleVO 저장할 일정 정보와 대상자ID 목록
     * @param request 로그인 사용자 세션 확인용 요청 객체
     * @return jsonView: result
     * @throws Exception 저장 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/schedule/scheduleSave.ajax")
    public ModelAndView saveSchedule(@ModelAttribute("scheduleVO") ScheduleVO scheduleVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        applyLoginUser(scheduleVO, request, true);
        String validateMsg = normalizeVacation(scheduleVO);
        if (validateMsg != null) {
            mav.addObject("result", "FAIL");
            mav.addObject("message", validateMsg);
            return mav;
        }
        normalizeDateTime(scheduleVO);
        validateMsg = validateScheduleForSave(scheduleVO);
        if (validateMsg != null) {
            mav.addObject("result", "FAIL");
            mav.addObject("message", validateMsg);
            return mav;
        }
        validateMsg = validateAndNormalizeProject(scheduleVO);
        if (validateMsg != null) {
            mav.addObject("result", "FAIL");
            mav.addObject("message", validateMsg);
            return mav;
        }
        try {
            scheduleService.saveSchedule(scheduleVO);
            mav.addObject("result", "OK");
            mav.addObject("schdlSn", scheduleVO.getSchdlSn());
        } catch (IllegalArgumentException e) {
            mav.addObject("result", "CONFLICT");
            mav.addObject("message", e.getMessage());
        }
        return mav;
    }

    /**
     * 일정을 삭제 처리한다.
     * @param scheduleVO 삭제할 일정 순번
     * @param request 로그인 사용자 세션 확인용 요청 객체
     * @return jsonView: result
     * @throws Exception 삭제 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/schedule/scheduleDelete.ajax")
    public ModelAndView deleteSchedule(@ModelAttribute("scheduleVO") ScheduleVO scheduleVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        applyLoginUser(scheduleVO, request, true);
        scheduleService.deleteSchedule(scheduleVO);
        mav.addObject("result", "OK");
        return mav;
    }

    /**
     * 로그인 사용자 회사/사용자 정보를 일정 VO에 세팅한다.
     * @param scheduleVO 로그인 사용자 정보를 반영할 VO
     * @param request 세션 조회용 요청 객체
     * @param withAudit 등록자/수정자 세팅 여부
     */
    private void applyLoginUser(ScheduleVO scheduleVO, HttpServletRequest request, boolean withAudit) {
        UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
        scheduleVO.setCoId(reqLoginVo.getCoId());
        scheduleVO.setTargetUserId(reqLoginVo.getUserId());
        if (withAudit) {
            scheduleVO.setRgtrId(reqLoginVo.getUserId());
            scheduleVO.setMdfrId(reqLoginVo.getUserId());
        }
    }

    /**
     * 선택일자 기준으로 월 시작일/종료일을 계산한다.
     * @param scheduleVO selectedYmd를 포함한 조회조건 VO
     */
    private void normalizeDateRange(ScheduleVO scheduleVO) {
        String selectedYmd = scheduleVO.getSelectedYmd();
        if (selectedYmd == null || selectedYmd.trim().isEmpty()) {
            selectedYmd = LocalDate.now().format(DateTimeFormatter.ISO_DATE);
            scheduleVO.setSelectedYmd(selectedYmd);
        }
        YearMonth ym = YearMonth.from(LocalDate.parse(selectedYmd));
        scheduleVO.setMonthStartYmd(ym.atDay(1).format(DateTimeFormatter.ISO_DATE));
        scheduleVO.setMonthEndYmd(ym.atEndOfMonth().format(DateTimeFormatter.ISO_DATE));
    }

    private boolean isValidYmd(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        try {
            LocalDate.parse(value.trim(), DateTimeFormatter.ISO_DATE);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 일정 저장 전 필수값과 시작/종료일시의 선후관계를 검증한다.
     * @param scheduleVO 검증할 일정 정보
     * @return 오류 메시지. 정상인 경우 null
     */
    private String validateScheduleForSave(ScheduleVO scheduleVO) {
        if (!"Y".equals(scheduleVO.getAllDayYn()) && !"N".equals(scheduleVO.getAllDayYn())) {
            return "종일여부 값이 올바르지 않습니다.";
        }
        if (scheduleVO.getSchdlSeCd() == null || scheduleVO.getSchdlSeCd().trim().isEmpty()) {
            return "일정구분을 선택하세요.";
        }
        if (scheduleVO.getSchdlNm() == null || scheduleVO.getSchdlNm().trim().isEmpty()) {
            return "일정명을 입력하세요.";
        }
        if (scheduleVO.getTargetUserIds() == null || scheduleVO.getTargetUserIds().trim().isEmpty()) {
            return "대상자를 선택하세요.";
        }
        if (scheduleVO.getBgngDt() == null || scheduleVO.getBgngDt().trim().isEmpty()
                || scheduleVO.getEndDt() == null || scheduleVO.getEndDt().trim().isEmpty()) {
            return "시작일시와 종료일시를 입력하세요.";
        }
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm[:ss]");
            LocalDateTime bgngDt = LocalDateTime.parse(scheduleVO.getBgngDt(), formatter);
            LocalDateTime endDt = LocalDateTime.parse(scheduleVO.getEndDt(), formatter);
            if (!endDt.isAfter(bgngDt)) {
                return "종료일시는 시작일시보다 이후여야 합니다.";
            }
        } catch (Exception e) {
            return "시작일시 또는 종료일시 형식이 올바르지 않습니다.";
        }
        return null;
    }

    /**
     * 휴가구분에 따라 일정명과 종일여부를 일관되게 보정한다.
     * 연차는 종일, 반차와 시간대 휴가는 시간 지정 일정으로 저장한다.
     * @param scheduleVO 일정구분과 휴가구분을 포함한 저장 VO
     * @return 휴가구분 오류 메시지. 정상인 경우 null
     */
    private String normalizeVacation(ScheduleVO scheduleVO) {
        if (!"VAC".equals(scheduleVO.getSchdlSeCd())) {
            scheduleVO.setVacSeCd(null);
            return null;
        }
        String vacSeCd = scheduleVO.getVacSeCd();
        if ("ANNUAL".equals(vacSeCd)) {
            scheduleVO.setSchdlNm("연차");
            scheduleVO.setAllDayYn("Y");
        } else if ("HALF".equals(vacSeCd)) {
            scheduleVO.setSchdlNm("반차");
            scheduleVO.setAllDayYn("N");
        } else if ("HOURLY".equals(vacSeCd)) {
            scheduleVO.setSchdlNm("시간대");
            scheduleVO.setAllDayYn("N");
        } else {
            return "휴가구분을 선택하세요.";
        }
        return null;
    }

    /**
     * 일정의 연관 프로젝트를 정규화하고 현재 회사 소속 프로젝트인지 검증한다.
     * 휴가 일정은 프로젝트와 연결하지 않으며, 미할당 값은 null로 저장한다.
     * @param scheduleVO 일정구분, 사업ID, 회사ID가 설정된 일정 VO
     * @return 오류 메시지. 정상인 경우 null
     * @throws Exception 사업 상세 조회 중 예외 발생 시 전달
     */
    private String validateAndNormalizeProject(ScheduleVO scheduleVO) throws Exception {
        if ("VAC".equals(scheduleVO.getSchdlSeCd())) {
            scheduleVO.setBizId(null);
            return null;
        }
        String bizId = scheduleVO.getBizId();
        if (bizId == null || bizId.trim().isEmpty()) {
            scheduleVO.setBizId(null);
            return null;
        }
        bizId = bizId.trim();
        BizVO bizVO = new BizVO();
        bizVO.setCoId(scheduleVO.getCoId());
        bizVO.setBizId(bizId);
        if (bizService.selectBizDetail(bizVO) == null) {
            return "선택한 프로젝트가 없거나 현재 회사에 속하지 않습니다.";
        }
        scheduleVO.setBizId(bizId);
        return null;
    }

    /**
     * 기존 사업 목록 조회 기능을 이용해 일정 프로젝트 선택에 필요한 최소 정보만 반환한다.
     * @param coId 로그인 사용자의 회사ID
     * @return 사업ID, 사업코드, 사업명만 포함한 프로젝트 목록
     * @throws Exception 사업 목록 조회 중 예외 발생 시 전달
     */
    private List<BizVO> selectScheduleProjectList(String coId) throws Exception {
        BizVO searchVO = new BizVO();
        searchVO.setCoId(coId);
        searchVO.setRecordCountPerPage(0);
        List<BizVO> projectList = new ArrayList<BizVO>();
        for (BizVO bizVO : bizService.selectBizList(searchVO)) {
            BizVO projectVO = new BizVO();
            projectVO.setBizId(bizVO.getBizId());
            projectVO.setBizCd(bizVO.getBizCd());
            projectVO.setBizNm(bizVO.getBizNm());
            projectList.add(projectVO);
        }
        return projectList;
    }

    /**
     * HTML 날짜/일시 값을 DB 저장 형식으로 보정하고 종일 일정의 시작·종료 시각을 확정한다.
     * @param scheduleVO 시작/종료일시 값을 포함한 VO
     */
    private void normalizeDateTime(ScheduleVO scheduleVO) {
        if ("Y".equals(scheduleVO.getAllDayYn())) {
            String bgngYmd = extractYmd(scheduleVO.getBgngDt());
            String endYmd = extractYmd(scheduleVO.getEndDt());
            scheduleVO.setBgngDt(bgngYmd == null ? null : bgngYmd + " 00:00:00");
            scheduleVO.setEndDt(endYmd == null ? null : endYmd + " 23:59:59");
            return;
        }
        if (scheduleVO.getBgngDt() != null) {
            scheduleVO.setBgngDt(scheduleVO.getBgngDt().replace("T", " "));
        }
        if (scheduleVO.getEndDt() != null) {
            scheduleVO.setEndDt(scheduleVO.getEndDt().replace("T", " "));
        }
    }

    /**
     * HTML date/datetime-local 값에서 yyyy-MM-dd 부분을 추출한다.
     * @param dateTimeValue 날짜 또는 일시 문자열
     * @return yyyy-MM-dd 형식 문자열. 값이 없거나 길이가 부족하면 null
     */
    private String extractYmd(String dateTimeValue) {
        if (dateTimeValue == null || dateTimeValue.trim().length() < 10) {
            return null;
        }
        return dateTimeValue.trim().substring(0, 10);
    }
}
