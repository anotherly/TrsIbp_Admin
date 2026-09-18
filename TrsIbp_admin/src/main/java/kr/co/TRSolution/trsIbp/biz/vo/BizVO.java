
package kr.co.TRSolution.trsIbp.biz.vo;

import java.math.BigDecimal;

import kr.co.TRSolution.trsIbp.comm.BaseVO;

/**
 * 사업관리 통합 VO
 * - biz_info
 * - cust_info
 * - biz_cust_rel
 * - biz_mnpw
 * - biz_cst
 * - biz_schdl
 * - 손익요약 조회
 */
public class BizVO extends BaseVO {

    /* 검색/페이징 */
    private String searchBizPrgrsStepCd;
    private String searchBizSttsCd;
    private String searchCustSeCd;
    private String searchInstSeCd;
    private String searchBizKndCd;
    private String searchBizSeCd;
    private String bizCdPrefix;
    private String scopeUserId;

    /* biz_info */
    private String bizId;
    private String coId;
    private String bizCd;
    private String ctrtNo;
    private String bizNm;
    private String bizAbrvNm;
    private String dtlBizNm;
    private String instSeCd;
    private String bizKndCd;
    private String bizSeCd;
    private String ordplNm;
    private String ctrtYmd;
    private String otstYmd;
    private String bizBgngYmd;
    private String bizEndYmd;
    private BigDecimal ctrtAmt;
    private String giveMthdCd;
    private String giveMthdCn;
    private String giveDdtYmd;
    private String dfrpGrnteBgngYmd;
    private String dfrpGrnteEndYmd;
    private String vatInclYn;
    private String giveMthdListJson;
    private String bizPrgrsStepCd;
    private String bizSttsCd;
    private String rmrkCn;
    private String useYn;
    private String rgtrId;
    private String mdfrId;
    private String mdfcnDt;

    /* cust_info */
    private Long custSn;
    private String custCoNm;
    private String custSeCd;
    private String brno;
    private String rprsvNm;
    private String telno;
    private String addr;
    private String daddr;

    /* biz_cust_rel */
    private Long bizCustRelSn;
    private String relSeCd;
    private Integer relLvl;
    private String directCtrtYn;

    /* biz_give_mthd */
    private Long bizGiveMthdSn;
    private Integer sortSeq;

    /* biz_mnpw */
    private Long bizMnpwSn;
    private String userId;
    private String inputMnpwNm;
    private String inputSeCd;
    private String roleNm;
    private String jbpsNm;
    private String inputBgngYmd;
    private String inputEndYmd;
    private BigDecimal inputMcnt;
    private BigDecimal untprc;
    private BigDecimal inputRt;

    /* biz_cst */
    private Long bizCstSn;
    private String cstSeCd;
    private String cstNm;
    private BigDecimal ocrnCst;
    private String ocrnYmd;

    /* biz_schdl */
    private Long bizSchdlSn;
    private String schdlNm;
    private String schdlCn;
    private String schdlSeCd;
    private String schdlBgngYmd;
    private String schdlEndYmd;
    private String picId;

    /* 화면 표시용 */
    private String bizPrgrsStepNm;
    private String bizSttsNm;
    private String instSeNm;
    private String bizKndNm;
    private String bizSeNm;
    private String giveMthdNm;
    private String vatInclNm;
    private String custSeNm;
    private String relSeNm;
    private String inputSeNm;
    private String cstSeNm;
    private String schdlSeNm;
    private String picNm;
    private String userNm;

    /* 손익요약 */
    private BigDecimal directCstSum;
    private BigDecimal laborCstSum;
    private BigDecimal totalCstSum;
    private BigDecimal profitAmt;
    private BigDecimal profitRate;

