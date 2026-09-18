package kr.co.TRSolution.trsIbp.dashboard.mapper;

import java.util.List;
import java.util.Map;

import egovframework.rte.psl.dataaccess.mapper.Mapper;

@Mapper("dashboardMapper")
public interface DashboardMapper {

    Map<String, Object> selectWorkSummary(Map<String, Object> param);

    List<Map<String, Object>> selectWorkTodayScheduleList(Map<String, Object> param);

    Map<String, Object> selectProjectSummary(Map<String, Object> param);

    List<Map<String, Object>> selectProjectStatusList(Map<String, Object> param);

    List<Map<String, Object>> selectProjectScheduleList(Map<String, Object> param);

    Map<String, Object> selectOrgSummary(Map<String, Object> param);

    List<Map<String, Object>> selectOrgDeptStatusList(Map<String, Object> param);

    List<Map<String, Object>> selectOrgTodayScheduleList(Map<String, Object> param);

    Map<String, Object> selectManagementSummary(Map<String, Object> param);

    List<Map<String, Object>> selectManagementProjectList(Map<String, Object> param);
}
