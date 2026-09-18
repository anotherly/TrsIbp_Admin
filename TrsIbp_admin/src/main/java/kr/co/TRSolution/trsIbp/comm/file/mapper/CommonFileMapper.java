package kr.co.TRSolution.trsIbp.comm.file.mapper;

import java.util.List;

import egovframework.rte.psl.dataaccess.mapper.Mapper;
import kr.co.TRSolution.trsIbp.comm.file.vo.CommonFileVO;

@Mapper("commonFileMapper")
public interface CommonFileMapper {
    public void insertFile(CommonFileVO fileVO) throws Exception;
    public CommonFileVO selectFile(CommonFileVO fileVO) throws Exception;
    public List<CommonFileVO> selectFileList(CommonFileVO fileVO) throws Exception;
    public void deactivateProfileFiles(CommonFileVO fileVO) throws Exception;
    public void deleteFile(CommonFileVO fileVO) throws Exception;
}
