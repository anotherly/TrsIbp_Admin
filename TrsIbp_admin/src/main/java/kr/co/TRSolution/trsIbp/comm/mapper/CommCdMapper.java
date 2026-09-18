package kr.co.TRSolution.trsIbp.comm.mapper;

import java.util.List;

import egovframework.rte.psl.dataaccess.mapper.Mapper;
import kr.co.TRSolution.trsIbp.comm.vo.CommCdVO;

/**
 * 공통코드 Mapper
 * - 코드 그룹별 코드 목록과 기본 코드를 조회한다.
 */
@Mapper("commCdMapper")
public interface CommCdMapper {

    /**
     * 코드 그룹 목록 기준으로 사용 중인 공통코드를 조회한다.
     * @param commCdVO cdGroupIdList 또는 cdGroupId 조건
     * @return 공통코드 목록
     */
    List<CommCdVO> selectCommCdList(CommCdVO commCdVO);

    /**
     * 지정한 코드 그룹의 기본 코드를 조회한다.
     * @param commCdVO cdGroupId 조건
     * @return 기본 코드
     */
    String selectDefaultCd(CommCdVO commCdVO);
}