    public String getSearchBizPrgrsStepCd() { return searchBizPrgrsStepCd; }
    public void setSearchBizPrgrsStepCd(String searchBizPrgrsStepCd) { this.searchBizPrgrsStepCd = searchBizPrgrsStepCd; }
    public String getSearchBizSttsCd() { return searchBizSttsCd; }
    public void setSearchBizSttsCd(String searchBizSttsCd) { this.searchBizSttsCd = searchBizSttsCd; }
    public String getSearchCustSeCd() { return searchCustSeCd; }
    public void setSearchCustSeCd(String searchCustSeCd) { this.searchCustSeCd = searchCustSeCd; }
    public String getSearchInstSeCd() { return searchInstSeCd; }
    public void setSearchInstSeCd(String searchInstSeCd) { this.searchInstSeCd = searchInstSeCd; }
    public String getSearchBizKndCd() { return searchBizKndCd; }
    public void setSearchBizKndCd(String searchBizKndCd) { this.searchBizKndCd = searchBizKndCd; }
    public String getSearchBizSeCd() { return searchBizSeCd; }
    public void setSearchBizSeCd(String searchBizSeCd) { this.searchBizSeCd = searchBizSeCd; }
    public String getBizCdPrefix() { return bizCdPrefix; }
    public void setBizCdPrefix(String bizCdPrefix) { this.bizCdPrefix = bizCdPrefix; }
    public String getScopeUserId() { return scopeUserId; }
    public void setScopeUserId(String scopeUserId) { this.scopeUserId = scopeUserId; }
    public String getBizId() { return bizId; }
    public void setBizId(String bizId) { this.bizId = bizId; }
    public String getCoId() { return coId; }
    public void setCoId(String coId) { this.coId = coId; }
    public String getBizCd() { return bizCd; }
    public void setBizCd(String bizCd) { this.bizCd = bizCd; }
    public String getCtrtNo() { return ctrtNo; }
    public void setCtrtNo(String ctrtNo) { this.ctrtNo = ctrtNo; }
    public String getBizNm() { return bizNm; }
    public void setBizNm(String bizNm) { this.bizNm = bizNm; }
    public String getBizAbrvNm() { return bizAbrvNm; }
    public void setBizAbrvNm(String bizAbrvNm) { this.bizAbrvNm = bizAbrvNm; }
    public String getDtlBizNm() { return dtlBizNm; }
    public void setDtlBizNm(String dtlBizNm) { this.dtlBizNm = dtlBizNm; }
    public String getInstSeCd() { return instSeCd; }
    public void setInstSeCd(String instSeCd) { this.instSeCd = instSeCd; }
    public String getBizKndCd() { return bizKndCd; }
    public void setBizKndCd(String bizKndCd) { this.bizKndCd = bizKndCd; }
    public String getBizSeCd() { return bizSeCd; }
    public void setBizSeCd(String bizSeCd) { this.bizSeCd = bizSeCd; }
    public String getOrdplNm() { return ordplNm; }
    public void setOrdplNm(String ordplNm) { this.ordplNm = ordplNm; }
    public String getCtrtYmd() { return ctrtYmd; }
    public void setCtrtYmd(String ctrtYmd) { this.ctrtYmd = ctrtYmd; }
    public String getOtstYmd() { return otstYmd; }
    public void setOtstYmd(String otstYmd) { this.otstYmd = otstYmd; }
    public String getBizBgngYmd() { return bizBgngYmd; }
    public void setBizBgngYmd(String bizBgngYmd) { this.bizBgngYmd = bizBgngYmd; }
    public String getBizEndYmd() { return bizEndYmd; }
    public void setBizEndYmd(String bizEndYmd) { this.bizEndYmd = bizEndYmd; }
    public BigDecimal getCtrtAmt() { return ctrtAmt; }
    public void setCtrtAmt(BigDecimal ctrtAmt) { this.ctrtAmt = ctrtAmt; }
    public String getGiveMthdCd() { return giveMthdCd; }
    public void setGiveMthdCd(String giveMthdCd) { this.giveMthdCd = giveMthdCd; }
    public String getGiveMthdCn() { return giveMthdCn; }
    public void setGiveMthdCn(String giveMthdCn) { this.giveMthdCn = giveMthdCn; }
    public String getGiveDdtYmd() { return giveDdtYmd; }
    public void setGiveDdtYmd(String giveDdtYmd) { this.giveDdtYmd = giveDdtYmd; }
    public String getDfrpGrnteBgngYmd() { return dfrpGrnteBgngYmd; }
    public void setDfrpGrnteBgngYmd(String dfrpGrnteBgngYmd) { this.dfrpGrnteBgngYmd = dfrpGrnteBgngYmd; }
    public String getDfrpGrnteEndYmd() { return dfrpGrnteEndYmd; }
    public void setDfrpGrnteEndYmd(String dfrpGrnteEndYmd) { this.dfrpGrnteEndYmd = dfrpGrnteEndYmd; }
    public String getVatInclYn() { return vatInclYn; }
    public void setVatInclYn(String vatInclYn) { this.vatInclYn = vatInclYn; }
    public String getGiveMthdListJson() { return giveMthdListJson; }
    public void setGiveMthdListJson(String giveMthdListJson) { this.giveMthdListJson = giveMthdListJson; }
    public String getBizPrgrsStepCd() { return bizPrgrsStepCd; }
    public void setBizPrgrsStepCd(String bizPrgrsStepCd) { this.bizPrgrsStepCd = bizPrgrsStepCd; }
    public String getBizSttsCd() { return bizSttsCd; }
    public void setBizSttsCd(String bizSttsCd) { this.bizSttsCd = bizSttsCd; }
    public String getRmrkCn() { return rmrkCn; }
    public void setRmrkCn(String rmrkCn) { this.rmrkCn = rmrkCn; }
    public String getUseYn() { return useYn; }
    public void setUseYn(String useYn) { this.useYn = useYn; }
    public String getRgtrId() { return rgtrId; }
    public void setRgtrId(String rgtrId) { this.rgtrId = rgtrId; }
    public String getMdfrId() { return mdfrId; }
    public void setMdfrId(String mdfrId) { this.mdfrId = mdfrId; }
    public String getMdfcnDt() { return mdfcnDt; }
    public void setMdfcnDt(String mdfcnDt) { this.mdfcnDt = mdfcnDt; }

