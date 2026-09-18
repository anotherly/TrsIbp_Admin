package kr.co.TRSolution.trsIbp.comm.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import kr.co.TRSolution.trsIbp.comm.mapper.CommCdMapper;
import kr.co.TRSolution.trsIbp.comm.service.CommCdService;
import kr.co.TRSolution.trsIbp.comm.vo.CommCdVO;

/**
 * 공통코드 서비스 구현체
 * - MyBatis Mapper를 통해 공통코드 데이터를 조회한다.
 */
@Service("commCdService")
public class CommCdServiceImpl implements CommCdService {

    @Resource(name = "commCdMapper")
    private CommCdMapper commCdMapper;

    @Override
    public List<CommCdVO> selectCommCdList(CommCdVO commCdVO) {
        return commCdMapper.selectCommCdList(commCdVO);
    }

    @Override
    public String selectDefaultCd(String cdGroupId) {
        CommCdVO commCdVO = new CommCdVO();
        commCdVO.setCdGroupId(cdGroupId);
        return commCdMapper.selectDefaultCd(commCdVO);
    }
}
