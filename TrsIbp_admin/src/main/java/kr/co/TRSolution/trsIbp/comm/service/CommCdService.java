package kr.co.TRSolution.trsIbp.comm.service;

import java.util.List;

import kr.co.TRSolution.trsIbp.comm.vo.CommCdVO;

/**
 * 공통코드 서비스
 * - 화면/업무 공통 코드 조회 기능을 제공한다.
 */
public interface CommCdService {

    /**
     * 코드 그룹 목록 기준으로 공통코드를 조회한다.
     * @param commCdVO cdGroupIdList 또는 cdGroupId 조건
     * @return 공통코드 목록
     */
    List<CommCdVO> selectCommCdList(CommCdVO commCdVO);

    /**
     * 코드 그룹의 기본 코드를 조회한다.
     * @param cdGroupId 코드 그룹 ID
     * @return 기본 코드. 미지정 시 null
     */
    String selectDefaultCd(String cdGroupId);
}
