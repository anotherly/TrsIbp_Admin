package kr.co.TRSolution.trsIbp.comm.file.vo;

import java.io.Serializable;

/**
 * 여러 업무 화면에서 공통으로 사용하는 첨부파일 메타데이터 VO.
 */
public class CommonFileVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long atchFileSn;
    private String coId;
    private String refSeCd;
    private String refId;
    private String fileSeCd;
    private String orgnlFileNm;
    private String encptFileNm;
    private String filePathNm;
    private Long fileSz;
    private String fileExtnNm;
    private Integer sortSeq;
    private String useYn;
    private String rgtrId;
    private String regDt;

    public Long getAtchFileSn() { return atchFileSn; }
    public void setAtchFileSn(Long atchFileSn) { this.atchFileSn = atchFileSn; }
    public String getCoId() { return coId; }
    public void setCoId(String coId) { this.coId = coId; }
    public String getRefSeCd() { return refSeCd; }
    public void setRefSeCd(String refSeCd) { this.refSeCd = refSeCd; }
    public String getRefId() { return refId; }
    public void setRefId(String refId) { this.refId = refId; }
    public String getFileSeCd() { return fileSeCd; }
    public void setFileSeCd(String fileSeCd) { this.fileSeCd = fileSeCd; }
    public String getOrgnlFileNm() { return orgnlFileNm; }
    public void setOrgnlFileNm(String orgnlFileNm) { this.orgnlFileNm = orgnlFileNm; }
    public String getEncptFileNm() { return encptFileNm; }
    public void setEncptFileNm(String encptFileNm) { this.encptFileNm = encptFileNm; }
    public String getFilePathNm() { return filePathNm; }
    public void setFilePathNm(String filePathNm) { this.filePathNm = filePathNm; }
    public Long getFileSz() { return fileSz; }
    public void setFileSz(Long fileSz) { this.fileSz = fileSz; }
    public String getFileExtnNm() { return fileExtnNm; }
    public void setFileExtnNm(String fileExtnNm) { this.fileExtnNm = fileExtnNm; }
    public Integer getSortSeq() { return sortSeq; }
    public void setSortSeq(Integer sortSeq) { this.sortSeq = sortSeq; }
    public String getUseYn() { return useYn; }
    public void setUseYn(String useYn) { this.useYn = useYn; }
    public String getRgtrId() { return rgtrId; }
    public void setRgtrId(String rgtrId) { this.rgtrId = rgtrId; }
    public String getRegDt() { return regDt; }
    public void setRegDt(String regDt) { this.regDt = regDt; }
}
