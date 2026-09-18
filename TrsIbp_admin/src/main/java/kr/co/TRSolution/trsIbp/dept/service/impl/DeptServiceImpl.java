package kr.co.TRSolution.trsIbp.dept.service.impl;

import java.util.List;
import java.util.Map;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import kr.co.TRSolution.trsIbp.dept.mapper.DeptMapper;
import kr.co.TRSolution.trsIbp.dept.service.DeptService;
import kr.co.TRSolution.trsIbp.dept.vo.DeptVO;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

@Service("deptService")
public class DeptServiceImpl implements DeptService {

    @Resource(name = "deptMapper")
    private DeptMapper deptMapper;

    @Override
    public List<DeptVO> selectDeptList(UserVO userVO) {
        return deptMapper.selectDeptList(userVO);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void insertDept(DeptVO deptVO) throws Exception {
        normalizeAndValidate(deptVO, true);
        if (deptMapper.selectDeptIdCount(deptVO) > 0) {
            throw new IllegalArgumentException("이미 사용 중인 조직 코드입니다.");
        }
        deptMapper.insertDept(deptVO);
    }

    /** 부서 목록 조회 (트리구조용) */
    @Override
    public List<Map<String, Object>> selectDeptTreeList(DeptVO deptVO) throws Exception {
        // 부서 목록을 LinkedHashMap으로 순서 보장하여 호출
        return deptMapper.selectDeptTreeList(deptVO);
    }

    @Override
    public DeptVO selectDeptDetail(DeptVO deptVO) throws Exception {
        return deptMapper.selectDeptDetail(deptVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateDept(DeptVO deptVO) throws Exception {
        DeptVO saved = deptMapper.selectDeptDetail(deptVO);
        if (saved == null) {
            throw new IllegalArgumentException("조직 정보를 찾을 수 없습니다.");
        }
        if (!saved.getDeptSeCd().equals(deptVO.getDeptSeCd())) {
            throw new IllegalArgumentException("등록된 조직 구분은 변경할 수 없습니다.");
        }
        normalizeAndValidate(deptVO, false);
        deptMapper.updateDept(deptVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDept(DeptVO deptVO) throws Exception {
        DeptVO saved = deptMapper.selectDeptDetail(deptVO);
        if (saved == null) {
            throw new IllegalArgumentException("조직 정보를 찾을 수 없습니다.");
        }
        int childCnt = deptMapper.selectDeptChildCount(deptVO);
        if (childCnt > 0) {
            throw new IllegalArgumentException("하위 조직 " + childCnt + "개가 있어 삭제할 수 없습니다.");
        }
        int memberCnt = deptMapper.selectDeptMemberCount(deptVO);
        if (memberCnt > 0) {
            throw new IllegalArgumentException("소속 사용자 " + memberCnt + "명이 있어 삭제할 수 없습니다. 먼저 다른 조직으로 이동해 주세요.");
        }
        deptMapper.deleteDept(deptVO);
    }

    @Override
    public Map<String, Object> selectOrganizationSummary(DeptVO deptVO) throws Exception {
        return deptMapper.selectOrganizationSummary(deptVO);
    }

    @Override
    public List<DeptVO> selectOrganizationList(DeptVO deptVO) throws Exception {
        return deptMapper.selectOrganizationList(deptVO);
    }

    @Override
    public List<UserVO> selectOrganizationMemberList(DeptVO deptVO) throws Exception {
        return deptMapper.selectOrganizationMemberList(deptVO);
    }

    private void normalizeAndValidate(DeptVO deptVO, boolean insert) throws Exception {
        deptVO.setDeptId(trimUpper(deptVO.getDeptId()));
        deptVO.setDeptNm(trim(deptVO.getDeptNm()));
        deptVO.setDeptSeCd(trimUpper(deptVO.getDeptSeCd()));
        deptVO.setUpDeptId(trim(deptVO.getUpDeptId()));
        deptVO.setMngrUserId(trim(deptVO.getMngrUserId()));
        deptVO.setDeptExpln(trim(deptVO.getDeptExpln()));

        if (insert && (deptVO.getDeptId() == null || !deptVO.getDeptId().matches("[A-Z0-9-]{2,20}"))) {
            throw new IllegalArgumentException("조직 코드는 영문 대문자, 숫자, 하이픈 2~20자로 입력해 주세요.");
        }
        if (deptVO.getDeptNm() == null || deptVO.getDeptNm().length() > 100) {
            throw new IllegalArgumentException("조직명을 1~100자로 입력해 주세요.");
        }
        if (deptVO.getDeptExpln() != null && deptVO.getDeptExpln().length() > 500) {
            throw new IllegalArgumentException("조직 설명은 500자 이하로 입력해 주세요.");
        }
        if (!("HQ".equals(deptVO.getDeptSeCd()) || "DEPT".equals(deptVO.getDeptSeCd())
                || "TEAM".equals(deptVO.getDeptSeCd()))) {
            throw new IllegalArgumentException("올바른 조직 구분을 선택해 주세요.");
        }
        if (deptVO.getSortDeptSeq() < 0) {
            deptVO.setSortDeptSeq(0);
        }
        validateParent(deptVO);
        if (deptVO.getMngrUserId() != null && deptMapper.selectManagerCount(deptVO) == 0) {
            throw new IllegalArgumentException("같은 회사의 사용자를 조직장으로 선택해 주세요.");
        }
    }

    private void validateParent(DeptVO deptVO) throws Exception {
        String type = deptVO.getDeptSeCd();
        String parentId = deptVO.getUpDeptId();
        if ("HQ".equals(type)) {
            if (parentId != null) {
                throw new IllegalArgumentException("본부의 상위 조직은 회사만 선택할 수 있습니다.");
            }
            return;
        }
        if ("DEPT".equals(type) && parentId == null) {
            return;
        }
        if (parentId == null) {
            throw new IllegalArgumentException("팀은 상위 부서를 선택해야 합니다.");
        }
        if (parentId.equals(deptVO.getDeptId())) {
            throw new IllegalArgumentException("자기 자신을 상위 조직으로 선택할 수 없습니다.");
        }
        DeptVO parent = new DeptVO();
        parent.setCoId(deptVO.getCoId());
        parent.setDeptId(parentId);
        parent = deptMapper.selectDeptDetail(parent);
        if (parent == null) {
            throw new IllegalArgumentException("상위 조직 정보를 찾을 수 없습니다.");
        }
        if ("DEPT".equals(type) && !"HQ".equals(parent.getDeptSeCd())) {
            throw new IllegalArgumentException("부서의 상위 조직은 회사 또는 본부만 선택할 수 있습니다.");
        }
        if ("TEAM".equals(type) && !"DEPT".equals(parent.getDeptSeCd())) {
            throw new IllegalArgumentException("팀의 상위 조직은 부서만 선택할 수 있습니다.");
        }
    }

    private static String trim(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private static String trimUpper(String value) {
        String trimmed = trim(value);
        return trimmed == null ? null : trimmed.toUpperCase(java.util.Locale.ROOT);
    }
}
