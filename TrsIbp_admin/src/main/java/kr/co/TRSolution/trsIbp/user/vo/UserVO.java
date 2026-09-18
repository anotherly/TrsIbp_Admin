package kr.co.TRSolution.trsIbp.user.vo;

import kr.co.TRSolution.trsIbp.dept.vo.DeptVO;

/**
 * 사용자 VO (Value Object)
 * 테이블: USER_INFO, AUTHRT_INFO, CO_INFO, DEPT_INFO JOIN
 *
 * @author DevSync
 * @since 2026-05-28
 */
public class UserVO extends DeptVO {

	private static final long serialVersionUID = 1L;
	
    // ============================================================
    // USER_INFO 컬럼
    // ============================================================

    /** 사용자ID (PK) */
    private String userId;

    /** 비밀번호 (BCrypt 해시) */
    private String userEnpswd;

    /** 사용자명 */
    private String userNm;

    /** 소속회사ID (CO_INFO.CO_ID FK) */
    private String coId;

    /** 회사코드 (CO_INFO.CO_CD, 사업코드 생성용) */
    private String coCd;

    /** 소속부서ID (DEPT_INFO.DEPT_ID FK) */
    private String deptId;

    /** 직급/직책 (대표/본부장/팀장/팀원 등 자유입력) */
    private String jbpsNm;

    /** 권한ID (AUTHRT_INFO.AUTHRT_ID FK) */
    private String authrtId;

    /** 연락처 */
    private String userTelno;

    /** 사용여부 (Y/N) */
    private String useYn;

    /** 메모 */
    private String memoCn;

    /** 가입일시 */
    private String regDt;

    // ============================================================
    // JOIN 조회용 컬럼
    // ============================================================

    /** 회사명 (CO_INFO.CO_NM) */
    private String coNm;

    /** 부서명 (DEPT_INFO.DEPT_NM) */
    private String deptNm;

    /** 상위부서명 (DEPT_INFO.UP_DEPT_ID JOIN) */
    private String upDeptNm;

    /** 권한명 (AUTHRT_INFO.AUTHRT_NM) */
    private String authrtNm;

    // ============================================================
    // 검색 조건용
    // ============================================================

    /** 검색 타입 (userId / userNm 등) */
    private String searchType;

    /** 검색 값 */
    private String searchValue;

    /** 검색 시작일 */
    private String sDate;

    /** 검색 종료일 */
    private String eDate;

    /** 저장 모드(insert/update) */
    private String saveMode;

    // ============================================================
    // Getter / Setter
    // ============================================================

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserEnpswd() { return userEnpswd; }
    public void setUserEnpswd(String userEnpswd) { this.userEnpswd = userEnpswd; }

    public String getUserNm() { return userNm; }
    public void setUserNm(String userNm) { this.userNm = userNm; }

    public String getCoId() { return coId; }
    public void setCoId(String coId) { this.coId = coId; }

    public String getCoCd() { return coCd; }
    public void setCoCd(String coCd) { this.coCd = coCd; }

    public String getDeptId() { return deptId; }
    public void setDeptId(String deptId) { this.deptId = deptId; }

    public String getJbpsNm() { return jbpsNm; }
    public void setJbpsNm(String jbpsNm) { this.jbpsNm = jbpsNm; }

    public String getAuthrtId() { return authrtId; }
    public void setAuthrtId(String authrtId) { this.authrtId = authrtId; }

    public String getUserTelno() { return userTelno; }
    public void setUserTelno(String userTelno) { this.userTelno = userTelno; }

    public String getUseYn() { return useYn; }
    public void setUseYn(String useYn) { this.useYn = useYn; }

    public String getMemoCn() { return memoCn; }
    public void setMemoCn(String memoCn) { this.memoCn = memoCn; }

    public String getRegDt() { return regDt; }
    public void setRegDt(String regDt) { this.regDt = regDt; }

    public String getCoNm() { return coNm; }
    public void setCoNm(String coNm) { this.coNm = coNm; }

    public String getDeptNm() { return deptNm; }
    public void setDeptNm(String deptNm) { this.deptNm = deptNm; }

    public String getUpDeptNm() { return upDeptNm; }
    public void setUpDeptNm(String upDeptNm) { this.upDeptNm = upDeptNm; }

    public String getAuthrtNm() { return authrtNm; }
    public void setAuthrtNm(String authrtNm) { this.authrtNm = authrtNm; }

    public String getSearchType() { return searchType; }
    public void setSearchType(String searchType) { this.searchType = searchType; }

    public String getSearchValue() { return searchValue; }
    public void setSearchValue(String searchValue) { this.searchValue = searchValue; }

    public String getsDate() { return sDate; }
    public void setsDate(String sDate) { this.sDate = sDate; }

    public String geteDate() { return eDate; }
    public void seteDate(String eDate) { this.eDate = eDate; }

    public String getSaveMode() { return saveMode; }
    public void setSaveMode(String saveMode) { this.saveMode = saveMode; }

    @Override
    public String toString() {
        return "UserVO [userId=" + userId + ", userNm=" + userNm
                + ", coId=" + coId + ", coCd=" + coCd + ", deptId=" + deptId
                + ", jbpsNm=" + jbpsNm + ", authrtId=" + authrtId
                + ", useYn=" + useYn + "]";
    }
}
