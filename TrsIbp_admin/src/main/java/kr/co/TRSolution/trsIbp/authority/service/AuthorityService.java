package kr.co.TRSolution.trsIbp.authority.service;

import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpSession;

import kr.co.TRSolution.trsIbp.user.vo.UserVO;

public interface AuthorityService {

    List<Map<String, Object>> selectAuthorityList();

    List<Map<String, Object>> selectMenuAuthorityList(String authrtId);

    void saveAuthorityMenu(String authrtId, List<Long> menuSnList, String loginUserId);

    void insertAuthority(String authrtId, String authrtNm, String authrtExpln);

    void updateAuthority(String authrtId, String authrtNm, String authrtExpln);

    void deleteAuthority(String authrtId);

    boolean isRequestGranted(String authrtId, String requestUrl, String menuTypeNm);

    Set<String> refreshSessionAuthority(HttpSession session, UserVO loginUser);

    boolean isWorkspaceAllowed(HttpSession session, String workspaceId);

    boolean isBizAccessAllowed(UserVO loginUser, String bizId);

    boolean isScheduleAccessAllowed(UserVO loginUser, String schdlSn, boolean writeRequest);

    void saveDefaultWorkspace(UserVO loginUser, String workspaceId);
}
