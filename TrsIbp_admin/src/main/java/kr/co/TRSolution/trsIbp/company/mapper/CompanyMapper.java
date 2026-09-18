package kr.co.TRSolution.trsIbp.company.mapper;

import java.util.List;
import kr.co.TRSolution.trsIbp.company.vo.CompanyVO;
import egovframework.rte.psl.dataaccess.mapper.Mapper;

@Mapper("companyMapper")
public interface CompanyMapper {
    List<CompanyVO> selectCompanyList(CompanyVO vo) throws Exception;
    void insertCompany(CompanyVO vo) throws Exception;
    void insertCompanyIp(CompanyVO vo) throws Exception;
    CompanyVO selectCompany(CompanyVO vo) throws Exception;
	void insertCompanyRequest(CompanyVO vo);
	CompanyVO selectCompanyRequestDetail(int aplySn);
	void insertApprovedCompany(CompanyVO requestData);
	void insertCompanyDocAuto(CompanyVO requestData);
	void insertCompDocFileAuto(CompanyVO requestData);
	void updateRequestStatus(CompanyVO statusVO);
}