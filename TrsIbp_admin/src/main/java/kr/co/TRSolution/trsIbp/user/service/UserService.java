package kr.co.TRSolution.trsIbp.user.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import kr.co.TRSolution.trsIbp.user.vo.UserVO;

/**
 * 사용자 서비스 인터페이스
 *
 * @author DevSync
 * @since 2026-05-28
 */
public interface UserService {

    /** 사용자 목록 조회 */
    public List<UserVO> selectUserList(UserVO userVO) throws Exception;

    /** 특정 사용자 단건 조회 */
    public UserVO selectUser(UserVO userVO) throws Exception;

    /** 로그인용 단건 조회 (비밀번호 포함) */
    public UserVO selectUserForLogin(UserVO userVO) throws Exception;

    /** 사용자 등록 */
    public void insertUser(UserVO userVO) throws Exception;

    /** 사용자 정보 수정 */
    public void updateUser(UserVO userVO);

    /** 사용자 삭제 */
    public void deleteUser(UserVO userVO);

    /** 회사 목록 조회 */
    public List<Map<String, Object>> selectCompanyList(UserVO userVO);

    /** 권한 목록 조회 */
    public List<Map<String, Object>> selectAuthList();
    /**
     * 사용자 선택 모달에 표시할 로그인 사용자 회사의 부서 목록을 조회한다.
     * @param userVO coId, searchKeyword 등 조회조건을 담은 사용자 VO
     * @return 부서 목록
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    public List<UserVO> selectUserSelectDeptList(UserVO userVO) throws Exception;

    /**
     * 사용자 선택 모달에 표시할 로그인 사용자 회사의 사용자 목록을 조회한다.
     * @param userVO coId, deptId, searchKeyword 등 조회조건을 담은 사용자 VO
     * @return 사용자 목록
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    public List<UserVO> selectUserSelectUserList(UserVO userVO) throws Exception;

    /** 사용자(직원) 관리 목록 조회 */
    public List<UserVO> selectUserManageList(UserVO userVO) throws Exception;

    /** 사용자(직원) 관리 단건 조회 */
    public UserVO selectUserManage(UserVO userVO) throws Exception;

    /** 사용자ID 중복 건수 조회 */
    public int selectUserIdCount(UserVO userVO) throws Exception;

    /** 로그인 사용자 회사의 부서 목록 조회 */
    public List<UserVO> selectDeptListByCoId(UserVO userVO) throws Exception;

    /** 사용자(직원) 관리 등록 */
    public void insertUserManage(UserVO userVO) throws Exception;

    /** 사용자 기본정보와 프로필 사진/증빙서류를 함께 등록 */
    public void insertUserManage(UserVO userVO, MultipartFile profileFile,
            MultipartFile[] userFiles, String rgtrId) throws Exception;

    /** 사용자(직원) 관리 수정 */
    public void updateUserManage(UserVO userVO) throws Exception;

    /** 사용자 기본정보와 새 프로필 사진/증빙서류를 함께 수정 */
    public void updateUserManage(UserVO userVO, MultipartFile profileFile,
            MultipartFile[] userFiles, String rgtrId) throws Exception;

    /** 사용자(직원) 관리 삭제 처리 */
    public void deleteUserManage(UserVO userVO) throws Exception;

}
