package kr.co.TRSolution.trsIbp.comm.vo;

import java.util.List;

import kr.co.TRSolution.trsIbp.comm.BaseVO;

/**
 * 공통코드 VO
 * - cmn_cd_group, cmn_cd 조회 결과와 검색 조건을 담는다.
 */
public class CommCdVO extends BaseVO {

    private String cdGroupId;
    private String cdGroupNm;
    private String cd;
    private String cdNm;
    private String cdExpln;
    private String dfltYn;
    private String useYn;
    private String rmrkCn;
    private List<String> cdGroupIdList;

    public String getCdGroupId() { return cdGroupId; }
    public void setCdGroupId(String cdGroupId) { this.cdGroupId = cdGroupId; }
    public String getCdGroupNm() { return cdGroupNm; }
    public void setCdGroupNm(String cdGroupNm) { this.cdGroupNm = cdGroupNm; }
    public String getCd() { return cd; }
    public void setCd(String cd) { this.cd = cd; }
    public String getCdNm() { return cdNm; }
    public void setCdNm(String cdNm) { this.cdNm = cdNm; }
    public String getCdExpln() { return cdExpln; }
    public void setCdExpln(String cdExpln) { this.cdExpln = cdExpln; }
    public String getDfltYn() { return dfltYn; }
    public void setDfltYn(String dfltYn) { this.dfltYn = dfltYn; }
    public String getUseYn() { return useYn; }
    public void setUseYn(String useYn) { this.useYn = useYn; }
    public String getRmrkCn() { return rmrkCn; }
    public void setRmrkCn(String rmrkCn) { this.rmrkCn = rmrkCn; }
    public List<String> getCdGroupIdList() { return cdGroupIdList; }
    public void setCdGroupIdList(List<String> cdGroupIdList) { this.cdGroupIdList = cdGroupIdList; }
}
