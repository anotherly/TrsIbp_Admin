package kr.co.TRSolution.trsIbp.admin.mapper;

import java.util.List;
import java.util.Map;

import egovframework.rte.psl.dataaccess.mapper.Mapper;
import kr.co.TRSolution.trsIbp.admin.vo.AdminVO;

@Mapper("adminMapper")
public interface AdminMapper {

    Map<String, Object> selectDashboardSummary() throws Exception;

    List<Map<String, Object>> selectPendingCompanyRequestList() throws Exception;

    List<Map<String, Object>> selectRecentSystemLogList() throws Exception;

    List<Map<String, Object>> selectRecentAdminHistoryList() throws Exception;

    List<Map<String, Object>> selectCompanyRequestList(AdminVO adminVO) throws Exception;

    Map<String, Object> selectCompanyRequestDetail(Integer aplySn) throws Exception;

    Map<String, Object> selectCompanyRequestForUpdate(Integer aplySn) throws Exception;

    int selectApprovedCompanyDuplicateCount(Map<String, Object> requestData) throws Exception;

    int insertApprovedCompany(Map<String, Object> requestData) throws Exception;

    int updateCompanyRequestStatus(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectCompanyList(AdminVO adminVO) throws Exception;

    int updateCompanyUseYn(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectUserList(AdminVO adminVO) throws Exception;

    int updateUserUseYn(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectSystemLogList(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectAdminHistoryList(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectCommonCodeGroupList() throws Exception;

    List<Map<String, Object>> selectCommonCodeList(AdminVO adminVO) throws Exception;

    int updateCommonCodeUseYn(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectOperationPolicyList() throws Exception;

    int updateOperationPolicy(AdminVO adminVO) throws Exception;

    int insertAdminHistory(AdminVO adminVO) throws Exception;

    int insertSystemLog(AdminVO adminVO) throws Exception;

    List<Map<String, Object>> selectUserActionLogList(AdminVO adminVO) throws Exception;
    List<Map<String, Object>> selectSystemNoticeList(AdminVO adminVO) throws Exception;
    int insertSystemNotice(AdminVO adminVO) throws Exception;
    int updateSystemNotice(AdminVO adminVO) throws Exception;
    int deleteSystemNotice(AdminVO adminVO) throws Exception;
}
