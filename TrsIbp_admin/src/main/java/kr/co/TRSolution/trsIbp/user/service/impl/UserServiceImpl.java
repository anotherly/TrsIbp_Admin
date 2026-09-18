package kr.co.TRSolution.trsIbp.user.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.co.TRSolution.trsIbp.comm.file.service.CommonFileService;
import kr.co.TRSolution.trsIbp.user.mapper.UserMapper;
import kr.co.TRSolution.trsIbp.user.service.UserService;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

/**
 * 사용자 서비스 구현 클래스
 *
 * @author DevSync
 * @since 2026-05-28
 */
@Service("userService")
public class UserServiceImpl implements UserService {

    @Resource(name = "userMapper")
    private UserMapper userMapper;

    @Resource(name = "commonFileService")
    private CommonFileService commonFileService;

    /** 사용자 목록 조회 */
    @Override
    public List<UserVO> selectUserList(UserVO userVO) throws Exception {
        return userMapper.selectUser(userVO);
    }

    /** 특정 사용자 단건 조회 */
    @Override
    public UserVO selectUser(UserVO userVO) throws Exception {
        List<UserVO> list = userMapper.selectUser(userVO);
        return (list != null && !list.isEmpty()) ? list.get(0) : null;
    }

    /** 로그인용 단건 조회 (비밀번호 포함) */
    @Override
    public UserVO selectUserForLogin(UserVO userVO) throws Exception {
        return userMapper.selectUserForLogin(userVO);
    }

    /** 사용자 등록 */
    @Override
    public void insertUser(UserVO userVO) throws Exception {
        userMapper.insertUser(userVO);
    }

    /** 사용자 정보 수정 */
    @Override
    public void updateUser(UserVO userVO) {
        userMapper.updateUser(userVO);
    }

    /** 사용자 삭제 */
    @Override
    public void deleteUser(UserVO userVO) {
        userMapper.deleteUser(userVO);
    }

    /** 회사 목록 조회 */
    @Override
    public List<Map<String, Object>> selectCompanyList(UserVO userVO) {
        return userMapper.selectCompanyList(userVO);
    }

    /** 권한 목록 조회 */
    @Override
    public List<Map<String, Object>> selectAuthList() {
        return userMapper.selectAuthList();
    }
    /**
     * 사용자 선택 모달에 표시할 로그인 사용자 회사의 부서 목록을 조회한다.
     * @param userVO coId, searchKeyword 등 조회조건을 담은 사용자 VO
     * @return 부서 목록
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @Override
    public List<UserVO> selectUserSelectDeptList(UserVO userVO) throws Exception {
        return userMapper.selectUserSelectDeptList(userVO);
    }

    /**
     * 사용자 선택 모달에 표시할 로그인 사용자 회사의 사용자 목록을 조회한다.
     * @param userVO coId, deptId, searchKeyword 등 조회조건을 담은 사용자 VO
     * @return 사용자 목록
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @Override
    public List<UserVO> selectUserSelectUserList(UserVO userVO) throws Exception {
        return userMapper.selectUserSelectUserList(userVO);
    }

    /** 사용자(직원) 관리 목록 조회 */
    @Override
    public List<UserVO> selectUserManageList(UserVO userVO) throws Exception {
        return userMapper.selectUserManageList(userVO);
    }

    /** 사용자(직원) 관리 단건 조회 */
    @Override
    public UserVO selectUserManage(UserVO userVO) throws Exception {
        return userMapper.selectUserManage(userVO);
    }

    /** 사용자ID 중복 건수 조회 */
    @Override
    public int selectUserIdCount(UserVO userVO) throws Exception {
        return userMapper.selectUserIdCount(userVO);
    }

    /** 로그인 사용자 회사의 부서 목록 조회 */
    @Override
    public List<UserVO> selectDeptListByCoId(UserVO userVO) throws Exception {
        return userMapper.selectDeptListByCoId(userVO);
    }

    /** 사용자(직원) 관리 등록 */
    @Override
    public void insertUserManage(UserVO userVO) throws Exception {
        userMapper.insertUserManage(userVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void insertUserManage(UserVO userVO, MultipartFile profileFile,
            MultipartFile[] userFiles, String rgtrId) throws Exception {
        userMapper.insertUserManage(userVO);
        commonFileService.replaceProfileFile(userVO.getCoId(), userVO.getUserId(), profileFile, rgtrId);
        commonFileService.saveUserDocumentFiles(userVO.getCoId(), userVO.getUserId(), userFiles, rgtrId);
    }

    /** 사용자(직원) 관리 수정 */
    @Override
    public void updateUserManage(UserVO userVO) throws Exception {
        userMapper.updateUserManage(userVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateUserManage(UserVO userVO, MultipartFile profileFile,
            MultipartFile[] userFiles, String rgtrId) throws Exception {
        userMapper.updateUserManage(userVO);
        commonFileService.replaceProfileFile(userVO.getCoId(), userVO.getUserId(), profileFile, rgtrId);
        commonFileService.saveUserDocumentFiles(userVO.getCoId(), userVO.getUserId(), userFiles, rgtrId);
    }

    /** 사용자(직원) 관리 삭제 처리 */
    @Override
    public void deleteUserManage(UserVO userVO) throws Exception {
        userMapper.deleteUserManage(userVO);
    }

}
