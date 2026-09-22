package kr.co.TRSolution.trsIbp.admin.vo;

import java.io.Serializable;

import kr.co.TRSolution.trsIbp.comm.BaseVO;

/**
 * 시스템관리자 화면의 검색조건과 처리 파라미터를 전달한다.
 */
public class AdminVO extends BaseVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer aplySn;
    private String coId;
    private String userId;
    private String useYn;
    private String prcsSttsCd;
    private String rjctRsn;
    private String adminId;
    private String actionSeCd;
    private String targetSeCd;
    private String targetId;
    private String actionCn;
    private String logSeCd;
    private String logLevelCd;
    private String logTitle;
    private String logCn;
    private String requestUri;
    private String clientIpAddr;
    private String cdGroupId;
    private String cd;
    private String policyId;
    private String policyValue;
    private Long noticeSn;
    private String noticeTitle;
    private String noticeCn;
    private String popupYn;

    public Integer getAplySn() {
        return aplySn;
    }

    public void setAplySn(Integer aplySn) {
        this.aplySn = aplySn;
    }

    public String getCoId() {
        return coId;
    }

    public void setCoId(String coId) {
        this.coId = coId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUseYn() {
        return useYn;
    }

    public void setUseYn(String useYn) {
        this.useYn = useYn;
    }

    public String getPrcsSttsCd() {
        return prcsSttsCd;
    }

    public void setPrcsSttsCd(String prcsSttsCd) {
        this.prcsSttsCd = prcsSttsCd;
    }

    public String getRjctRsn() {
        return rjctRsn;
    }

    public void setRjctRsn(String rjctRsn) {
        this.rjctRsn = rjctRsn;
    }

    public String getAdminId() {
        return adminId;
    }

    public void setAdminId(String adminId) {
        this.adminId = adminId;
    }

    public String getActionSeCd() {
        return actionSeCd;
    }

    public void setActionSeCd(String actionSeCd) {
        this.actionSeCd = actionSeCd;
    }

    public String getTargetSeCd() {
        return targetSeCd;
    }

    public void setTargetSeCd(String targetSeCd) {
        this.targetSeCd = targetSeCd;
    }

    public String getTargetId() {
        return targetId;
    }

    public void setTargetId(String targetId) {
        this.targetId = targetId;
    }

    public String getActionCn() {
        return actionCn;
    }

    public void setActionCn(String actionCn) {
        this.actionCn = actionCn;
    }

    public String getLogSeCd() {
        return logSeCd;
    }

    public void setLogSeCd(String logSeCd) {
        this.logSeCd = logSeCd;
    }

    public String getLogLevelCd() {
        return logLevelCd;
    }

    public void setLogLevelCd(String logLevelCd) {
        this.logLevelCd = logLevelCd;
    }

    public String getLogTitle() {
        return logTitle;
    }

    public void setLogTitle(String logTitle) {
        this.logTitle = logTitle;
    }

    public String getLogCn() {
        return logCn;
    }

    public void setLogCn(String logCn) {
        this.logCn = logCn;
    }

    public String getRequestUri() {
        return requestUri;
    }

    public void setRequestUri(String requestUri) {
        this.requestUri = requestUri;
    }

    public String getClientIpAddr() {
        return clientIpAddr;
    }

    public void setClientIpAddr(String clientIpAddr) {
        this.clientIpAddr = clientIpAddr;
    }

    public String getCdGroupId() {
        return cdGroupId;
    }

    public void setCdGroupId(String cdGroupId) {
        this.cdGroupId = cdGroupId;
    }

    public String getCd() {
        return cd;
    }

    public void setCd(String cd) {
        this.cd = cd;
    }

    public String getPolicyId() {
        return policyId;
    }

    public void setPolicyId(String policyId) {
        this.policyId = policyId;
    }

    public String getPolicyValue() {
        return policyValue;
    }

    public void setPolicyValue(String policyValue) {
        this.policyValue = policyValue;
    }
    public Long getNoticeSn() { return noticeSn; }
    public void setNoticeSn(Long noticeSn) { this.noticeSn = noticeSn; }
    public String getNoticeTitle() { return noticeTitle; }
    public void setNoticeTitle(String noticeTitle) { this.noticeTitle = noticeTitle; }
    public String getNoticeCn() { return noticeCn; }
    public void setNoticeCn(String noticeCn) { this.noticeCn = noticeCn; }
    public String getPopupYn() { return popupYn; }
    public void setPopupYn(String popupYn) { this.popupYn = popupYn; }

}
