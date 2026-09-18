package kr.co.TRSolution.trsIbp.company.vo;

import java.io.Serializable;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.annotation.JsonIgnore;

import kr.co.TRSolution.trsIbp.comm.BaseVO;

public class CompanyVO extends BaseVO implements Serializable {

    private static final long serialVersionUID = 1L;

    // ===================================================
    // [기존] CO_INFO & CO_IP_INFO 테이블 컬럼
    // ===================================================
    private String coId;         // 회사 ID (PK)
    private String coNm;       // 회사명
    private String coTelno;        // 대표전화
    private String coAddr;       // 주소
    private String useYn;           // 사용여부(Y/N)
    private String regDt;             // 등록일시
    
    private String prmIpAddr;         // 허용 공인 IP 주소
    private String ipExpln;            // IP 설명
    private String searchKeyword;     // 검색 키워드

    // ===================================================
    // [추가] CO_APLY_INFO (도입 신청) 테이블 매핑 컬럼
    // ===================================================
    private int aplySn;               // 신청 일련번호 (PK, AUTO_INCREMENT)
    private String coNmReq;    // 신청 회사명 (co_aply_info 전용 필드 분리 원칙)
    private String brno;             // ★ 누락 복구: 사업자등록번호 (NOT NULL 제약조건 대응)
    private String aplcntNm;       // 담당자 이름
    private String rprsvNm;// 대표자명/신청자명
    private String picTelno;        // 담당자 연락처
    private String picEmlAddr;      // 담당자 이메일
    private String prcsSttsCd;         // 신청 상태 (WAIT:대기, APPR:승인, REJECT:반려)
    private String rjctRsn;      // 반려 사유

    // ===================================================
    // [추가] 파일 업로드 및 가공 수신용 (사업자등록증 등 증빙서류)
    // ===================================================
    @JsonIgnore // ★ 이 어노테이션을 붙여야 Jackson이 Ajax 응답(JSON 변환) 시 이 필드를 무시합니다!
    private MultipartFile bizFile; // 프론트 <input type="file" name="bizFile"> 수신용
    private String orgnlFileNm;       // 원본 파일명
    private String encptFileNm;       // 암호화 가공 파일명
    private String filePathNm;          // 디스크 보관 경로
    private int dataSn;               // 자식 테이블 연결용 자동생성 SEQ 저장 공간

    // ===================================================
    // Getter & Setter (모든 필드 완비 명세)
    // ===================================================
    public String getCoId() { return coId; }
    public void setCoId(String coId) { this.coId = coId; }
    public String getCoNm() { return coNm; }
    public void setCoNm(String coNm) { this.coNm = coNm; }
    public String getCoTelno() { return coTelno; }
    public void setCoTelno(String coTelno) { this.coTelno = coTelno; }
    public String getCoAddr() { return coAddr; }
    public void setCoAddr(String coAddr) { this.coAddr = coAddr; }
    public String getUseYn() { return useYn; }
    public void setUseYn(String useYn) { this.useYn = useYn; }
    public String getRegDt() { return regDt; }
    public void setRegDt(String regDt) { this.regDt = regDt; }
    public String getPrmIpAddr() { return prmIpAddr; }
    public void setPrmIpAddr(String prmIpAddr) { this.prmIpAddr = prmIpAddr; }
    public String getIpExpln() { return ipExpln; }
    public void setIpExpln(String ipExpln) { this.ipExpln = ipExpln; }
    public String getSearchKeyword() { return searchKeyword; }
    public void setSearchKeyword(String searchKeyword) { this.searchKeyword = searchKeyword; }

    public int getAplySn() { return aplySn; }
    public void setAplySn(int aplySn) { this.aplySn = aplySn; }
    public String getCoNmReq() { return coNmReq; }
    public void setCoNmReq(String coNmReq) { this.coNmReq = coNmReq; }
    public String getBrno() { return brno; }
    public void setBrno(String brno) { this.brno = brno; }
    public String getAplcntNm() { return aplcntNm; }
    public void setAplcntNm(String aplcntNm) { this.aplcntNm = aplcntNm; }
    public String getRprsvNm() { return rprsvNm; }
    public void setRprsvNm(String rprsvNm) { this.rprsvNm = rprsvNm; }
    public String getPicTelno() { return picTelno; }
    public void setPicTelno(String picTelno) { this.picTelno = picTelno; }
    public String getPicEmlAddr() { return picEmlAddr; }
    public void setPicEmlAddr(String picEmlAddr) { this.picEmlAddr = picEmlAddr; }
    public String getPrcsSttsCd() { return prcsSttsCd; }
    public void setPrcsSttsCd(String prcsSttsCd) { this.prcsSttsCd = prcsSttsCd; }
    public String getRjctRsn() { return rjctRsn; }
    public void setRjctRsn(String rjctRsn) { this.rjctRsn = rjctRsn; }
    public MultipartFile getBizFile() { return bizFile; }
    public void setBizFile(MultipartFile bizFile) { this.bizFile = bizFile; }
    public String getOrgnlFileNm() { return orgnlFileNm; }
    public void setOrgnlFileNm(String orgnlFileNm) { this.orgnlFileNm = orgnlFileNm; }
    public String getEncptFileNm() { return encptFileNm; }
    public void setEncptFileNm(String encptFileNm) { this.encptFileNm = encptFileNm; }
    public String getFilePathNm() { return filePathNm; }
    public void setFilePathNm(String filePathNm) { this.filePathNm = filePathNm; }
    public int getDataSn() { return dataSn; }
    public void setDataSn(int dataSn) { this.dataSn = dataSn; }
}