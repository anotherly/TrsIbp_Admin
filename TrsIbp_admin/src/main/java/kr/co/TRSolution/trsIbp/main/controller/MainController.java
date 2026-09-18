package kr.co.TRSolution.trsIbp.main.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.annotation.Resource;

import java.util.Collections;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import kr.co.TRSolution.trsIbp.authority.service.AuthorityService;
import kr.co.TRSolution.trsIbp.dashboard.service.DashboardService;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

/**
 * 메인 화면 컨트롤러.
 *
 * <p>역할:</p>
 * <ul>
 *   <li>루트 index.jsp에서 세션 확인 후 이동하는 메인 대시보드 화면을 반환한다.</li>
 *   <li>실제 JSP 파일 위치는 /WEB-INF/jsp/main/main.jsp 이다.</li>
 * </ul>
 *
 * <p>URL:</p>
 * <ul>
 *   <li>/main/main.do</li>
 * </ul>
 */
@Controller
public class MainController {

    private static final Logger logger = LoggerFactory.getLogger(MainController.class);

    @Resource(name = "authorityService")
    private AuthorityService authorityService;

    @Resource(name = "dashboardService")
    private DashboardService dashboardService;

    /**
     * 메인 대시보드 화면으로 이동한다.
     *
     * @param session 현재 HTTP 세션. login 속성은 LoginInterceptor 또는 JSP 공통 head에서 검증한다.
     * @param request 현재 요청 객체. 로그 기록 및 확장용으로 사용한다.
     * @return ViewResolver 기준 JSP 경로. /WEB-INF/jsp/main/main.jsp 로 해석된다.
     * @throws Exception 화면 이동 중 예외 발생 시 상위로 전달한다.
     */
    @RequestMapping(value = "/main/main.do")
    public String main(@RequestParam(value = "workspace", required = false) String workspace,
            HttpSession session, HttpServletRequest request) throws Exception {
        UserVO loginUser = (UserVO) session.getAttribute("login");
        authorityService.refreshSessionAuthority(session, loginUser);
        String selectedWorkspace = resolveWorkspace(loginUser, workspace,
                (String) session.getAttribute("selectedWorkspace"), session);
        session.setAttribute("selectedWorkspace", selectedWorkspace);
        request.setAttribute("selectedWorkspace", selectedWorkspace);
        if (loginUser != null) {
            Map<String, Object> summary = dashboardService.selectSummary(selectedWorkspace, loginUser);
            request.setAttribute("dashboardSummary", summary == null
                    ? Collections.<String, Object>emptyMap() : summary);
            request.setAttribute("dashboardPrimaryList",
                    dashboardService.selectPrimaryList(selectedWorkspace, loginUser));
            request.setAttribute("dashboardSecondaryList",
                    dashboardService.selectSecondaryList(selectedWorkspace, loginUser));
            request.setAttribute("canViewContractAmount",
                    hasMenuCode(session, "PROJECT_CONTRACT_LIST"));
            request.setAttribute("canViewCostAmount",
                    hasMenuCode(session, "PROJECT_ACCOUNT_LIST"));
            request.setAttribute("canViewScheduleWidget",
                    hasMenuCode(session, "WORK_SCHEDULE_LIST")
                    && hasMenuCode(session, "WORK_SCHEDULE_META")
                    && hasMenuCode(session, "WORK_SCHEDULE_DASHBOARD"));
        }
        logger.debug("▶▶▶▶▶▶▶.메인 대시보드 화면 이동 : {}", request.getRequestURI());
        return "/main/main";
    }

    @RequestMapping(value = "/main/defaultWorkspace.ajax", method = RequestMethod.POST)
    public ModelAndView saveDefaultWorkspace(@RequestParam("workspace") String workspace,
            HttpSession session) {
        ModelAndView mav = new ModelAndView("jsonView");
        UserVO loginUser = (UserVO) session.getAttribute("login");
        String workspaceId = workspace == null ? "" : workspace.trim().toUpperCase();
        if (!authorityService.isWorkspaceAllowed(session, workspaceId)) {
            mav.addObject("result", "DENIED");
            mav.addObject("msg", "기본 업무공간으로 지정할 권한이 없습니다.");
            return mav;
        }
        authorityService.saveDefaultWorkspace(loginUser, workspaceId);
        session.setAttribute("defaultWorkspaceId", workspaceId);
        mav.addObject("result", "OK");
        return mav;
    }

    private String resolveWorkspace(UserVO loginUser, String requestedWorkspace,
            String currentWorkspace, HttpSession session) {
        String candidate = requestedWorkspace == null || requestedWorkspace.trim().isEmpty()
                ? currentWorkspace : requestedWorkspace.trim().toLowerCase();
        if (candidate == null || candidate.isEmpty()) {
            Object defaultWorkspace = session.getAttribute("defaultWorkspaceId");
            candidate = defaultWorkspace == null ? "work"
                    : String.valueOf(defaultWorkspace).toLowerCase();
        }

        if (authorityService.isWorkspaceAllowed(session, candidate.toUpperCase())) {
            return candidate;
        }
        return "work";
    }

    @SuppressWarnings("unchecked")
    private boolean hasMenuCode(HttpSession session, String menuCode) {
        Object menuCodes = session.getAttribute("grantedMenuCodes");
        return menuCodes instanceof Set && ((Set<String>) menuCodes).contains(menuCode);
    }
}
