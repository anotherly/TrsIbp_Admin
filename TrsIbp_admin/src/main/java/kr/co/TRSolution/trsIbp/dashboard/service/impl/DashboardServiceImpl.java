package kr.co.TRSolution.trsIbp.dashboard.service.impl;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import kr.co.TRSolution.trsIbp.dashboard.mapper.DashboardMapper;
import kr.co.TRSolution.trsIbp.dashboard.service.DashboardService;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

@Service("dashboardService")
public class DashboardServiceImpl implements DashboardService {

    @Resource(name = "dashboardMapper")
    private DashboardMapper dashboardMapper;

    @Override
    public Map<String, Object> selectSummary(String workspace, UserVO loginUser) {
        Map<String, Object> param = createParam(loginUser);
        if ("project".equals(workspace)) {
            return dashboardMapper.selectProjectSummary(param);
        }
        if ("org".equals(workspace)) {
            return dashboardMapper.selectOrgSummary(param);
        }
        if ("management".equals(workspace)) {
            return dashboardMapper.selectManagementSummary(param);
        }
        return dashboardMapper.selectWorkSummary(param);
    }

    @Override
    public List<Map<String, Object>> selectPrimaryList(String workspace, UserVO loginUser) {
        Map<String, Object> param = createParam(loginUser);
        if ("project".equals(workspace)) {
            return dashboardMapper.selectProjectStatusList(param);
        }
        if ("org".equals(workspace)) {
            return dashboardMapper.selectOrgDeptStatusList(param);
        }
        if ("management".equals(workspace)) {
            return dashboardMapper.selectManagementProjectList(param);
        }
        return dashboardMapper.selectWorkTodayScheduleList(param);
    }

    @Override
    public List<Map<String, Object>> selectSecondaryList(String workspace, UserVO loginUser) {
        Map<String, Object> param = createParam(loginUser);
        if ("project".equals(workspace)) {
            return dashboardMapper.selectProjectScheduleList(param);
        }
        if ("org".equals(workspace)) {
            return dashboardMapper.selectOrgTodayScheduleList(param);
        }
        return Collections.emptyList();
    }

    private Map<String, Object> createParam(UserVO loginUser) {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("userId", loginUser.getUserId());
        param.put("coId", loginUser.getCoId());
        param.put("deptId", loginUser.getDeptId());
        param.put("allCompanyYn", "ADMIN".equals(loginUser.getAuthrtId()) ? "Y" : "N");
        return param;
    }
}
