package kr.co.TRSolution.trsIbp.schedule.vo;

import kr.co.TRSolution.trsIbp.comm.BaseVO;

/**
 * 종합 일정 캘린더 VO
 * - schdl_info, schdl_user_rel 조회/등록/수정/삭제 파라미터와 화면 표시값을 담는다.
 */
public class ScheduleVO extends BaseVO {
    private Long schdlSn;
    private String coId;
    private String bizId;
    private String bizNm;
    private String schdlSeCd;
    private String schdlSeNm;
    private String vacSeCd;
    private String schdlNm;
    private String bgngDt;
    private String endDt;
    private String allDayYn;
    private String placeNm;
    private String schdlCn;
    private String useYn;
    private String rgtrId;
    private String mdfrId;
    private String targetUserId;
    private String targetUserIds;
    private String targetUserNm;
    private String targetUserNms;
    private String selectedYmd;
    private String monthStartYmd;
    private String monthEndYmd;
    private String searchBizId;
    private String searchUnassignedYn;
    private String viewType;
    private String colorType;
    private String conflictConfirmedYn;
    private Integer targetCnt;

    public Long getSchdlSn() { return schdlSn; }
    public void setSchdlSn(Long schdlSn) { this.schdlSn = schdlSn; }
    public String getCoId() { return coId; }
    public void setCoId(String coId) { this.coId = coId; }
    public String getBizId() { return bizId; }
    public void setBizId(String bizId) { this.bizId = bizId; }
    public String getBizNm() { return bizNm; }
    public void setBizNm(String bizNm) { this.bizNm = bizNm; }
    public String getSchdlSeCd() { return schdlSeCd; }
    public void setSchdlSeCd(String schdlSeCd) { this.schdlSeCd = schdlSeCd; }
    public String getSchdlSeNm() { return schdlSeNm; }
    public void setSchdlSeNm(String schdlSeNm) { this.schdlSeNm = schdlSeNm; }
    public String getVacSeCd() { return vacSeCd; }
    public void setVacSeCd(String vacSeCd) { this.vacSeCd = vacSeCd; }
    public String getSchdlNm() { return schdlNm; }
    public void setSchdlNm(String schdlNm) { this.schdlNm = schdlNm; }
    public String getBgngDt() { return bgngDt; }
    public void setBgngDt(String bgngDt) { this.bgngDt = bgngDt; }
    public String getEndDt() { return endDt; }
    public void setEndDt(String endDt) { this.endDt = endDt; }
    public String getAllDayYn() { return allDayYn; }
    public void setAllDayYn(String allDayYn) { this.allDayYn = allDayYn; }
    public String getPlaceNm() { return placeNm; }
    public void setPlaceNm(String placeNm) { this.placeNm = placeNm; }
    public String getSchdlCn() { return schdlCn; }
    public void setSchdlCn(String schdlCn) { this.schdlCn = schdlCn; }
    public String getUseYn() { return useYn; }
    public void setUseYn(String useYn) { this.useYn = useYn; }
    public String getRgtrId() { return rgtrId; }
    public void setRgtrId(String rgtrId) { this.rgtrId = rgtrId; }
    public String getMdfrId() { return mdfrId; }
    public void setMdfrId(String mdfrId) { this.mdfrId = mdfrId; }
    public String getTargetUserId() { return targetUserId; }
    public void setTargetUserId(String targetUserId) { this.targetUserId = targetUserId; }
    public String getTargetUserIds() { return targetUserIds; }
    public void setTargetUserIds(String targetUserIds) { this.targetUserIds = targetUserIds; }
    public String getTargetUserNm() { return targetUserNm; }
    public void setTargetUserNm(String targetUserNm) { this.targetUserNm = targetUserNm; }
    public String getTargetUserNms() { return targetUserNms; }
    public void setTargetUserNms(String targetUserNms) { this.targetUserNms = targetUserNms; }
    public String getSelectedYmd() { return selectedYmd; }
    public void setSelectedYmd(String selectedYmd) { this.selectedYmd = selectedYmd; }
    public String getMonthStartYmd() { return monthStartYmd; }
    public void setMonthStartYmd(String monthStartYmd) { this.monthStartYmd = monthStartYmd; }
    public String getMonthEndYmd() { return monthEndYmd; }
    public void setMonthEndYmd(String monthEndYmd) { this.monthEndYmd = monthEndYmd; }
    public String getSearchBizId() { return searchBizId; }
    public void setSearchBizId(String searchBizId) { this.searchBizId = searchBizId; }
    public String getSearchUnassignedYn() { return searchUnassignedYn; }
    public void setSearchUnassignedYn(String searchUnassignedYn) { this.searchUnassignedYn = searchUnassignedYn; }
    public String getViewType() { return viewType; }
    public void setViewType(String viewType) { this.viewType = viewType; }
    public String getColorType() { return colorType; }
    public void setColorType(String colorType) { this.colorType = colorType; }
    public String getConflictConfirmedYn() { return conflictConfirmedYn; }
    public void setConflictConfirmedYn(String conflictConfirmedYn) { this.conflictConfirmedYn = conflictConfirmedYn; }
    public Integer getTargetCnt() { return targetCnt; }
    public void setTargetCnt(Integer targetCnt) { this.targetCnt = targetCnt; }
}
