package kr.co.TRSolution.trsIbp.company.service.impl;

import java.util.List;
import java.util.UUID;
import javax.annotation.Resource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.co.TRSolution.trsIbp.comm.file.service.CommonFileService;
import kr.co.TRSolution.trsIbp.comm.file.vo.CommonFileVO;
import kr.co.TRSolution.trsIbp.company.mapper.CompanyMapper;
import kr.co.TRSolution.trsIbp.company.service.CompanyService;
import kr.co.TRSolution.trsIbp.company.vo.CompanyVO;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("companyService")
public class CompanyServiceImpl extends EgovAbstractServiceImpl implements CompanyService {

    private static final Logger logger = LoggerFactory.getLogger(CompanyServiceImpl.class);

    // 기존 매퍼 연동 보존
    @Resource(name = "companyMapper")
    private CompanyMapper companyMapper;

    @Resource(name = "commonFileService")
    private CommonFileService commonFileService;

    // ====================================================================
    // [기존 메서드들 - 원본 보존 유지]
    // ====================================================================
    @Override
    public List<CompanyVO> selectCompanyList(CompanyVO companyVO) throws Exception {
        return companyMapper.selectCompanyList(companyVO);
    }

    @Override
    public String insertCompany(CompanyVO companyVO) throws Exception {
        String coId = "COMP_" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        companyVO.setCoId(coId);
        companyMapper.insertCompany(companyVO);
        if(companyVO.getPrmIpAddr() != null && !companyVO.getPrmIpAddr().isEmpty()) {
            companyMapper.insertCompanyIp(companyVO);
        }
        return coId;
    }

    @Override
    public CompanyVO selectCompany(CompanyVO companyVO) throws Exception {
        return companyMapper.selectCompany(companyVO);
    }

    // ====================================================================
    // [신규 추가 메서드들 - 도입신청 / 트랜잭션 승인 이관 로직]
    // ====================================================================
    
    /**
     * 외부 대표자용: 가입 신청서 접수 및 증빙 첨부서류(사업자등록증) UUID 파일명 암호화 디스크 저장
     */
    @Override
    public void insertCompanyRequest(CompanyVO vo) throws Exception {
        // 커맨드 객체로 매핑되어 들어온 멀티파트 파일 획득
        MultipartFile file = vo.getBizFile();
        
        if (file != null && !file.isEmpty()) {
            CommonFileVO storedFile = commonFileService.storeFileOnly(file, "request_biz", "BIZ_LICENSE");
            vo.setOrgnlFileNm(storedFile.getOrgnlFileNm());
            vo.setEncptFileNm(storedFile.getEncptFileNm());
            vo.setFilePathNm(storedFile.getFilePathNm());
            logger.debug("▶ [도입신청 공통 파일저장 완료] 원본명: {}, 저장명: {}",
                    storedFile.getOrgnlFileNm(), storedFile.getEncptFileNm());
        }
        
        // 통합된 기존 companyMapper의 회사 신청 쿼리 구문 호출 실행
        companyMapper.insertCompanyRequest(vo);
    }

    /**
     * 관리자 전용: 사유 기입형 서류 미비 반려 처리 
     */
    @Override
    public void rejectCompanyRequest(int aplySn, String rjctRsn) throws Exception {
        CompanyVO vo = new CompanyVO();
        vo.setAplySn(aplySn);
        vo.setPrcsSttsCd("REJECT");
        vo.setRjctRsn(rjctRsn);
        
        companyMapper.updateRequestStatus(vo);
        logger.debug("▶ [도입신청 반려 가감] 신청번호: {}, 사유: {}", aplySn, rjctRsn);
    }

    /**
     * 관리자 전용: [ 프로세스 핵심 4번] 
     * 최종 승인 시 정식 회사 개설 + 중요서류함 + 서류 파일 정보 일괄 트랜잭션 영속 이관
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public String approveCompanyRequest(int aplySn) throws Exception {
        
        // 1. 임시 테이블(co_aply_info) 신청 기록 단건 획득
        CompanyVO requestData = companyMapper.selectCompanyRequestDetail(aplySn);
        if (requestData == null) {
            throw new IllegalArgumentException("올바르지 않은 도입 신청 내역 일련번호입니다.");
        }
        
        // 2. 회사 정식 영문 규격 코드 채번 가공 주입 (COMP_ + 난수6자)
        String newCoId = "COMP_" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        requestData.setCoId(newCoId);
        
        // 3. [이관 단계 1] co_info 테이블 정식 안착 (HeidiSQL 정본 기준)
        companyMapper.insertApprovedCompany(requestData);
        
        // 4. [이관 단계 2] co_data_mng 테이블 자동 이관 인서트
        // xml 내부 <selectKey> 에 의해 구동 후 requestData 객체의 dataSn 프로퍼티에 자동 바인딩됩니다.
        companyMapper.insertCompanyDocAuto(requestData);
        
        // 5. [이관 단계 3] co_data_file 자식 테이블에 물리 증빙 링크 최종 적재
        if (requestData.getEncptFileNm() != null && !requestData.getEncptFileNm().isEmpty()) {
            companyMapper.insertCompDocFileAuto(requestData);
        }
        
        // 6. 원본 도입 신청서 상태를 최종 승인('APPR') 완료로 갱신
        CompanyVO statusVO = new CompanyVO();
        statusVO.setAplySn(aplySn);
        statusVO.setPrcsSttsCd("APPR");
        companyMapper.updateRequestStatus(statusVO);
        
        logger.debug("▶ [통합 서비스 이관 마감] 정식 개설 회사 ID: {}", newCoId);
        return newCoId;
    }
}
