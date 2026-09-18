package kr.co.TRSolution.trsIbp.authority.web;

import java.util.Collections;
import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import kr.co.TRSolution.trsIbp.authority.service.AuthorityService;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

@Controller
public class AuthorityController {

    @Resource(name = "authorityService")
    private AuthorityService authorityService;

    @RequestMapping(value = "/authority/authorityManage.do")
    public ModelAndView authorityManage(HttpServletRequest request) {
        requireAdmin(request);
        return new ModelAndView("/authority/authorityManage");
    }

    @RequestMapping(value = "/authority/authorityData.ajax")
    public ModelAndView authorityData(
            @RequestParam(value = "authrtId", required = false) String authrtId,
            HttpServletRequest request) {
        requireAdmin(request);
        ModelAndView mav = new ModelAndView("jsonView");
        mav.addObject("authorityList", authorityService.selectAuthorityList());
        mav.addObject("menuList", authrtId == null || authrtId.trim().isEmpty()
                ? Collections.emptyList() : authorityService.selectMenuAuthorityList(authrtId));
        mav.addObject("result", "OK");
        return mav;
    }

    @RequestMapping(value = "/authority/authoritySave.ajax", method = RequestMethod.POST)
    public ModelAndView authoritySave(
            @RequestParam("authrtId") String authrtId,
            @RequestParam(value = "menuSn", required = false) List<Long> menuSnList,
            HttpServletRequest request) {
        UserVO loginUser = requireAdmin(request);
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            authorityService.saveAuthorityMenu(authrtId, menuSnList, loginUser.getUserId());
            mav.addObject("result", "OK");
        } catch (IllegalArgumentException ex) {
            mav.addObject("result", "FAIL");
            mav.addObject("msg", ex.getMessage());
        }
        return mav;
    }

    @RequestMapping(value = "/authority/authorityInsert.ajax", method = RequestMethod.POST)
    public ModelAndView authorityInsert(
            @RequestParam("authrtId") String authrtId,
            @RequestParam("authrtNm") String authrtNm,
            @RequestParam(value = "authrtExpln", required = false) String authrtExpln,
            HttpServletRequest request) {
        requireAdmin(request);
        return saveAuthorityResult(new AuthorityAction() {
            @Override
            public void execute() {
                authorityService.insertAuthority(authrtId, authrtNm, authrtExpln);
            }
        });
    }

    @RequestMapping(value = "/authority/authorityUpdate.ajax", method = RequestMethod.POST)
    public ModelAndView authorityUpdate(
            @RequestParam("authrtId") String authrtId,
            @RequestParam("authrtNm") String authrtNm,
            @RequestParam(value = "authrtExpln", required = false) String authrtExpln,
            HttpServletRequest request) {
        requireAdmin(request);
        return saveAuthorityResult(new AuthorityAction() {
            @Override
            public void execute() {
                authorityService.updateAuthority(authrtId, authrtNm, authrtExpln);
            }
        });
    }

    @RequestMapping(value = "/authority/authorityDelete.ajax", method = RequestMethod.POST)
    public ModelAndView authorityDelete(
            @RequestParam("authrtId") String authrtId,
            HttpServletRequest request) {
        requireAdmin(request);
        return saveAuthorityResult(new AuthorityAction() {
            @Override
            public void execute() {
                authorityService.deleteAuthority(authrtId);
            }
        });
    }

    private ModelAndView saveAuthorityResult(AuthorityAction action) {
        ModelAndView mav = new ModelAndView("jsonView");
        try {
            action.execute();
            mav.addObject("result", "OK");
        } catch (IllegalArgumentException ex) {
            mav.addObject("result", "FAIL");
            mav.addObject("msg", ex.getMessage());
        }
        return mav;
    }

    private UserVO requireAdmin(HttpServletRequest request) {
        UserVO loginUser = (UserVO) request.getSession().getAttribute("login");
        if (loginUser == null || !"ADMIN".equals(loginUser.getAuthrtId())) {
            throw new IllegalArgumentException("최고관리자 권한이 필요합니다.");
        }
        return loginUser;
    }

    private interface AuthorityAction {
        void execute();
    }
}
