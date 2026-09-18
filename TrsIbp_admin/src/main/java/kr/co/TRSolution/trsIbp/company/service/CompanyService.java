package kr.co.TRSolution.trsIbp.company.service;

import java.util.List;
import kr.co.TRSolution.trsIbp.company.vo.CompanyVO;

/**
 * 회사 관리 비즈니스 로직 서비스 인터페이스 (기존 소스 확장본)
 */
public interface CompanyService {

    // [기존 구현 명세]
    List<CompanyVO> selectCompanyList(CompanyVO companyVO) throws Exception;
    String insertCompany(CompanyVO companyVO) throws Exception;
    CompanyVO selectCompany(CompanyVO companyVO) throws Exception;

    // ====================================================================
    // [신규 추가 명세] 
    // ====================================================================
    // 1. 외부 도입 문의/신청 접수 (서류 파일 암호화 디스크 저장 포획 포함)
    void insertCompanyRequest(CompanyVO vo) throws Exception;

    // 2. 시스템 관리자 판단에 따른 반려 마감 처리
    void rejectCompanyRequest(int aplySn, String rjctRsn) throws Exception;

    // 3. [핵심] 최고 관리자 승인 - 3개 테이블 마스터 일괄 연쇄 이관 트랜잭션 보장
    String approveCompanyRequest(int aplySn) throws Exception;
}