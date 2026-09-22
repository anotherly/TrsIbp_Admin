package kr.co.TRSolution.trsIbp.admin.web;

import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.co.TRSolution.trsIbp.admin.service.AdminService;
import kr.co.TRSolution.trsIbp.admin.vo.AdminVO;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

@Controller
public class AdminController {

    private static final Logger logger = LoggerFactory.getLogger(AdminController.class);

    @Resource(name = "adminService")
    private AdminService adminService;

    @Resource(name = "propertiesService")
    private EgovPropertyService propertiesService;

    @RequestMapping(value = {"/main/main.do", "/admin/dashboard.do"}, method = RequestMethod.GET)
    public ModelAndView dashboard(HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        ModelAndView mav = new ModelAndView("/admin/dashboard");
        mav.addObject("summary", adminService.selectDashboardSummary());
        mav.addObject("pendingList", adminService.selectPendingCompanyRequestList());
        mav.addObject("systemLogList", adminService.selectRecentSystemLogList());
        mav.addObject("historyList", adminService.selectRecentAdminHistoryList());
        return mav;
    }

    @RequestMapping(value = "/admin/companyRequestList.do", method = RequestMethod.GET)
    public ModelAndView companyRequestList(@ModelAttribute AdminVO adminVO,
            HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        ModelAndView mav = new ModelAndView("/admin/companyRequestList");
        mav.addObject("list", adminService.selectCompanyRequestList(adminVO));
        mav.addObject("search", adminVO);
        return mav;
    }

