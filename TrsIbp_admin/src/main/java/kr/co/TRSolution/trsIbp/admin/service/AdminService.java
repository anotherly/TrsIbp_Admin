package kr.co.TRSolution.trsIbp.admin.service;

import java.util.List;
import java.util.Map;

import kr.co.TRSolution.trsIbp.admin.vo.AdminVO;

public interface AdminService {

    Map<String, Object> selectDashboardSummary() throws Exception;

    List<Map<String, Object>> selectPendingCompanyRequestList() throws Exception;

    List<Map<String, Object>> selectRecentSystemLogList() throws Exception;

    List<Map<String, Object>> selectRecentAdminHistoryList() throws Exception;

    List<Map<String, Object>> selectCompanyRequestList(AdminVO adminVO) throws Exception;

    Map<String, Object> selectCompanyRequestDetail(Integer aplySn) throws Exception;

    String approveCompanyRequest(Integer aplySn, String adminId) throws Exception;

    void rejectCompanyRequest(Integer aplySn, String rjctRsn, String adminId) throws Exception;

    List<Map<String, Object>> selectCompanyList(AdminVO adminVO) throws Exception;

    void updateCompanyUseYn(String coId, String useYn, String adminId) throws Exception;

    List<Map<String, Object>> selectUserList(AdminVO adminVO) throws Exception;

    void updateUserUseYn(String userId, String useYn, String adminId) throws Exception;

    List<Map<String, Object>> selectSystemLogList(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectAdminHistoryList(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectCommonCodeGroupList() throws Exception;

    List<Map<String, Object>> selectCommonCodeList(AdminVO adminVO) throws Exception;

    void updateCommonCodeUseYn(String cdGroupId, String cd, String useYn, String adminId) throws Exception;

    List<Map<String, Object>> selectOperationPolicyList() throws Exception;

    void updateOperationPolicy(String policyId, String policyValue, String adminId) throws Exception;

    void recordSystemLog(AdminVO adminVO);

    List<Map<String, Object>> selectUserActionLogList(AdminVO adminVO) throws Exception;
    List<Map<String, Object>> selectSystemNoticeList(AdminVO adminVO) throws Exception;
    void saveSystemNotice(AdminVO adminVO, String adminId) throws Exception;
    void deleteSystemNotice(Long noticeSn, String adminId) throws Exception;
}
