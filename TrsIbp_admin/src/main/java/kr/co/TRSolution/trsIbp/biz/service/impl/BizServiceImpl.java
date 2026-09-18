
package kr.co.TRSolution.trsIbp.biz.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.co.TRSolution.trsIbp.biz.mapper.BizMapper;
import kr.co.TRSolution.trsIbp.biz.service.BizService;
import kr.co.TRSolution.trsIbp.biz.vo.BizVO;

@Service("bizService")
public class BizServiceImpl implements BizService {

    @Resource(name = "bizMapper")
    private BizMapper bizMapper;

    @Override
    public List<BizVO> selectBizList(BizVO vo) throws Exception {
        return bizMapper.selectBizList(vo);
    }

    @Override
    public int selectBizListCnt(BizVO vo) throws Exception {
        return bizMapper.selectBizListCnt(vo);
    }

    @Override
    public BizVO selectBizDetail(BizVO vo) throws Exception {
        return bizMapper.selectBizDetail(vo);
    }

    @Override
    public int selectNextBizCdSeq(BizVO vo) throws Exception {
        return bizMapper.selectNextBizCdSeq(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertBiz(BizVO vo) throws Exception {
        return bizMapper.insertBiz(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateBiz(BizVO vo) throws Exception {
        return bizMapper.updateBiz(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteBiz(BizVO vo) throws Exception {
        return bizMapper.deleteBiz(vo);
    }

    @Override
    public List<BizVO> selectBizGiveMthdList(BizVO vo) throws Exception {
        return bizMapper.selectBizGiveMthdList(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteBizGiveMthdByBizId(BizVO vo) throws Exception {
        return bizMapper.deleteBizGiveMthdByBizId(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertBizGiveMthd(BizVO vo) throws Exception {
        return bizMapper.insertBizGiveMthd(vo);
    }

    @Override
    public List<BizVO> selectCustList(BizVO vo) throws Exception {
        return bizMapper.selectCustList(vo);
    }

    @Override
    public BizVO selectCustDetail(BizVO vo) throws Exception {
        return bizMapper.selectCustDetail(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertCust(BizVO vo) throws Exception {
        return bizMapper.insertCust(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateCust(BizVO vo) throws Exception {
        return bizMapper.updateCust(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteCust(BizVO vo) throws Exception {
        return bizMapper.deleteCust(vo);
    }

    @Override
    public List<BizVO> selectBizCustRelList(BizVO vo) throws Exception {
        return bizMapper.selectBizCustRelList(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertBizCustRel(BizVO vo) throws Exception {
        return bizMapper.insertBizCustRel(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateBizCustRel(BizVO vo) throws Exception {
        return bizMapper.updateBizCustRel(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteBizCustRel(BizVO vo) throws Exception {
        return bizMapper.deleteBizCustRel(vo);
    }

    @Override
    public List<BizVO> selectBizMnpwList(BizVO vo) throws Exception {
        return bizMapper.selectBizMnpwList(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertBizMnpw(BizVO vo) throws Exception {
        return bizMapper.insertBizMnpw(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateBizMnpw(BizVO vo) throws Exception {
        return bizMapper.updateBizMnpw(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteBizMnpw(BizVO vo) throws Exception {
        return bizMapper.deleteBizMnpw(vo);
    }

    @Override
    public List<BizVO> selectBizCstList(BizVO vo) throws Exception {
        return bizMapper.selectBizCstList(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertBizCst(BizVO vo) throws Exception {
        return bizMapper.insertBizCst(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateBizCst(BizVO vo) throws Exception {
        return bizMapper.updateBizCst(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteBizCst(BizVO vo) throws Exception {
        return bizMapper.deleteBizCst(vo);
    }

    @Override
    public List<BizVO> selectBizSchdlList(BizVO vo) throws Exception {
        return bizMapper.selectBizSchdlList(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertBizSchdl(BizVO vo) throws Exception {
        return bizMapper.insertBizSchdl(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateBizSchdl(BizVO vo) throws Exception {
        return bizMapper.updateBizSchdl(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteBizSchdl(BizVO vo) throws Exception {
        return bizMapper.deleteBizSchdl(vo);
    }

    @Override
    public BizVO selectBizProfitSummary(BizVO vo) throws Exception {
        return bizMapper.selectBizProfitSummary(vo);
    }


}