    public Long getCustSn() { return custSn; }
    public void setCustSn(Long custSn) { this.custSn = custSn; }
    public String getCustCoNm() { return custCoNm; }
    public void setCustCoNm(String custCoNm) { this.custCoNm = custCoNm; }
    public String getCustSeCd() { return custSeCd; }
    public void setCustSeCd(String custSeCd) { this.custSeCd = custSeCd; }
    public String getBrno() { return brno; }
    public void setBrno(String brno) { this.brno = brno; }
    public String getRprsvNm() { return rprsvNm; }
    public void setRprsvNm(String rprsvNm) { this.rprsvNm = rprsvNm; }
    public String getTelno() { return telno; }
    public void setTelno(String telno) { this.telno = telno; }
    public String getAddr() { return addr; }
    public void setAddr(String addr) { this.addr = addr; }
    public String getDaddr() { return daddr; }
    public void setDaddr(String daddr) { this.daddr = daddr; }

    public Long getBizCustRelSn() { return bizCustRelSn; }
    public void setBizCustRelSn(Long bizCustRelSn) { this.bizCustRelSn = bizCustRelSn; }
    public String getRelSeCd() { return relSeCd; }
    public void setRelSeCd(String relSeCd) { this.relSeCd = relSeCd; }
    public Integer getRelLvl() { return relLvl; }
    public void setRelLvl(Integer relLvl) { this.relLvl = relLvl; }
    public String getDirectCtrtYn() { return directCtrtYn; }
    public void setDirectCtrtYn(String directCtrtYn) { this.directCtrtYn = directCtrtYn; }

    public Long getBizGiveMthdSn() { return bizGiveMthdSn; }
    public void setBizGiveMthdSn(Long bizGiveMthdSn) { this.bizGiveMthdSn = bizGiveMthdSn; }
    public Integer getSortSeq() { return sortSeq; }
    public void setSortSeq(Integer sortSeq) { this.sortSeq = sortSeq; }

