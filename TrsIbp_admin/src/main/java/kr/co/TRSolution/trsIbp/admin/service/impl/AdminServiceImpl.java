package kr.co.TRSolution.trsIbp.admin.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import kr.co.TRSolution.trsIbp.admin.mapper.AdminMapper;
import kr.co.TRSolution.trsIbp.admin.service.AdminService;
import kr.co.TRSolution.trsIbp.admin.vo.AdminVO;

@Service("adminService")
public class AdminServiceImpl extends EgovAbstractServiceImpl implements AdminService {

    private static final Logger logger = LoggerFactory.getLogger(AdminServiceImpl.class);

    @Resource(name = "adminMapper")
    private AdminMapper adminMapper;

    @Override
    public Map<String, Object> selectDashboardSummary() throws Exception {
        return adminMapper.selectDashboardSummary();
    }

    @Override
    public List<Map<String, Object>> selectPendingCompanyRequestList() throws Exception {
        return adminMapper.selectPendingCompanyRequestList();
    }

    @Override
    public List<Map<String, Object>> selectRecentSystemLogList() throws Exception {
        return adminMapper.selectRecentSystemLogList();
    }

    @Override
    public List<Map<String, Object>> selectRecentAdminHistoryList() throws Exception {
        return adminMapper.selectRecentAdminHistoryList();
    }

    @Override
    public List<Map<String, Object>> selectCompanyRequestList(AdminVO adminVO) throws Exception {
        return adminMapper.selectCompanyRequestList(adminVO);
    }