    @RequestMapping(value = "/admin/companyRequestDetail.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView companyRequestDetail(@RequestParam("aplySn") Integer aplySn,
            HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            requireSystemAdmin(request);
            Map<String, Object> detail = adminService.selectCompanyRequestDetail(aplySn);
            if (detail == null) {
                throw new IllegalArgumentException("신청 정보를 찾을 수 없습니다.");
            }
            mav.addObject("result", "OK");
            mav.addObject("detail", detail);
        } catch (Exception e) {
            addError(mav, request, "기업 신청 상세 조회 실패", e);
        }
        return mav;
    }

    @RequestMapping(value = "/admin/companyRequestApprove.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView approveCompanyRequest(@RequestParam("aplySn") Integer aplySn,
            HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = requireSystemAdmin(request);
            String coId = adminService.approveCompanyRequest(aplySn, loginUser.getUserId());
            mav.addObject("result", "OK");
            mav.addObject("coId", coId);
            mav.addObject("msg", "기업가입 신청을 승인했습니다.");
        } catch (Exception e) {
            addError(mav, request, "기업가입 승인 처리 실패", e);
        }
        return mav;
    }

    @RequestMapping(value = "/admin/companyRequestReject.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView rejectCompanyRequest(@RequestParam("aplySn") Integer aplySn,
            @RequestParam("rjctRsn") String rjctRsn, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = requireSystemAdmin(request);
            adminService.rejectCompanyRequest(aplySn, rjctRsn, loginUser.getUserId());
            mav.addObject("result", "OK");
            mav.addObject("msg", "기업가입 신청을 반려했습니다.");
        } catch (Exception e) {
            addError(mav, request, "기업가입 반려 처리 실패", e);
        }
        return mav;
    }

    @RequestMapping(value = "/admin/companyRequestFile.do", method = RequestMethod.GET)
    public void companyRequestFile(@RequestParam("aplySn") Integer aplySn,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        requireSystemAdmin(request);
        Map<String, Object> detail = adminService.selectCompanyRequestDetail(aplySn);
        if (detail == null || detail.get("ENCPT_FILE_NM") == null
                || detail.get("FILE_PATH_NM") == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path root = getUploadRoot();
        Path filePath = resolveRequestFile(root, String.valueOf(detail.get("FILE_PATH_NM")),
                String.valueOf(detail.get("ENCPT_FILE_NM")));
        if (!Files.isRegularFile(filePath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String originalName = String.valueOf(detail.get("ORGNL_FILE_NM"));
        String encodedName = URLEncoder.encode(originalName, "UTF-8").replace("+", "%20");
        String contentType = Files.probeContentType(filePath);
        response.setContentType(contentType == null ? "application/octet-stream" : contentType);
        response.setContentLengthLong(Files.size(filePath));
        response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedName);
        response.setHeader("X-Content-Type-Options", "nosniff");
        try (InputStream inputStream = Files.newInputStream(filePath)) {
            FileCopyUtils.copy(inputStream, response.getOutputStream());
        }
    }

    @RequestMapping(value = "/admin/companyList.do", method = RequestMethod.GET)
    public ModelAndView companyList(@ModelAttribute AdminVO adminVO,
            HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        ModelAndView mav = new ModelAndView("/admin/companyList");
        mav.addObject("list", adminService.selectCompanyList(adminVO));
        mav.addObject("search", adminVO);
        return mav;
    }

    @RequestMapping(value = "/admin/companyUseUpdate.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView companyUseUpdate(@RequestParam("coId") String coId,
            @RequestParam("useYn") String useYn, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = requireSystemAdmin(request);
            adminService.updateCompanyUseYn(coId, useYn, loginUser.getUserId());
            mav.addObject("result", "OK");
            mav.addObject("msg", "기업 사용상태를 변경했습니다.");
        } catch (Exception e) {
            addError(mav, request, "기업 사용상태 변경 실패", e);
        }
        return mav;
    }

    @RequestMapping(value = "/admin/userList.do", method = RequestMethod.GET)
    public ModelAndView userList(@ModelAttribute AdminVO adminVO,
            HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        ModelAndView mav = new ModelAndView("/admin/userList");
        mav.addObject("list", adminService.selectUserList(adminVO));
        mav.addObject("search", adminVO);
        return mav;
    }

    @RequestMapping(value = "/admin/userUseUpdate.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView userUseUpdate(@RequestParam("userId") String userId,
            @RequestParam("useYn") String useYn, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = requireSystemAdmin(request);
            adminService.updateUserUseYn(userId, useYn, loginUser.getUserId());
            mav.addObject("result", "OK");
            mav.addObject("msg", "회원 사용상태를 변경했습니다.");
        } catch (Exception e) {
            addError(mav, request, "회원 사용상태 변경 실패", e);
        }
        return mav;
    }

    @RequestMapping(value = "/admin/systemLogList.do", method = RequestMethod.GET)
    public ModelAndView systemLogList(@ModelAttribute AdminVO adminVO,
            HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        ModelAndView mav = new ModelAndView("/admin/systemLogList");
        mav.addObject("list", adminService.selectSystemLogList(adminVO));
        mav.addObject("search", adminVO);
        return mav;
    }

    @RequestMapping(value = "/admin/actionHistoryList.do", method = RequestMethod.GET)
    public ModelAndView actionHistoryList(@ModelAttribute AdminVO adminVO,
            HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        ModelAndView mav = new ModelAndView("/admin/actionHistoryList");
        mav.addObject("list", adminService.selectAdminHistoryList(adminVO));
        mav.addObject("search", adminVO);
        return mav;
    }

    @RequestMapping(value = "/admin/userActionLogList.do", method = RequestMethod.GET)
    public ModelAndView userActionLogList(@ModelAttribute AdminVO adminVO, HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        ModelAndView mav = new ModelAndView("/admin/userActionLogList");
        mav.addObject("list", adminService.selectUserActionLogList(adminVO));
        mav.addObject("search", adminVO);
        return mav;
    }

    @RequestMapping(value = "/admin/systemNoticeList.do", method = RequestMethod.GET)
    public ModelAndView systemNoticeList(@ModelAttribute AdminVO adminVO, HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        ModelAndView mav = new ModelAndView("/admin/systemNoticeList");
        mav.addObject("list", adminService.selectSystemNoticeList(adminVO));
        mav.addObject("search", adminVO);
        return mav;
    }

    @RequestMapping(value = "/admin/systemNoticeSave.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView systemNoticeSave(@ModelAttribute AdminVO adminVO, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try { UserVO u=requireSystemAdmin(request); adminService.saveSystemNotice(adminVO,u.getUserId()); mav.addObject("result","OK"); }
        catch(Exception e){ addError(mav,request,"시스템 공지 저장 실패",e); }
        return mav;
    }

    @RequestMapping(value = "/admin/systemNoticeDelete.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView systemNoticeDelete(@RequestParam("noticeSn") Long noticeSn, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try { UserVO u=requireSystemAdmin(request); adminService.deleteSystemNotice(noticeSn,u.getUserId()); mav.addObject("result","OK"); }
        catch(Exception e){ addError(mav,request,"시스템 공지 삭제 실패",e); }
        return mav;
    }

    @RequestMapping(value = "/admin/operationPolicy.do", method = RequestMethod.GET)
    public ModelAndView operationPolicy(@ModelAttribute AdminVO adminVO,
            HttpServletRequest request) throws Exception {
        requireSystemAdmin(request);
        if (adminVO.getCdGroupId() == null || adminVO.getCdGroupId().trim().isEmpty()) {
            adminVO.setCdGroupId("BIZ_STTS_CD");
        }
        ModelAndView mav = new ModelAndView("/admin/operationPolicy");
        mav.addObject("groupList", adminService.selectCommonCodeGroupList());
        mav.addObject("codeList", adminService.selectCommonCodeList(adminVO));
        mav.addObject("policyList", adminService.selectOperationPolicyList());
        mav.addObject("search", adminVO);
        return mav;
    }

    @RequestMapping(value = "/admin/commonCodeUseUpdate.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView commonCodeUseUpdate(@RequestParam("cdGroupId") String cdGroupId,
            @RequestParam("cd") String cd, @RequestParam("useYn") String useYn,
            HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = requireSystemAdmin(request);
            adminService.updateCommonCodeUseYn(cdGroupId, cd, useYn, loginUser.getUserId());
            mav.addObject("result", "OK");
            mav.addObject("msg", "공통코드 사용상태를 변경했습니다.");
        } catch (Exception e) {
            addError(mav, request, "공통코드 변경 실패", e);
        }
        return mav;
    }

    @RequestMapping(value = "/admin/operationPolicyUpdate.ajax", method = RequestMethod.POST)
    @ResponseBody
    public ModelAndView operationPolicyUpdate(@RequestParam("policyId") String policyId,
            @RequestParam("policyValue") String policyValue, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = requireSystemAdmin(request);
            adminService.updateOperationPolicy(policyId, policyValue, loginUser.getUserId());
            mav.addObject("result", "OK");
            mav.addObject("msg", "운영정책을 저장했습니다.");
        } catch (Exception e) {
            addError(mav, request, "운영정책 저장 실패", e);
        }
        return mav;
    }

    private UserVO requireSystemAdmin(HttpServletRequest request) {
        UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
        if (loginUser == null || !"SYS_ADMIN".equals(loginUser.getAuthrtId())) {
            throw new IllegalStateException("시스템관리자 권한이 필요합니다.");
        }
        return loginUser;
    }

    private void addError(ModelAndView mav, HttpServletRequest request, String title, Exception e) {
        logger.error(title + ": " + e.toString());
        mav.addObject("result", "FAIL");
        mav.addObject("msg", e.getMessage() == null ? title : e.getMessage());

        AdminVO log = new AdminVO();
        UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
        log.setUserId(loginUser == null ? null : loginUser.getUserId());
        log.setLogSeCd("SERVER_ERROR");
        log.setLogLevelCd("ERROR");
        log.setLogTitle(title);
        log.setLogCn(e.toString());
        log.setRequestUri(request.getRequestURI());
        log.setClientIpAddr(getClientIp(request));
        adminService.recordSystemLog(log);
    }

    private Path getUploadRoot() {
        String configuredRoot = System.getProperty("trs.fileUploadRoot");
        if (configuredRoot == null || configuredRoot.trim().isEmpty()) {
            configuredRoot = System.getenv("TRS_FILE_UPLOAD_ROOT");
        }
        if (configuredRoot == null || configuredRoot.trim().isEmpty()) {
            configuredRoot = propertiesService.getString("fileUploadRoot");
        }
        if (configuredRoot == null || configuredRoot.trim().isEmpty()) {
            configuredRoot = "C:/trsStorage";
        }
        return Paths.get(configuredRoot).toAbsolutePath().normalize();
    }

    private Path resolveRequestFile(Path root, String storedPath, String storedName) {
        if (storedPath.contains("..") || storedName.contains("..")
                || storedName.contains("/") || storedName.contains("\\")) {
            throw new IllegalArgumentException("첨부파일 경로가 올바르지 않습니다.");
        }
        Path path = Paths.get(storedPath);
        Path resolved = path.isAbsolute() ? path.resolve(storedName).normalize()
                : root.resolve(path).resolve(storedName).normalize();
        if (!resolved.startsWith(root)) {
            throw new IllegalArgumentException("첨부파일 경로가 허용 범위를 벗어났습니다.");
        }
        return resolved;
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.trim().isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
