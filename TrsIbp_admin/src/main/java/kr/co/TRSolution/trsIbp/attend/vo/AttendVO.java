package kr.co.TRSolution.trsIbp.attend.vo;

import kr.co.TRSolution.trsIbp.comm.BaseVO;

/**
 * 근태 데이터 VO (Value Object)
 *
 * WORK_HSTRY 테이블과 매핑
 *
 * @author DevSync
 * @since 2026-05-28
 */
public class AttendVO extends BaseVO {

    /** 이력번호 (PK, AUTO_INCREMENT) */
    private Long workHstrySn;

    /** 사용자 ID */
    private String userId;

    /** 사용자명 (JOIN 조회용) */
    private String userNm;

    /** 회사ID / 부서ID (대시보드 부서원 조회 조건) */
    private String coId;
    private String deptId;
    private String deptNm;
    private String jbpsNm;

    /** 근무일자 (YYYY-MM-DD) */
    private String workYmd;

    /** 출근시간 (YYYY-MM-DD HH:mm:ss) */
    private String gtwkDt;

    /** 퇴근시간 (YYYY-MM-DD HH:mm:ss) */
    private String lvwkDt;

    /** 근무장소구분코드. 기존 화면 호환을 위해 필드명은 powkNm 유지 */
    private String powkNm;

    /** 비고 */
    private String workRmrkCn;

    /** 등록일시 */
    private String regDt;

    /** 수정일시 */
    private String mdfcnDt;

    /** 근무시간 (분 단위, 조회용 계산값) */
    private String workMinutes;

    /** 오늘 출근 여부 (Y/N, 조회용) */
    private String todayGtwk;

    /** 오늘 퇴근 여부 (Y/N, 조회용) */
    private String todayLvwk;

    /** 일정 또는 근태를 종합한 현재 상태 */
    private String statusCd;
    private String statusNm;
    private String scheduleLinkedYn;
    private String schdlNm;
    private Long profileFileSn;
    private String externalYn;

    // ============================================================
    // Getter / Setter
    // ============================================================

    public Long getWorkHstrySn() { return workHstrySn; }
    public void setWorkHstrySn(Long workHstrySn) { this.workHstrySn = workHstrySn; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserNm() { return userNm; }
    public void setUserNm(String userNm) { this.userNm = userNm; }

    public String getCoId() { return coId; }
    public void setCoId(String coId) { this.coId = coId; }
    public String getDeptId() { return deptId; }
    public void setDeptId(String deptId) { this.deptId = deptId; }
    public String getDeptNm() { return deptNm; }
    public void setDeptNm(String deptNm) { this.deptNm = deptNm; }
    public String getJbpsNm() { return jbpsNm; }
    public void setJbpsNm(String jbpsNm) { this.jbpsNm = jbpsNm; }

    public String getWorkYmd() { return workYmd; }
    public void setWorkYmd(String workYmd) { this.workYmd = workYmd; }

    public String getGtwkDt() { return gtwkDt; }
    public void setGtwkDt(String gtwkDt) { this.gtwkDt = gtwkDt; }

    public String getLvwkDt() { return lvwkDt; }
    public void setLvwkDt(String lvwkDt) { this.lvwkDt = lvwkDt; }

    public String getPowkNm() { return powkNm; }
    public void setPowkNm(String powkNm) { this.powkNm = powkNm; }

    public String getWorkRmrkCn() { return workRmrkCn; }
    public void setWorkRmrkCn(String workRmrkCn) { this.workRmrkCn = workRmrkCn; }

    public String getRegDt() { return regDt; }
    public void setRegDt(String regDt) { this.regDt = regDt; }

    public String getMdfcnDt() { return mdfcnDt; }
    public void setMdfcnDt(String mdfcnDt) { this.mdfcnDt = mdfcnDt; }

    public String getWorkMinutes() { return workMinutes; }
    public void setWorkMinutes(String workMinutes) { this.workMinutes = workMinutes; }

    public String getTodayGtwk() { return todayGtwk; }
    public void setTodayGtwk(String todayGtwk) { this.todayGtwk = todayGtwk; }

    public String getTodayLvwk() { return todayLvwk; }
    public void setTodayLvwk(String todayLvwk) { this.todayLvwk = todayLvwk; }

    public String getStatusCd() { return statusCd; }
    public void setStatusCd(String statusCd) { this.statusCd = statusCd; }
    public String getStatusNm() { return statusNm; }
    public void setStatusNm(String statusNm) { this.statusNm = statusNm; }
    public String getScheduleLinkedYn() { return scheduleLinkedYn; }
    public void setScheduleLinkedYn(String scheduleLinkedYn) { this.scheduleLinkedYn = scheduleLinkedYn; }
    public String getSchdlNm() { return schdlNm; }
    public void setSchdlNm(String schdlNm) { this.schdlNm = schdlNm; }
    public Long getProfileFileSn() { return profileFileSn; }
    public void setProfileFileSn(Long profileFileSn) { this.profileFileSn = profileFileSn; }
    public String getExternalYn() { return externalYn; }
    public void setExternalYn(String externalYn) { this.externalYn = externalYn; }

    @Override
    public String toString() {
        return "AttendVO [workHstrySn=" + workHstrySn + ", userId=" + userId + ", workYmd=" + workYmd
                + ", gtwkDt=" + gtwkDt + ", lvwkDt=" + lvwkDt
                + ", powkNm=" + powkNm + "]";
    }
}
