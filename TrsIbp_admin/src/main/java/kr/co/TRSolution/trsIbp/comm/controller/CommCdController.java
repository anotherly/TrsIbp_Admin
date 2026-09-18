package kr.co.TRSolution.trsIbp.comm.controller;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import kr.co.TRSolution.trsIbp.comm.service.CommCdService;
import kr.co.TRSolution.trsIbp.comm.vo.CommCdVO;

/**
 * 공통코드 Controller
 * - 화면에서 필요한 코드 그룹을 한 번에 조회한다.
 */
@Controller
public class CommCdController {

    @Resource(name = "commCdService")
    private CommCdService commCdService;

    /**
     * 쉼표로 전달된 코드 그룹 ID 목록의 공통코드를 조회한다.
     * @param cdGroupIds 쉼표 구분 코드 그룹 ID 문자열
     * @return jsonView: result, list, codeMap
     * @throws Exception 공통코드 조회 중 예외 발생 시 전달
     */
    @RequestMapping(value = "/comm/codeList.ajax")
    public ModelAndView selectCommCdList(String cdGroupIds) throws Exception {
        ModelAndView mav = new ModelAndView("jsonView");
        CommCdVO param = new CommCdVO();
        param.setCdGroupIdList(parseCdGroupIds(cdGroupIds));

        List<CommCdVO> list = commCdService.selectCommCdList(param);
        Map<String, List<CommCdVO>> codeMap = new LinkedHashMap<String, List<CommCdVO>>();
        for (CommCdVO code : list) {
            if (!codeMap.containsKey(code.getCdGroupId())) {
                codeMap.put(code.getCdGroupId(), new ArrayList<CommCdVO>());
            }
            codeMap.get(code.getCdGroupId()).add(code);
        }

        mav.addObject("result", "OK");
        mav.addObject("list", list);
        mav.addObject("codeMap", codeMap);
        return mav;
    }

    /**
     * 쉼표 구분 코드 그룹 문자열을 목록으로 변환한다.
     * @param cdGroupIds 쉼표 구분 코드 그룹 ID 문자열
     * @return 공백과 빈 값을 제거한 코드 그룹 ID 목록
     */
    private List<String> parseCdGroupIds(String cdGroupIds) {
        List<String> list = new ArrayList<String>();
        if (cdGroupIds == null || cdGroupIds.trim().isEmpty()) {
            return list;
        }

        String[] arr = cdGroupIds.split(",");
        for (String item : arr) {
            String value = item == null ? "" : item.trim();
            if (!value.isEmpty()) {
                list.add(value);
            }
        }
        return list;
    }
}
