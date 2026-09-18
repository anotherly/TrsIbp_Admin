package kr.co.TRSolution.trsIbp.dept.vo;

import kr.co.TRSolution.trsIbp.company.vo.CompanyVO;

/**
 * 부서 정보 VO (CompanyVO를 상속받아 회사 및 BaseVO 속성을 가짐)
 */
public class DeptVO extends CompanyVO {

    private static final long serialVersionUID = 1L;

    // ===================================================
    // [trsIbp.sql] DEPT_INFO 테이블 물리 컬럼 매핑
    // ===================================================
    private String deptId;          // 부서 ID (PK)
    private String deptNm;          // 조직명
    private String upDeptId;        // 상위 조직 ID (Self-Join용)
    private int sortDeptSeq;        // 정렬 순서
    private String deptSeCd;        // 조직 구분(HQ: 본부, DEPT: 부서, TEAM: 팀)
    private String deptExpln;       // 조직 설명
    private String mngrUserId;      // 조직장 사용자 ID
    
    // [화면 확장 필드] 조인을 통해 받아올 상위 부서명
    private String upDeptNm;
    private String mngrUserNm;
    private String mngrJbpsNm;
    private int memberCnt;
    private int childCnt;

    // ===================================================
    // Getter & Setter
    // ===================================================
    public String getDeptId() { return deptId; }
    public void setDeptId(String deptId) { this.deptId = deptId; }

    public String getDeptNm() { return deptNm; }
    public void setDeptNm(String deptNm) { this.deptNm = deptNm; }

    public String getUpDeptId() { return upDeptId; }
    public void setUpDeptId(String upDeptId) { this.upDeptId = upDeptId; }

    public int getSortDeptSeq() { return sortDeptSeq; }
    public void setSortDeptSeq(int sortDeptSeq) { this.sortDeptSeq = sortDeptSeq; }

    public String getUpDeptNm() { return upDeptNm; }
    public void setUpDeptNm(String upDeptNm) { this.upDeptNm = upDeptNm; }

    public String getDeptSeCd() { return deptSeCd; }
    public void setDeptSeCd(String deptSeCd) { this.deptSeCd = deptSeCd; }

    public String getDeptExpln() { return deptExpln; }
    public void setDeptExpln(String deptExpln) { this.deptExpln = deptExpln; }

    public String getMngrUserId() { return mngrUserId; }
    public void setMngrUserId(String mngrUserId) { this.mngrUserId = mngrUserId; }

    public String getMngrUserNm() { return mngrUserNm; }
    public void setMngrUserNm(String mngrUserNm) { this.mngrUserNm = mngrUserNm; }

    public String getMngrJbpsNm() { return mngrJbpsNm; }
    public void setMngrJbpsNm(String mngrJbpsNm) { this.mngrJbpsNm = mngrJbpsNm; }

    public int getMemberCnt() { return memberCnt; }
    public void setMemberCnt(int memberCnt) { this.memberCnt = memberCnt; }

    public int getChildCnt() { return childCnt; }
    public void setChildCnt(int childCnt) { this.childCnt = childCnt; }

    @Override
    public String toString() {
        return "DeptVO [deptId=" + deptId + ", deptNm=" + deptNm + ", deptSeCd=" + deptSeCd
                + ", upDeptId=" + upDeptId + ", coId=" + getCoId() + "]";
    }
}
