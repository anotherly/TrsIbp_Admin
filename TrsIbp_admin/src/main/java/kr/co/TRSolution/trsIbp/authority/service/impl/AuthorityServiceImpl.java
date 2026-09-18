package kr.co.TRSolution.trsIbp.authority.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.co.TRSolution.trsIbp.authority.mapper.AuthorityMapper;
import kr.co.TRSolution.trsIbp.authority.service.AuthorityService;
import kr.co.TRSolution.trsIbp.user.vo.UserVO;

@Service("authorityService")
public class AuthorityServiceImpl implements AuthorityService {

    @Resource(name = "authorityMapper")
    private AuthorityMapper authorityMapper;

    @Override
    public List<Map<String, Object>> selectAuthorityList() {
        return authorityMapper.selectAuthorityList();
    }

    @Override
    public List<Map<String, Object>> selectMenuAuthorityList(String authrtId) {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("authrtId", authrtId);
        return authorityMapper.selectMenuAuthorityList(param);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveAuthorityMenu(String authrtId, List<Long> menuSnList, String loginUserId) {
        requireAuthority(authrtId);
        if ("ADMIN".equals(authrtId)) {
            throw new IllegalArgumentException("최고관리자 권한은 전체 기능 사용으로 고정됩니다.");
        }
        authorityMapper.deleteAuthorityMenu(authrtId);
        if (menuSnList == null) {
            return;
        }
        for (Long menuSn : new LinkedHashSet<Long>(menuSnList)) {
            if (menuSn == null) {
                continue;
            }
            Map<String, Object> param = new HashMap<String, Object>();
            param.put("authrtId", authrtId);
            param.put("menuSn", menuSn);
            param.put("loginUserId", loginUserId);
            authorityMapper.insertAuthorityMenu(param);
        }
    }

    @Override
    public void insertAuthority(String authrtId, String authrtNm, String authrtExpln) {
        validateAuthority(authrtId, authrtNm);
        if (authorityMapper.selectAuthorityCount(authrtId) > 0) {
            throw new IllegalArgumentException("이미 사용 중인 권한ID입니다.");
        }
        Map<String, Object> param = authorityParam(authrtId, authrtNm, authrtExpln);
        authorityMapper.insertAuthority(param);
    }

    @Override
    public void updateAuthority(String authrtId, String authrtNm, String authrtExpln) {
        requireAuthority(authrtId);
        validateAuthority(authrtId, authrtNm);
        authorityMapper.updateAuthority(authorityParam(authrtId, authrtNm, authrtExpln));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteAuthority(String authrtId) {
        requireAuthority(authrtId);
        if (Arrays.asList("ADMIN", "MANAGER", "USER").contains(authrtId)) {
            throw new IllegalArgumentException("기본 권한은 삭제할 수 없습니다.");
        }
        if (authorityMapper.selectAuthorityUserCount(authrtId) > 0) {
            throw new IllegalArgumentException("사용 중인 권한은 삭제할 수 없습니다.");
        }
        authorityMapper.deleteAuthorityMenu(authrtId);
        authorityMapper.deleteAuthority(authrtId);
    }

    @Override
    public boolean isRequestGranted(String authrtId, String requestUrl, String menuTypeNm) {
        if ("ADMIN".equals(authrtId)) {
            return true;
        }
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("authrtId", authrtId);
        param.put("requestUrl", requestUrl);
        param.put("menuTypeNm", menuTypeNm);
        int registered = authorityMapper.selectRegisteredMenuCount(param);
        return registered == 0 || authorityMapper.selectGrantedMenuCount(param) > 0;
    }

    @Override
    public Set<String> refreshSessionAuthority(HttpSession session, UserVO loginUser) {
        String authrtId = loginUser == null || loginUser.getAuthrtId() == null
                ? "USER" : loginUser.getAuthrtId();
        Set<String> workspaceSet = new LinkedHashSet<String>();
        Set<String> menuCodeSet = new HashSet<String>();
        Set<String> menuUrlSet = new HashSet<String>();
        String defaultWorkspace = "WORK";
        try {
            workspaceSet.addAll(authorityMapper.selectAllowedWorkspaceList(authrtId));
            menuCodeSet.addAll(authorityMapper.selectGrantedMenuCodeList(authrtId));
            menuUrlSet.addAll(authorityMapper.selectGrantedMenuUrlList(authrtId));
            String storedDefault = loginUser == null ? null
                    : authorityMapper.selectDefaultWorkspace(loginUser.getUserId());
            if (storedDefault != null && workspaceSet.contains(storedDefault)) {
                defaultWorkspace = storedDefault;
            }
        } catch (DataAccessException ex) {
            applyLegacyFallback(authrtId, workspaceSet, menuCodeSet);
        }
        if (workspaceSet.isEmpty()) {
            workspaceSet.add("WORK");
        }
        session.setAttribute("allowedWorkspaces", workspaceSet);
        session.setAttribute("grantedMenuCodes", menuCodeSet);
        session.setAttribute("grantedMenuUrls", menuUrlSet);
        session.setAttribute("defaultWorkspaceId", defaultWorkspace);
        return workspaceSet;
    }

    @Override
    @SuppressWarnings("unchecked")
    public boolean isWorkspaceAllowed(HttpSession session, String workspaceId) {
        Object allowed = session.getAttribute("allowedWorkspaces");
        return allowed instanceof Set && ((Set<String>) allowed).contains(workspaceId);
    }

    @Override
    public boolean isBizAccessAllowed(UserVO loginUser, String bizId) {
        if (bizId == null || bizId.trim().isEmpty() || loginUser == null) {
            return true;
        }
        if ("ADMIN".equals(loginUser.getAuthrtId())) {
            return true;
        }
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("coId", loginUser.getCoId());
        param.put("userId", loginUser.getUserId());
        param.put("bizId", bizId);
        return authorityMapper.selectBizAccessCount(param) > 0;
    }

    @Override
    public boolean isScheduleAccessAllowed(UserVO loginUser, String schdlSn, boolean writeRequest) {
        if (schdlSn == null || schdlSn.trim().isEmpty() || loginUser == null) {
            return true;
        }
        if ("ADMIN".equals(loginUser.getAuthrtId())) {
            return true;
        }
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("coId", loginUser.getCoId());
        param.put("userId", loginUser.getUserId());
        param.put("schdlSn", schdlSn);
        param.put("writeYn", writeRequest ? "Y" : "N");
        return authorityMapper.selectScheduleAccessCount(param) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveDefaultWorkspace(UserVO loginUser, String workspaceId) {
        if (loginUser == null) {
            throw new IllegalArgumentException("로그인 정보가 없습니다.");
        }
        authorityMapper.clearDefaultWorkspace(loginUser.getUserId());
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("userId", loginUser.getUserId());
        param.put("workspaceId", workspaceId);
        authorityMapper.upsertDefaultWorkspace(param);
    }

    private void requireAuthority(String authrtId) {
        if (authrtId == null || authorityMapper.selectAuthorityCount(authrtId) == 0) {
            throw new IllegalArgumentException("존재하지 않는 권한입니다.");
        }
    }

    private void validateAuthority(String authrtId, String authrtNm) {
        if (authrtId == null || !authrtId.matches("^[A-Z][A-Z0-9_]{1,19}$")) {
            throw new IllegalArgumentException("권한ID는 영문 대문자로 시작하는 대문자·숫자·밑줄 2~20자로 입력해 주세요.");
        }
        if (authrtNm == null || authrtNm.trim().isEmpty() || authrtNm.trim().length() > 50) {
            throw new IllegalArgumentException("권한명은 1~50자로 입력해 주세요.");
        }
    }

    private Map<String, Object> authorityParam(String authrtId, String authrtNm, String authrtExpln) {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("authrtId", authrtId);
        param.put("authrtNm", authrtNm == null ? "" : authrtNm.trim());
        param.put("authrtExpln", authrtExpln == null ? "" : authrtExpln.trim());
        return param;
    }

    private void applyLegacyFallback(String authrtId, Set<String> workspaceSet, Set<String> menuCodeSet) {
        workspaceSet.add("WORK");
        menuCodeSet.add("WORK_DASHBOARD_SCREEN");
        menuCodeSet.add("WORK_SCHEDULE_LIST_SCREEN");
        if ("ADMIN".equals(authrtId) || "MANAGER".equals(authrtId)) {
            workspaceSet.addAll(Arrays.asList("PROJECT", "ORG", "MANAGEMENT"));
            menuCodeSet.addAll(new ArrayList<String>(Arrays.asList(
                    "PROJECT_DASHBOARD_SCREEN", "PROJECT_BIZ_LIST_SCREEN",
                    "PROJECT_CONTRACT_SCREEN", "PROJECT_ACCOUNT_SCREEN",
                    "PROJECT_MNPW_SCREEN", "PROJECT_PROCESS_SCREEN",
                    "ORG_DASHBOARD_SCREEN", "MANAGEMENT_DASHBOARD_SCREEN")));
        }
        if ("ADMIN".equals(authrtId)) {
            menuCodeSet.addAll(Arrays.asList("MANAGEMENT_ORG_SCREEN",
                    "MANAGEMENT_USER_SCREEN", "MANAGEMENT_AUTHRT_SCREEN"));
        }
    }
}
