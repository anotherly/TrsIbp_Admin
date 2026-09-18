package kr.co.TRSolution.trsIbp.comm.controller;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import kr.co.TRSolution.trsIbp.user.service.UserService;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

/**
 * 공통 업무 Controller
 * - 여러 업무 화면에서 재사용하는 공통 Ajax 기능을 제공한다.
 */
@Controller
public class CommonController {

    @Resource(name = "userService")
    private UserService userService;

    /**
     * 로그인 사용자의 회사 기준으로 사용자 선택 모달의 부서/사용자 목록을 조회한다.
     * @param userVO deptId, searchKeyword 등 사용자 선택 검색조건을 담은 VO
     * @param request 로그인 사용자 회사ID 확인용 HttpServletRequest
     * @return jsonView: result, deptList, userList
     * @throws Exception 부서/사용자 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/common/userSelectList.ajax")
    public ModelAndView selectUserSelectList(@ModelAttribute("userVO") UserVO userVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
        userVO.setCoId(reqLoginVo.getCoId());
        List<UserVO> deptList = userService.selectUserSelectDeptList(userVO);
        List<UserVO> userList = userService.selectUserSelectUserList(userVO);

        mav.addObject("result", "OK");
        mav.addObject("deptList", deptList);
        mav.addObject("userList", userList);
        return mav;
    }


    /**
     * 로그인 사용자의 회사 기준으로 부서 선택 모달에 사용할 부서 목록을 조회한다.
     * @param userVO 검색어 등 부서 선택 검색조건을 담은 VO
     * @param request 로그인 사용자 회사ID 확인용 HttpServletRequest
     * @return jsonView: result, deptList
     * @throws Exception 부서 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/common/deptSelectList.ajax")
    public ModelAndView selectDeptSelectList(@ModelAttribute("userVO") UserVO userVO, HttpServletRequest request) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        UserVO reqLoginVo = (UserVO) request.getSession().getAttribute("login");
        userVO.setCoId(reqLoginVo.getCoId());
        List<UserVO> deptList = userService.selectUserSelectDeptList(userVO);

        mav.addObject("result", "OK");
        mav.addObject("deptList", deptList);
        return mav;
    }

}