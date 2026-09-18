package kr.co.TRSolution.trsIbp.comm.file.service;

import java.nio.file.Path;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import kr.co.TRSolution.trsIbp.comm.file.vo.CommonFileVO;

public interface CommonFileService {
    public CommonFileVO storeFileOnly(MultipartFile file, String directoryName, String fileSeCd) throws Exception;
    public void replaceProfileFile(String coId, String userId, MultipartFile file, String rgtrId) throws Exception;
    public void saveUserDocumentFiles(String coId, String userId, MultipartFile[] files, String rgtrId) throws Exception;
    public CommonFileVO selectFile(Long atchFileSn) throws Exception;
    public CommonFileVO selectUserProfileFile(String coId, String userId) throws Exception;
    public List<CommonFileVO> selectUserDocumentFileList(String coId, String userId) throws Exception;
    public void deleteUserFile(Long atchFileSn, String coId, String userId) throws Exception;
    public Path resolveStoredFile(CommonFileVO fileVO) throws Exception;
}