    @Override
    public Map<String, Object> selectCompanyRequestDetail(Integer aplySn) throws Exception {
        return adminMapper.selectCompanyRequestDetail(aplySn);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String approveCompanyRequest(Integer aplySn, String adminId) throws Exception {
        if (aplySn == null) {
            throw new IllegalArgumentException("승인할 신청번호가 없습니다.");
        }
        Map<String, Object> requestData = adminMapper.selectCompanyRequestForUpdate(aplySn);
        if (requestData == null) {
            throw new IllegalArgumentException("해당 기업 신청을 찾을 수 없습니다.");
        }
        if (!"WAIT".equals(String.valueOf(requestData.get("PRCS_STTS_CD")))) {
            throw new IllegalStateException("이미 처리된 신청입니다.");
        }
        if (adminMapper.selectApprovedCompanyDuplicateCount(requestData) > 0) {
            throw new IllegalStateException("동일 신청번호 또는 사업자번호로 등록된 기업이 이미 있습니다.");
        }

        Map<String, Object> insertData = new HashMap<String, Object>(requestData);
        String coId = "COMP_" + UUID.randomUUID().toString().replace("-", "")
                .substring(0, 8).toUpperCase();
        insertData.put("CO_ID", coId);
        if (adminMapper.insertApprovedCompany(insertData) != 1) {
            throw new IllegalStateException("기업 마스터 생성에 실패했습니다.");
        }

        AdminVO status = new AdminVO();
        status.setAplySn(aplySn);
        status.setPrcsSttsCd("APPR");
        status.setAdminId(adminId);
        if (adminMapper.updateCompanyRequestStatus(status) != 1) {
            throw new IllegalStateException("기업 신청 상태 변경에 실패했습니다.");
        }

        insertHistory(adminId, "COMPANY_APPROVE", "COMPANY_REQUEST",
                String.valueOf(aplySn), "기업가입 신청 승인, 생성 기업ID=" + coId);
        return coId;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void rejectCompanyRequest(Integer aplySn, String rjctRsn, String adminId) throws Exception {
        if (aplySn == null) {
            throw new IllegalArgumentException("반려할 신청번호가 없습니다.");
        }
        String reason = rjctRsn == null ? "" : rjctRsn.trim();
        if (reason.isEmpty()) {
            throw new IllegalArgumentException("반려사유를 입력해 주세요.");
        }
        if (reason.length() > 500) {
            throw new IllegalArgumentException("반려사유는 500자 이하로 입력해 주세요.");
        }

        Map<String, Object> requestData = adminMapper.selectCompanyRequestForUpdate(aplySn);
        if (requestData == null) {
            throw new IllegalArgumentException("해당 기업 신청을 찾을 수 없습니다.");
        }
        if (!"WAIT".equals(String.valueOf(requestData.get("PRCS_STTS_CD")))) {
            throw new IllegalStateException("이미 처리된 신청입니다.");
        }

        AdminVO status = new AdminVO();
        status.setAplySn(aplySn);
        status.setPrcsSttsCd("REJECT");
        status.setRjctRsn(reason);
        status.setAdminId(adminId);
        if (adminMapper.updateCompanyRequestStatus(status) != 1) {
            throw new IllegalStateException("기업 신청 상태 변경에 실패했습니다.");
        }
        insertHistory(adminId, "COMPANY_REJECT", "COMPANY_REQUEST",
                String.valueOf(aplySn), "기업가입 신청 반려, 사유=" + reason);
    }

    @Override
    public List<Map<String, Object>> selectCompanyList(AdminVO adminVO) throws Exception {
        return adminMapper.selectCompanyList(adminVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCompanyUseYn(String coId, String useYn, String adminId) throws Exception {
        validateUseYn(useYn);
        AdminVO param = new AdminVO();
        param.setCoId(requireValue(coId, "기업ID"));
        param.setUseYn(useYn);
        if (adminMapper.updateCompanyUseYn(param) != 1) {
            throw new IllegalArgumentException("변경할 기업을 찾을 수 없습니다.");
        }
        insertHistory(adminId, "COMPANY_USE_UPDATE", "COMPANY", coId,
                "기업 사용여부를 " + useYn + "로 변경");
    }

    @Override
    public List<Map<String, Object>> selectUserList(AdminVO adminVO) throws Exception {
        return adminMapper.selectUserList(adminVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateUserUseYn(String userId, String useYn, String adminId) throws Exception {
        validateUseYn(useYn);
        String targetId = requireValue(userId, "사용자ID");
        if (targetId.equals(adminId)) {
            throw new IllegalArgumentException("현재 로그인한 시스템관리자 계정은 정지할 수 없습니다.");
        }
        AdminVO param = new AdminVO();
        param.setUserId(targetId);
        param.setUseYn(useYn);
        if (adminMapper.updateUserUseYn(param) != 1) {
            throw new IllegalArgumentException("변경할 사용자를 찾을 수 없습니다.");
        }
        insertHistory(adminId, "USER_USE_UPDATE", "USER", targetId,
                "사용자 사용여부를 " + useYn + "로 변경");
    }

    @Override
    public List<Map<String, Object>> selectSystemLogList(AdminVO adminVO) throws Exception {
        return adminMapper.selectSystemLogList(adminVO);
    }

    @Override
    public List<Map<String, Object>> selectAdminHistoryList(AdminVO adminVO) throws Exception {
        return adminMapper.selectAdminHistoryList(adminVO);
    }

    @Override
    public List<Map<String, Object>> selectCommonCodeGroupList() throws Exception {
        return adminMapper.selectCommonCodeGroupList();
    }

    @Override
    public List<Map<String, Object>> selectCommonCodeList(AdminVO adminVO) throws Exception {
        return adminMapper.selectCommonCodeList(adminVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCommonCodeUseYn(String cdGroupId, String cd, String useYn,
            String adminId) throws Exception {
        validateUseYn(useYn);
        AdminVO param = new AdminVO();
        param.setCdGroupId(requireValue(cdGroupId, "코드그룹ID"));
        param.setCd(requireValue(cd, "코드"));
        param.setUseYn(useYn);
        if (adminMapper.updateCommonCodeUseYn(param) != 1) {
            throw new IllegalArgumentException("변경할 공통코드를 찾을 수 없습니다.");
        }
        insertHistory(adminId, "COMMON_CODE_UPDATE", "COMMON_CODE",
                cdGroupId + ":" + cd, "공통코드 사용여부를 " + useYn + "로 변경");
    }

    @Override
    public List<Map<String, Object>> selectOperationPolicyList() throws Exception {
        return adminMapper.selectOperationPolicyList();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateOperationPolicy(String policyId, String policyValue,
            String adminId) throws Exception {
        String value = policyValue == null ? "" : policyValue.trim();
        if (value.length() > 1000) {
            throw new IllegalArgumentException("운영정책 값은 1000자 이하로 입력해 주세요.");
        }
        AdminVO param = new AdminVO();
        param.setPolicyId(requireValue(policyId, "정책ID"));
        param.setPolicyValue(value);
        param.setAdminId(adminId);
        if (adminMapper.updateOperationPolicy(param) != 1) {
            throw new IllegalArgumentException("변경할 운영정책을 찾을 수 없습니다.");
        }
        insertHistory(adminId, "POLICY_UPDATE", "OPERATION_POLICY", policyId,
                "운영정책 값을 변경");
    }

    @Override
    public void recordSystemLog(AdminVO adminVO) {
        try {
            adminMapper.insertSystemLog(adminVO);
        } catch (Exception e) {
            logger.warn("시스템 로그 DB 기록 실패: " + e.toString());
        }
    }

    private void insertHistory(String adminId, String actionSeCd, String targetSeCd,
            String targetId, String actionCn) throws Exception {
        AdminVO history = new AdminVO();
        history.setAdminId(adminId);
        history.setActionSeCd(actionSeCd);
        history.setTargetSeCd(targetSeCd);
        history.setTargetId(targetId);
        history.setActionCn(actionCn);
        adminMapper.insertAdminHistory(history);
    }

    private void validateUseYn(String useYn) {
        if (!"Y".equals(useYn) && !"N".equals(useYn)) {
            throw new IllegalArgumentException("사용여부 값이 올바르지 않습니다.");
        }
    }

    private String requireValue(String value, String name) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(name + " 값이 없습니다.");
        }
        return value.trim();
    }
}