    public Long getBizMnpwSn() { return bizMnpwSn; }
    public void setBizMnpwSn(Long bizMnpwSn) { this.bizMnpwSn = bizMnpwSn; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getInputMnpwNm() { return inputMnpwNm; }
    public void setInputMnpwNm(String inputMnpwNm) { this.inputMnpwNm = inputMnpwNm; }
    public String getInputSeCd() { return inputSeCd; }
    public void setInputSeCd(String inputSeCd) { this.inputSeCd = inputSeCd; }
    public String getRoleNm() { return roleNm; }
    public void setRoleNm(String roleNm) { this.roleNm = roleNm; }
    public String getJbpsNm() { return jbpsNm; }
    public void setJbpsNm(String jbpsNm) { this.jbpsNm = jbpsNm; }
    public String getInputBgngYmd() { return inputBgngYmd; }
    public void setInputBgngYmd(String inputBgngYmd) { this.inputBgngYmd = inputBgngYmd; }
    public String getInputEndYmd() { return inputEndYmd; }
    public void setInputEndYmd(String inputEndYmd) { this.inputEndYmd = inputEndYmd; }
    public BigDecimal getInputMcnt() { return inputMcnt; }
    public void setInputMcnt(BigDecimal inputMcnt) { this.inputMcnt = inputMcnt; }
    public BigDecimal getUntprc() { return untprc; }
    public void setUntprc(BigDecimal untprc) { this.untprc = untprc; }
    public BigDecimal getInputRt() { return inputRt; }
    public void setInputRt(BigDecimal inputRt) { this.inputRt = inputRt; }

    public Long getBizCstSn() { return bizCstSn; }
    public void setBizCstSn(Long bizCstSn) { this.bizCstSn = bizCstSn; }
    public String getCstSeCd() { return cstSeCd; }
    public void setCstSeCd(String cstSeCd) { this.cstSeCd = cstSeCd; }
    public String getCstNm() { return cstNm; }
    public void setCstNm(String cstNm) { this.cstNm = cstNm; }
    public BigDecimal getOcrnCst() { return ocrnCst; }
    public void setOcrnCst(BigDecimal ocrnCst) { this.ocrnCst = ocrnCst; }
    public String getOcrnYmd() { return ocrnYmd; }
    public void setOcrnYmd(String ocrnYmd) { this.ocrnYmd = ocrnYmd; }

    public Long getBizSchdlSn() { return bizSchdlSn; }
    public void setBizSchdlSn(Long bizSchdlSn) { this.bizSchdlSn = bizSchdlSn; }
    public String getSchdlNm() { return schdlNm; }
    public void setSchdlNm(String schdlNm) { this.schdlNm = schdlNm; }
    public String getSchdlCn() { return schdlCn; }
    public void setSchdlCn(String schdlCn) { this.schdlCn = schdlCn; }
    public String getSchdlSeCd() { return schdlSeCd; }
    public void setSchdlSeCd(String schdlSeCd) { this.schdlSeCd = schdlSeCd; }
    public String getSchdlBgngYmd() { return schdlBgngYmd; }
    public void setSchdlBgngYmd(String schdlBgngYmd) { this.schdlBgngYmd = schdlBgngYmd; }
    public String getSchdlEndYmd() { return schdlEndYmd; }
    public void setSchdlEndYmd(String schdlEndYmd) { this.schdlEndYmd = schdlEndYmd; }
    public String getPicId() { return picId; }
    public void setPicId(String picId) { this.picId = picId; }

    public String getBizPrgrsStepNm() { return bizPrgrsStepNm; }
    public void setBizPrgrsStepNm(String bizPrgrsStepNm) { this.bizPrgrsStepNm = bizPrgrsStepNm; }
    public String getBizSttsNm() { return bizSttsNm; }
    public void setBizSttsNm(String bizSttsNm) { this.bizSttsNm = bizSttsNm; }
    public String getInstSeNm() { return instSeNm; }
    public void setInstSeNm(String instSeNm) { this.instSeNm = instSeNm; }
    public String getBizKndNm() { return bizKndNm; }
    public void setBizKndNm(String bizKndNm) { this.bizKndNm = bizKndNm; }
    public String getBizSeNm() { return bizSeNm; }
    public void setBizSeNm(String bizSeNm) { this.bizSeNm = bizSeNm; }
    public String getGiveMthdNm() { return giveMthdNm; }
    public void setGiveMthdNm(String giveMthdNm) { this.giveMthdNm = giveMthdNm; }
    public String getVatInclNm() { return vatInclNm; }
    public void setVatInclNm(String vatInclNm) { this.vatInclNm = vatInclNm; }
    public String getCustSeNm() { return custSeNm; }
    public void setCustSeNm(String custSeNm) { this.custSeNm = custSeNm; }
    public String getRelSeNm() { return relSeNm; }
    public void setRelSeNm(String relSeNm) { this.relSeNm = relSeNm; }
    public String getInputSeNm() { return inputSeNm; }
    public void setInputSeNm(String inputSeNm) { this.inputSeNm = inputSeNm; }
    public String getCstSeNm() { return cstSeNm; }
    public void setCstSeNm(String cstSeNm) { this.cstSeNm = cstSeNm; }
    public String getSchdlSeNm() { return schdlSeNm; }
    public void setSchdlSeNm(String schdlSeNm) { this.schdlSeNm = schdlSeNm; }
    public String getPicNm() { return picNm; }
    public void setPicNm(String picNm) { this.picNm = picNm; }
    public String getUserNm() { return userNm; }
    public void setUserNm(String userNm) { this.userNm = userNm; }

    public BigDecimal getDirectCstSum() { return directCstSum; }
    public void setDirectCstSum(BigDecimal directCstSum) { this.directCstSum = directCstSum; }
    public BigDecimal getLaborCstSum() { return laborCstSum; }
    public void setLaborCstSum(BigDecimal laborCstSum) { this.laborCstSum = laborCstSum; }
    public BigDecimal getTotalCstSum() { return totalCstSum; }
    public void setTotalCstSum(BigDecimal totalCstSum) { this.totalCstSum = totalCstSum; }
    public BigDecimal getProfitAmt() { return profitAmt; }
    public void setProfitAmt(BigDecimal profitAmt) { this.profitAmt = profitAmt; }
    public BigDecimal getProfitRate() { return profitRate; }
    public void setProfitRate(BigDecimal profitRate) { this.profitRate = profitRate; }
}
