package kr.co.TRSolution.trsIbp.authority.mapper;

import java.util.List;
import java.util.Map;

import egovframework.rte.psl.dataaccess.mapper.Mapper;

@Mapper("authorityMapper")
public interface AuthorityMapper {

    List<Map<String, Object>> selectAuthorityList();

    List<Map<String, Object>> selectMenuAuthorityList(Map<String, Object> param);

    List<String> selectGrantedMenuCodeList(String authrtId);

    List<String> selectGrantedMenuUrlList(String authrtId);

    List<String> selectAllowedWorkspaceList(String authrtId);

    String selectDefaultWorkspace(String userId);

    int selectRegisteredMenuCount(Map<String, Object> param);

    int selectGrantedMenuCount(Map<String, Object> param);

    int selectAuthorityCount(String authrtId);

    int selectAuthorityUserCount(String authrtId);

    int selectBizAccessCount(Map<String, Object> param);

    int selectScheduleAccessCount(Map<String, Object> param);

    int insertAuthority(Map<String, Object> param);

    int updateAuthority(Map<String, Object> param);

    int deleteAuthorityMenu(String authrtId);

    int deleteAuthority(String authrtId);

    int insertAuthorityMenu(Map<String, Object> param);

    int clearDefaultWorkspace(String userId);

    int upsertDefaultWorkspace(Map<String, Object> param);
}
