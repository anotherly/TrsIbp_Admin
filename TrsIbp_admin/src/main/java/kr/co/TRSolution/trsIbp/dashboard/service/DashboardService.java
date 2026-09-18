package kr.co.TRSolution.trsIbp.dashboard.service;

import java.util.List;
import java.util.Map;

import kr.co.TRSolution.trsIbp.user.vo.UserVO;

public interface DashboardService {

    Map<String, Object> selectSummary(String workspace, UserVO loginUser);

    List<Map<String, Object>> selectPrimaryList(String workspace, UserVO loginUser);

    List<Map<String, Object>> selectSecondaryList(String workspace, UserVO loginUser);
}
