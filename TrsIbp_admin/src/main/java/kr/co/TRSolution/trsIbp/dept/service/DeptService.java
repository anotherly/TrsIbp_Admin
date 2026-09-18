package kr.co.TRSolution.trsIbp.dept.service;

import java.util.List;
import java.util.Map;
import kr.co.TRSolution.trsIbp.dept.vo.DeptVO;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

public interface DeptService {
	
    public List<DeptVO> selectDeptList(UserVO userVO);

    void insertDept(DeptVO deptVO) throws Exception;
    /** 부서 목록 조회 (트리구조용) */
    List<Map<String, Object>> selectDeptTreeList(DeptVO deptVO) throws Exception;
    DeptVO selectDeptDetail(DeptVO deptVO) throws Exception;
    void updateDept(DeptVO deptVO) throws Exception;
    void deleteDept(DeptVO deptVO) throws Exception;
    Map<String, Object> selectOrganizationSummary(DeptVO deptVO) throws Exception;
    List<DeptVO> selectOrganizationList(DeptVO deptVO) throws Exception;
    List<UserVO> selectOrganizationMemberList(DeptVO deptVO) throws Exception;
}
