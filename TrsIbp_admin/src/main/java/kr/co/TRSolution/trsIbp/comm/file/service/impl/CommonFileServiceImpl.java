package kr.co.TRSolution.trsIbp.comm.file.service.impl;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import egovframework.rte.fdl.property.EgovPropertyService;
import kr.co.TRSolution.trsIbp.comm.file.mapper.CommonFileMapper;
import kr.co.TRSolution.trsIbp.comm.file.service.CommonFileService;
import kr.co.TRSolution.trsIbp.comm.file.vo.CommonFileVO;
import kr.co.TRSolution.trsIbp.comm.util.UploadPolicy;

@Service("commonFileService")
public class CommonFileServiceImpl implements CommonFileService {

    private static final String USER_REF_SE_CD = "USER";
    private static final String PROFILE_FILE_SE_CD = "PROFILE";
    private static final String DOCUMENT_FILE_SE_CD = "DOCUMENT";
    private static final int MAX_DOCUMENT_FILE_COUNT = 10;

    @Resource(name = "commonFileMapper")
    private CommonFileMapper commonFileMapper;

    @Resource(name = "propertiesService")
    private EgovPropertyService propertiesService;

    @Override
    public CommonFileVO storeFileOnly(MultipartFile file, String directoryName, String fileSeCd) throws Exception {
        if (file == null || file.isEmpty()) {
            return null;
        }
        if (PROFILE_FILE_SE_CD.equals(fileSeCd)) {
            UploadPolicy.validateImage(file);
        } else {
            UploadPolicy.validate(file);
        }

        String safeDirectory = normalizeDirectoryName(directoryName);
        String extension = UploadPolicy.extractSafeExt(file.getOriginalFilename());
        String encryptedName = UUID.randomUUID().toString() + "." + extension;
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        Path root = getUploadRoot();
        Path relativeDirectory = Paths.get(safeDirectory, datePath);
        Path targetDirectory = root.resolve(relativeDirectory).normalize();
        if (!targetDirectory.startsWith(root)) {
            throw new IllegalArgumentException("파일 저장 경로가 올바르지 않습니다.");
        }
        Files.createDirectories(targetDirectory);
        Path targetFile = targetDirectory.resolve(encryptedName).normalize();

        try (InputStream inputStream = file.getInputStream()) {
            Files.copy(inputStream, targetFile, StandardCopyOption.REPLACE_EXISTING);
        }

        CommonFileVO fileVO = new CommonFileVO();
        fileVO.setFileSeCd(fileSeCd);
        fileVO.setOrgnlFileNm(UploadPolicy.extractSafeOriginalName(file.getOriginalFilename()));
        fileVO.setEncptFileNm(encryptedName);
        fileVO.setFilePathNm(relativeDirectory.toString().replace('\\', '/'));
        fileVO.setFileSz(file.getSize());
        fileVO.setFileExtnNm(extension);
        fileVO.setUseYn("Y");
        return fileVO;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void replaceProfileFile(String coId, String userId, MultipartFile file, String rgtrId) throws Exception {
        if (file == null || file.isEmpty()) {
            return;
        }
        CommonFileVO fileVO = storeFileOnly(file, "user/profile", PROFILE_FILE_SE_CD);
        populateReference(fileVO, coId, userId, rgtrId, 1);
        commonFileMapper.deactivateProfileFiles(fileVO);
        try {
            commonFileMapper.insertFile(fileVO);
        } catch (Exception e) {
            Files.deleteIfExists(resolveStoredFile(fileVO));
            throw e;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveUserDocumentFiles(String coId, String userId, MultipartFile[] files, String rgtrId) throws Exception {
        if (files == null || files.length == 0) {
            return;
        }
        int activeCount = 0;
        for (MultipartFile file : files) {
            if (file != null && !file.isEmpty()) {
                activeCount++;
            }
        }
        List<CommonFileVO> existingFiles = selectUserDocumentFileList(coId, userId);
        if (existingFiles.size() + activeCount > MAX_DOCUMENT_FILE_COUNT) {
            throw new IllegalArgumentException("사용자 첨부파일은 기존 파일을 포함해 최대 10개까지 등록할 수 있습니다.");
        }

        int sortSeq = existingFiles.size() + 1;
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) {
                continue;
            }
            CommonFileVO fileVO = storeFileOnly(file, "user/document", DOCUMENT_FILE_SE_CD);
            populateReference(fileVO, coId, userId, rgtrId, sortSeq++);
            try {
                commonFileMapper.insertFile(fileVO);
            } catch (Exception e) {
                Files.deleteIfExists(resolveStoredFile(fileVO));
                throw e;
            }
        }
    }

    @Override
    public CommonFileVO selectFile(Long atchFileSn) throws Exception {
        if (atchFileSn == null) {
            return null;
        }
        CommonFileVO param = new CommonFileVO();
        param.setAtchFileSn(atchFileSn);
        return commonFileMapper.selectFile(param);
    }

    @Override
    public CommonFileVO selectUserProfileFile(String coId, String userId) throws Exception {
        List<CommonFileVO> list = selectFileList(coId, userId, PROFILE_FILE_SE_CD);
        return list.isEmpty() ? null : list.get(0);
    }

    @Override
    public List<CommonFileVO> selectUserDocumentFileList(String coId, String userId) throws Exception {
        return selectFileList(coId, userId, DOCUMENT_FILE_SE_CD);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteUserFile(Long atchFileSn, String coId, String userId) throws Exception {
        CommonFileVO existing = selectFile(atchFileSn);
        if (existing == null || !USER_REF_SE_CD.equals(existing.getRefSeCd())
                || !safeEquals(coId, existing.getCoId()) || !safeEquals(userId, existing.getRefId())) {
            throw new IllegalArgumentException("삭제할 첨부파일이 없거나 접근 권한이 없습니다.");
        }
        CommonFileVO param = new CommonFileVO();
        param.setAtchFileSn(atchFileSn);
        param.setCoId(coId);
        param.setRefId(userId);
        commonFileMapper.deleteFile(param);
    }

    @Override
    public Path resolveStoredFile(CommonFileVO fileVO) throws Exception {
        if (fileVO == null || fileVO.getFilePathNm() == null || fileVO.getEncptFileNm() == null) {
            throw new IllegalArgumentException("파일 저장정보가 올바르지 않습니다.");
        }
        Path root = getUploadRoot();
        Path resolved = root.resolve(fileVO.getFilePathNm()).resolve(fileVO.getEncptFileNm()).normalize();
        if (!resolved.startsWith(root)) {
            throw new IllegalArgumentException("파일 저장경로가 올바르지 않습니다.");
        }
        return resolved;
    }

    private List<CommonFileVO> selectFileList(String coId, String userId, String fileSeCd) throws Exception {
        if (coId == null || userId == null) {
            return Collections.emptyList();
        }
        CommonFileVO param = new CommonFileVO();
        param.setCoId(coId);
        param.setRefSeCd(USER_REF_SE_CD);
        param.setRefId(userId);
        param.setFileSeCd(fileSeCd);
        return commonFileMapper.selectFileList(param);
    }

    private void populateReference(CommonFileVO fileVO, String coId, String userId, String rgtrId, int sortSeq) {
        fileVO.setCoId(coId);
        fileVO.setRefSeCd(USER_REF_SE_CD);
        fileVO.setRefId(userId);
        fileVO.setRgtrId(rgtrId);
        fileVO.setSortSeq(sortSeq);
    }

    private Path getUploadRoot() {
        String configuredRoot = System.getProperty("trs.fileUploadRoot");
        if (configuredRoot == null || configuredRoot.trim().isEmpty()) {
            configuredRoot = System.getenv("TRS_FILE_UPLOAD_ROOT");
        }
        if (configuredRoot == null || configuredRoot.trim().isEmpty()) {
            configuredRoot = propertiesService.getString("fileUploadRoot");
        }
        if (configuredRoot == null || configuredRoot.trim().isEmpty()) {
            configuredRoot = "C:/trsStorage";
        }
        return Paths.get(configuredRoot).toAbsolutePath().normalize();
    }

    private String normalizeDirectoryName(String directoryName) {
        String value = directoryName == null ? "common" : directoryName.trim();
        if (!value.matches("[A-Za-z0-9_/-]+") || value.contains("..")) {
            throw new IllegalArgumentException("파일 저장 구분값이 올바르지 않습니다.");
        }
        return value;
    }

    private boolean safeEquals(String left, String right) {
        return left == null ? right == null : left.equals(right);
    }
}
