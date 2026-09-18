package kr.co.TRSolution.trsIbp.comm.file.web;

import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import kr.co.TRSolution.trsIbp.comm.file.service.CommonFileService;
import kr.co.TRSolution.trsIbp.comm.file.vo.CommonFileVO;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

@Controller
public class CommonFileController {

    @Resource(name = "commonFileService")
    private CommonFileService commonFileService;

    @RequestMapping(value = "/common/fileView.do", method = RequestMethod.GET)
    public void viewFile(@RequestParam("atchFileSn") Long atchFileSn,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        writeFile(atchFileSn, true, request, response);
    }

    /**
     * 로그인 사용자의 최신 프로필 사진을 조회한다.
     * 프로필이 없으면 공통 기본 사용자 이미지로 이동한다.
     */
    @RequestMapping(value = "/common/loginProfileView.do", method = RequestMethod.GET)
    public void viewLoginProfile(HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        UserVO loginUser = requireLoginUser(request);
        CommonFileVO profileFile = commonFileService.selectUserProfileFile(
                loginUser.getCoId(), loginUser.getUserId());
        if (profileFile == null) {
            response.sendRedirect(request.getContextPath() + "/images/default-profile.svg");
            return;
        }
        writeFile(profileFile.getAtchFileSn(), true, request, response);
    }

    @RequestMapping(value = "/common/fileDownload.do", method = RequestMethod.GET)
    public void downloadFile(@RequestParam("atchFileSn") Long atchFileSn,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        writeFile(atchFileSn, false, request, response);
    }

    @RequestMapping(value = "/common/userFileDelete.ajax", method = RequestMethod.POST)
    public ModelAndView deleteUserFile(@RequestParam("atchFileSn") Long atchFileSn,
            @RequestParam("userId") String userId, HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            UserVO loginUser = requireLoginUser(request);
            if (!canManageUserFile(loginUser, userId)) {
                throw new IllegalStateException("첨부파일을 삭제할 권한이 없습니다.");
            }
            commonFileService.deleteUserFile(atchFileSn, loginUser.getCoId(), userId);
            mav.addObject("result", "OK");
        } catch (Exception e) {
            mav.addObject("result", "FAIL");
            mav.addObject("msg", e.getMessage());
        }
        return mav;
    }

    public static Map<String, Object> toClientFile(CommonFileVO fileVO) {
        if (fileVO == null) {
            return null;
        }
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("atchFileSn", fileVO.getAtchFileSn());
        result.put("fileSeCd", fileVO.getFileSeCd());
        result.put("orgnlFileNm", fileVO.getOrgnlFileNm());
        result.put("fileSz", fileVO.getFileSz());
        result.put("fileExtnNm", fileVO.getFileExtnNm());
        result.put("regDt", fileVO.getRegDt());
        return result;
    }

    private void writeFile(Long atchFileSn, boolean inline, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        UserVO loginUser = requireLoginUser(request);
        CommonFileVO fileVO = commonFileService.selectFile(atchFileSn);
        if (fileVO == null || !loginUser.getCoId().equals(fileVO.getCoId())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if ("DOCUMENT".equals(fileVO.getFileSeCd())
                && !canManageUserFile(loginUser, fileVO.getRefId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Path file = commonFileService.resolveStoredFile(fileVO);
        if (!Files.isRegularFile(file)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String contentType = Files.probeContentType(file);
        response.setContentType(contentType == null ? "application/octet-stream" : contentType);
        response.setContentLengthLong(Files.size(file));
        String encodedName = URLEncoder.encode(fileVO.getOrgnlFileNm(), "UTF-8").replace("+", "%20");
        response.setHeader("Content-Disposition", (inline ? "inline" : "attachment")
                + "; filename*=UTF-8''" + encodedName);
        response.setHeader("X-Content-Type-Options", "nosniff");
        try (InputStream inputStream = Files.newInputStream(file)) {
            FileCopyUtils.copy(inputStream, response.getOutputStream());
        }
    }

    private UserVO requireLoginUser(HttpServletRequest request) {
        UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
        if (loginUser == null || loginUser.getCoId() == null) {
            throw new IllegalStateException("로그인 정보가 없습니다.");
        }
        return loginUser;
    }

    private boolean canManageUserFile(UserVO loginUser, String targetUserId) {
        return targetUserId != null && (targetUserId.equals(loginUser.getUserId())
                || "ADMIN".equals(loginUser.getAuthrtId())
                || "MANAGER".equals(loginUser.getAuthrtId()));
    }
}
