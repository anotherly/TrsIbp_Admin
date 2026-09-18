/* DevSync 업무공간·메뉴 권한 확장
 * 기준 DB: trs_ibp(9).sql
 * 용어 기준: 공공데이터 공통표준(2025.11월)
 * MariaDB 10.6 / 재실행 가능
 *
 * 기존 user_info.authrt_id는 사용자-권한 연결용으로 계속 사용한다.
 */

ALTER TABLE authrt_info
    ADD COLUMN IF NOT EXISTS USE_YN char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    ADD COLUMN IF NOT EXISTS REG_DT datetime NOT NULL DEFAULT current_timestamp() COMMENT '등록일시',
    ADD COLUMN IF NOT EXISTS MDFCN_DT datetime DEFAULT NULL COMMENT '수정일시';

CREATE TABLE IF NOT EXISTS workspc_info (
  WORKSPC_ID varchar(20) NOT NULL COMMENT '업무공간ID',
  WORKSPC_NM varchar(100) NOT NULL COMMENT '업무공간명',
  WORKSPC_EXPLN varchar(4000) DEFAULT NULL COMMENT '업무공간설명',
  SORT_SEQ int(11) NOT NULL DEFAULT 0 COMMENT '정렬순서',
  USE_YN char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  REG_DT datetime NOT NULL DEFAULT current_timestamp() COMMENT '등록일시',
  MDFCN_DT datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (WORKSPC_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='업무공간정보';

CREATE TABLE IF NOT EXISTS menu_info (
  MENU_SN bigint(20) NOT NULL COMMENT '메뉴일련번호',
  MENU_CD varchar(50) NOT NULL COMMENT '메뉴코드',
  WORKSPC_ID varchar(20) NOT NULL COMMENT '업무공간ID',
  UP_MENU_SN bigint(20) DEFAULT NULL COMMENT '상위메뉴일련번호',
  MENU_NM varchar(100) NOT NULL COMMENT '메뉴명',
  MENU_URL_ADDR varchar(2000) DEFAULT NULL COMMENT '메뉴URL주소',
  MENU_TYPE_NM varchar(300) NOT NULL DEFAULT 'SCREEN' COMMENT '메뉴유형명',
  MENU_ICON_NM varchar(300) DEFAULT NULL COMMENT '메뉴아이콘명',
  MENU_LV varchar(10) NOT NULL DEFAULT '1' COMMENT '메뉴레벨',
  MENU_SORT_SEQ int(11) NOT NULL DEFAULT 0 COMMENT '메뉴정렬순서',
  MENU_USE_YN char(1) NOT NULL DEFAULT 'Y' COMMENT '메뉴사용여부',
  AUTHRT_CHK_YN char(1) NOT NULL DEFAULT 'Y' COMMENT '권한확인여부',
  REG_DT datetime NOT NULL DEFAULT current_timestamp() COMMENT '등록일시',
  MDFCN_DT datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (MENU_SN),
  UNIQUE KEY UK_MENU_INFO_MENU_CD (MENU_CD),
  KEY IDX_MENU_INFO_WORKSPC (WORKSPC_ID, MENU_SORT_SEQ),
  KEY IDX_MENU_INFO_URL (MENU_URL_ADDR(255)),
  KEY IDX_MENU_INFO_UP_MENU (UP_MENU_SN),
  CONSTRAINT FK_MENU_INFO_WORKSPC FOREIGN KEY (WORKSPC_ID) REFERENCES workspc_info (WORKSPC_ID),
  CONSTRAINT FK_MENU_INFO_UP_MENU FOREIGN KEY (UP_MENU_SN) REFERENCES menu_info (MENU_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='메뉴정보';

CREATE TABLE IF NOT EXISTS authrt_menu_rel (
  AUTHRT_ID varchar(20) NOT NULL COMMENT '권한ID',
  MENU_SN bigint(20) NOT NULL COMMENT '메뉴일련번호',
  AUTHRT_GRNT_YN char(1) NOT NULL DEFAULT 'Y' COMMENT '권한부여여부',
  REG_DT datetime NOT NULL DEFAULT current_timestamp() COMMENT '등록일시',
  MDFCN_DT datetime DEFAULT NULL COMMENT '수정일시',
  RGTR_ID varchar(50) DEFAULT NULL COMMENT '등록자아이디',
  MDFR_ID varchar(50) DEFAULT NULL COMMENT '수정자아이디',
  PRIMARY KEY (AUTHRT_ID, MENU_SN),
  KEY IDX_AUTHRT_MENU_REL_MENU (MENU_SN),
  CONSTRAINT FK_AUTHRT_MENU_REL_AUTHRT FOREIGN KEY (AUTHRT_ID) REFERENCES authrt_info (AUTHRT_ID),
  CONSTRAINT FK_AUTHRT_MENU_REL_MENU FOREIGN KEY (MENU_SN) REFERENCES menu_info (MENU_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='권한메뉴관계';

CREATE TABLE IF NOT EXISTS user_workspc_rel (
  USER_ID varchar(50) NOT NULL COMMENT '사용자아이디',
  WORKSPC_ID varchar(20) NOT NULL COMMENT '업무공간ID',
  DFLT_YN char(1) NOT NULL DEFAULT 'N' COMMENT '기본여부',
  USE_YN char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  REG_DT datetime NOT NULL DEFAULT current_timestamp() COMMENT '등록일시',
  MDFCN_DT datetime DEFAULT NULL COMMENT '수정일시',
  RGTR_ID varchar(50) DEFAULT NULL COMMENT '등록자아이디',
  MDFR_ID varchar(50) DEFAULT NULL COMMENT '수정자아이디',
  PRIMARY KEY (USER_ID, WORKSPC_ID),
  KEY IDX_USER_WORKSPC_REL_WORKSPC (WORKSPC_ID),
  CONSTRAINT FK_USER_WORKSPC_REL_USER FOREIGN KEY (USER_ID) REFERENCES user_info (USER_ID),
  CONSTRAINT FK_USER_WORKSPC_REL_WORKSPC FOREIGN KEY (WORKSPC_ID) REFERENCES workspc_info (WORKSPC_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자업무공간관계';

INSERT INTO workspc_info
  (WORKSPC_ID, WORKSPC_NM, WORKSPC_EXPLN, SORT_SEQ, USE_YN)
VALUES
  ('WORK', '내 업무', '전 직원 공통 개인 업무공간', 1, 'Y'),
  ('PROJECT', '프로젝트 관리', '담당·참여 프로젝트 관리 업무공간', 2, 'Y'),
  ('ORG', '조직 관리', '권한 범위의 조직원 현황 업무공간', 3, 'Y'),
  ('MANAGEMENT', '경영 관리', '인사·계약·회계·구매 관리 업무공간', 4, 'Y')
ON DUPLICATE KEY UPDATE
  WORKSPC_NM = VALUES(WORKSPC_NM),
  WORKSPC_EXPLN = VALUES(WORKSPC_EXPLN),
  SORT_SEQ = VALUES(SORT_SEQ),
  USE_YN = VALUES(USE_YN);

/* 1레벨은 권한화면 그룹, 2레벨은 실제 화면·기능이다. */
INSERT INTO menu_info
  (MENU_SN, MENU_CD, WORKSPC_ID, UP_MENU_SN, MENU_NM, MENU_URL_ADDR,
   MENU_TYPE_NM, MENU_ICON_NM, MENU_LV, MENU_SORT_SEQ, MENU_USE_YN, AUTHRT_CHK_YN)
VALUES
  (1000, 'WORK_DASHBOARD', 'WORK', NULL, '내 업무 대시보드', NULL, 'GROUP', 'fa-house', '1', 10, 'Y', 'N'),
  (1001, 'WORK_DASHBOARD_SCREEN', 'WORK', 1000, '화면', '/main/main.do', 'SCREEN', NULL, '2', 11, 'Y', 'Y'),
  (1100, 'WORK_SCHEDULE', 'WORK', NULL, '일정 관리', NULL, 'GROUP', 'fa-calendar-days', '1', 20, 'Y', 'N'),
  (1101, 'WORK_SCHEDULE_LIST_SCREEN', 'WORK', 1100, '목록 화면', '/schedule/scheduleList.do', 'SCREEN', NULL, '2', 21, 'Y', 'Y'),
  (1102, 'WORK_SCHEDULE_LIST', 'WORK', 1100, '목록', '/schedule/scheduleList.ajax', 'LIST', NULL, '2', 22, 'Y', 'Y'),
  (1103, 'WORK_SCHEDULE_DETAIL', 'WORK', 1100, '상세', '/schedule/scheduleDetail.ajax', 'DETAIL', NULL, '2', 23, 'Y', 'Y'),
  (1104, 'WORK_SCHEDULE_REG', 'WORK', 1100, '등록', '/schedule/scheduleSave.ajax', 'REG', NULL, '2', 24, 'Y', 'Y'),
  (1105, 'WORK_SCHEDULE_MDFCN', 'WORK', 1100, '수정', '/schedule/scheduleSave.ajax', 'MDFCN', NULL, '2', 25, 'Y', 'Y'),
  (1106, 'WORK_SCHEDULE_DEL', 'WORK', 1100, '삭제', '/schedule/scheduleDelete.ajax', 'DEL', NULL, '2', 26, 'Y', 'Y'),
  (1107, 'WORK_SCHEDULE_META', 'WORK', 1100, '일정 기준정보 조회', '/schedule/scheduleMeta.ajax', 'LIST', NULL, '2', 27, 'Y', 'Y'),
  (1108, 'WORK_SCHEDULE_DASHBOARD', 'WORK', 1100, '대시보드 일정 조회', '/schedule/dashboardSchedule.ajax', 'LIST', NULL, '2', 28, 'Y', 'Y'),
  (1109, 'WORK_SCHEDULE_WORK_HOUR', 'WORK', 1100, '사용자 근무시간 조회', '/schedule/userWorkHourSchedule.ajax', 'LIST', NULL, '2', 29, 'Y', 'Y'),

  (2000, 'PROJECT_DASHBOARD', 'PROJECT', NULL, '프로젝트 대시보드', NULL, 'GROUP', 'fa-chart-line', '1', 10, 'Y', 'N'),
  (2001, 'PROJECT_DASHBOARD_SCREEN', 'PROJECT', 2000, '화면', '/main/main.do', 'SCREEN', NULL, '2', 11, 'Y', 'Y'),
  (2100, 'PROJECT_BIZ', 'PROJECT', NULL, '사업 관리', NULL, 'GROUP', 'fa-diagram-project', '1', 20, 'Y', 'N'),
  (2101, 'PROJECT_BIZ_LIST_SCREEN', 'PROJECT', 2100, '목록 화면', '/biz/bizList.do', 'SCREEN', NULL, '2', 21, 'Y', 'Y'),
  (2102, 'PROJECT_BIZ_LIST', 'PROJECT', 2100, '목록', '/biz/bizList.ajax', 'LIST', NULL, '2', 22, 'Y', 'Y'),
  (2103, 'PROJECT_BIZ_DETAIL', 'PROJECT', 2100, '상세', '/biz/bizDetail.ajax', 'DETAIL', NULL, '2', 23, 'Y', 'Y'),
  (2104, 'PROJECT_BIZ_REG_SCREEN', 'PROJECT', 2100, '등록 화면', '/biz/bizInsert.do', 'SCREEN', NULL, '2', 24, 'Y', 'Y'),
  (2105, 'PROJECT_BIZ_REG', 'PROJECT', 2100, '등록', '/biz/bizSave.ajax', 'REG', NULL, '2', 25, 'Y', 'Y'),
  (2106, 'PROJECT_BIZ_MDFCN_SCREEN', 'PROJECT', 2100, '수정 화면', '/biz/bizUpdate.do', 'SCREEN', NULL, '2', 26, 'Y', 'Y'),
  (2107, 'PROJECT_BIZ_MDFCN', 'PROJECT', 2100, '수정', '/biz/bizSave.ajax', 'MDFCN', NULL, '2', 27, 'Y', 'Y'),
  (2108, 'PROJECT_BIZ_DEL', 'PROJECT', 2100, '삭제', '/biz/bizDelete.ajax', 'DEL', NULL, '2', 28, 'Y', 'Y'),
  (2200, 'PROJECT_CONTRACT', 'PROJECT', NULL, '계약 관리', NULL, 'GROUP', 'fa-file-signature', '1', 30, 'Y', 'N'),
  (2201, 'PROJECT_CONTRACT_SCREEN', 'PROJECT', 2200, '화면', '/biz/contractList.do', 'SCREEN', NULL, '2', 31, 'Y', 'Y'),
  (2202, 'PROJECT_CONTRACT_LIST', 'PROJECT', 2200, '조회', '/biz/custRelList.ajax', 'LIST', NULL, '2', 32, 'Y', 'Y'),
  (2203, 'PROJECT_CONTRACT_REG', 'PROJECT', 2200, '등록', '/biz/custRelSave.ajax', 'REG', NULL, '2', 33, 'Y', 'Y'),
  (2204, 'PROJECT_CONTRACT_MDFCN', 'PROJECT', 2200, '수정', '/biz/custRelSave.ajax', 'MDFCN', NULL, '2', 34, 'Y', 'Y'),
  (2205, 'PROJECT_CONTRACT_DEL', 'PROJECT', 2200, '삭제', '/biz/custRelDelete.ajax', 'DEL', NULL, '2', 35, 'Y', 'Y'),
  (2206, 'PROJECT_CUSTOMER_LIST', 'PROJECT', 2200, '고객사 조회', '/biz/custList.ajax', 'LIST', NULL, '2', 36, 'Y', 'Y'),
  (2207, 'PROJECT_CUSTOMER_REG', 'PROJECT', 2200, '고객사 등록', '/biz/custSave.ajax', 'REG', NULL, '2', 37, 'Y', 'Y'),
  (2208, 'PROJECT_CUSTOMER_MDFCN', 'PROJECT', 2200, '고객사 수정', '/biz/custSave.ajax', 'MDFCN', NULL, '2', 38, 'Y', 'Y'),
  (2209, 'PROJECT_CUSTOMER_DEL', 'PROJECT', 2200, '고객사 삭제', '/biz/custDelete.ajax', 'DEL', NULL, '2', 39, 'Y', 'Y'),
  (2300, 'PROJECT_ACCOUNT', 'PROJECT', NULL, '회계 관리', NULL, 'GROUP', 'fa-coins', '1', 40, 'Y', 'N'),
  (2301, 'PROJECT_ACCOUNT_SCREEN', 'PROJECT', 2300, '화면', '/biz/accountList.do', 'SCREEN', NULL, '2', 41, 'Y', 'Y'),
  (2302, 'PROJECT_ACCOUNT_LIST', 'PROJECT', 2300, '조회', '/biz/cstList.ajax', 'LIST', NULL, '2', 42, 'Y', 'Y'),
  (2303, 'PROJECT_ACCOUNT_REG', 'PROJECT', 2300, '등록', '/biz/cstSave.ajax', 'REG', NULL, '2', 43, 'Y', 'Y'),
  (2304, 'PROJECT_ACCOUNT_MDFCN', 'PROJECT', 2300, '수정', '/biz/cstSave.ajax', 'MDFCN', NULL, '2', 44, 'Y', 'Y'),
  (2305, 'PROJECT_ACCOUNT_DEL', 'PROJECT', 2300, '삭제', '/biz/cstDelete.ajax', 'DEL', NULL, '2', 45, 'Y', 'Y'),
  (2306, 'PROJECT_ACCOUNT_PROFIT', 'PROJECT', 2300, '손익 조회', '/biz/profitSummary.ajax', 'LIST', NULL, '2', 46, 'Y', 'Y'),
  (2400, 'PROJECT_MNPW', 'PROJECT', NULL, '투입인력 관리', NULL, 'GROUP', 'fa-people-group', '1', 50, 'Y', 'N'),
  (2401, 'PROJECT_MNPW_SCREEN', 'PROJECT', 2400, '화면', '/biz/mnpwList.do', 'SCREEN', NULL, '2', 51, 'Y', 'Y'),
  (2402, 'PROJECT_MNPW_LIST', 'PROJECT', 2400, '조회', '/biz/mnpwList.ajax', 'LIST', NULL, '2', 52, 'Y', 'Y'),
  (2403, 'PROJECT_MNPW_REG', 'PROJECT', 2400, '등록', '/biz/mnpwSave.ajax', 'REG', NULL, '2', 53, 'Y', 'Y'),
  (2404, 'PROJECT_MNPW_MDFCN', 'PROJECT', 2400, '수정', '/biz/mnpwSave.ajax', 'MDFCN', NULL, '2', 54, 'Y', 'Y'),
  (2405, 'PROJECT_MNPW_DEL', 'PROJECT', 2400, '삭제', '/biz/mnpwDelete.ajax', 'DEL', NULL, '2', 55, 'Y', 'Y'),
  (2500, 'PROJECT_PROCESS', 'PROJECT', NULL, '프로세스 관리', NULL, 'GROUP', 'fa-list-check', '1', 60, 'Y', 'N'),
  (2501, 'PROJECT_PROCESS_SCREEN', 'PROJECT', 2500, '화면', '/biz/schdlList.do', 'SCREEN', NULL, '2', 61, 'Y', 'Y'),
  (2502, 'PROJECT_PROCESS_LIST', 'PROJECT', 2500, '조회', '/biz/schdlList.ajax', 'LIST', NULL, '2', 62, 'Y', 'Y'),
  (2503, 'PROJECT_PROCESS_REG', 'PROJECT', 2500, '등록', '/biz/schdlSave.ajax', 'REG', NULL, '2', 63, 'Y', 'Y'),
  (2504, 'PROJECT_PROCESS_MDFCN', 'PROJECT', 2500, '수정', '/biz/schdlSave.ajax', 'MDFCN', NULL, '2', 64, 'Y', 'Y'),
  (2505, 'PROJECT_PROCESS_DEL', 'PROJECT', 2500, '삭제', '/biz/schdlDelete.ajax', 'DEL', NULL, '2', 65, 'Y', 'Y'),

  (3000, 'ORG_DASHBOARD', 'ORG', NULL, '조직 대시보드', NULL, 'GROUP', 'fa-sitemap', '1', 10, 'Y', 'N'),
  (3001, 'ORG_DASHBOARD_SCREEN', 'ORG', 3000, '화면', '/main/main.do', 'SCREEN', NULL, '2', 11, 'Y', 'Y'),

  (4000, 'MANAGEMENT_DASHBOARD', 'MANAGEMENT', NULL, '경영 대시보드', NULL, 'GROUP', 'fa-chart-line', '1', 10, 'Y', 'N'),
  (4001, 'MANAGEMENT_DASHBOARD_SCREEN', 'MANAGEMENT', 4000, '화면', '/main/main.do', 'SCREEN', NULL, '2', 11, 'Y', 'Y'),
  (4100, 'MANAGEMENT_ORG', 'MANAGEMENT', NULL, '조직 관리', NULL, 'GROUP', 'fa-sitemap', '1', 20, 'Y', 'N'),
  (4101, 'MANAGEMENT_ORG_SCREEN', 'MANAGEMENT', 4100, '화면', '/dept/orgList.do', 'SCREEN', NULL, '2', 21, 'Y', 'Y'),
  (4102, 'MANAGEMENT_ORG_LIST', 'MANAGEMENT', 4100, '조회', '/dept/organizationData.ajax', 'LIST', NULL, '2', 22, 'Y', 'Y'),
  (4103, 'MANAGEMENT_ORG_REG', 'MANAGEMENT', 4100, '등록', '/dept/insertDept.ajax', 'REG', NULL, '2', 23, 'Y', 'Y'),
  (4104, 'MANAGEMENT_ORG_MDFCN', 'MANAGEMENT', 4100, '수정', '/dept/updateDept.ajax', 'MDFCN', NULL, '2', 24, 'Y', 'Y'),
  (4105, 'MANAGEMENT_ORG_DEL', 'MANAGEMENT', 4100, '삭제', '/dept/deleteDept.ajax', 'DEL', NULL, '2', 25, 'Y', 'Y'),
  (4106, 'MANAGEMENT_ORG_TREE', 'MANAGEMENT', 4100, '조직 트리 조회', '/dept/selectDeptTreeList.ajax', 'LIST', NULL, '2', 26, 'Y', 'Y'),
  (4107, 'MANAGEMENT_ORG_DETAIL', 'MANAGEMENT', 4100, '조직 상세 조회', '/dept/selectDeptDetail.ajax', 'DETAIL', NULL, '2', 27, 'Y', 'Y'),
  (4200, 'MANAGEMENT_USER', 'MANAGEMENT', NULL, '사용자 관리', NULL, 'GROUP', 'fa-user-gear', '1', 30, 'Y', 'N'),
  (4201, 'MANAGEMENT_USER_SCREEN', 'MANAGEMENT', 4200, '목록 화면', '/user/empList.do', 'SCREEN', NULL, '2', 31, 'Y', 'Y'),
  (4202, 'MANAGEMENT_USER_LIST', 'MANAGEMENT', 4200, '목록', '/user/empList.ajax', 'LIST', NULL, '2', 32, 'Y', 'Y'),
  (4203, 'MANAGEMENT_USER_DETAIL', 'MANAGEMENT', 4200, '상세', '/user/empDetail.ajax', 'DETAIL', NULL, '2', 33, 'Y', 'Y'),
  (4204, 'MANAGEMENT_USER_REG_SCREEN', 'MANAGEMENT', 4200, '등록 화면', '/user/empInsert.do', 'SCREEN', NULL, '2', 34, 'Y', 'Y'),
  (4205, 'MANAGEMENT_USER_REG', 'MANAGEMENT', 4200, '등록', '/user/empSave.ajax', 'REG', NULL, '2', 35, 'Y', 'Y'),
  (4206, 'MANAGEMENT_USER_MDFCN_SCREEN', 'MANAGEMENT', 4200, '수정 화면', '/user/empUpdate.do', 'SCREEN', NULL, '2', 36, 'Y', 'Y'),
  (4207, 'MANAGEMENT_USER_MDFCN', 'MANAGEMENT', 4200, '수정', '/user/empSave.ajax', 'MDFCN', NULL, '2', 37, 'Y', 'Y'),
  (4208, 'MANAGEMENT_USER_DEL', 'MANAGEMENT', 4200, '삭제', '/user/empDelete.ajax', 'DEL', NULL, '2', 38, 'Y', 'Y'),
  (4209, 'MANAGEMENT_USER_META', 'MANAGEMENT', 4200, '기준정보 조회', '/user/empMeta.ajax', 'LIST', NULL, '2', 39, 'Y', 'Y'),
  (4210, 'MANAGEMENT_USER_ID_CHECK', 'MANAGEMENT', 4200, '아이디 중복확인', '/user/empIdCheck.ajax', 'LIST', NULL, '2', 40, 'Y', 'Y'),
  (4211, 'MANAGEMENT_USER_LEGACY_REG', 'MANAGEMENT', 4200, '기존 사용자 등록 API', '/user/insertUser.ajax', 'REG', NULL, '2', 41, 'Y', 'Y'),
  (4212, 'MANAGEMENT_USER_LEGACY_MDFCN', 'MANAGEMENT', 4200, '기존 사용자 수정 API', '/user/userUpdate.ajax', 'MDFCN', NULL, '2', 42, 'Y', 'Y'),
  (4213, 'MANAGEMENT_USER_LEGACY_DEL', 'MANAGEMENT', 4200, '기존 사용자 삭제 API', '/user/userDelete.ajax', 'DEL', NULL, '2', 43, 'Y', 'Y'),
  (4300, 'MANAGEMENT_AUTHRT', 'MANAGEMENT', NULL, '역할·권한 관리', NULL, 'GROUP', 'fa-shield-halved', '1', 40, 'Y', 'N'),
  (4301, 'MANAGEMENT_AUTHRT_SCREEN', 'MANAGEMENT', 4300, '화면', '/authority/authorityManage.do', 'SCREEN', NULL, '2', 41, 'Y', 'Y'),
  (4302, 'MANAGEMENT_AUTHRT_LIST', 'MANAGEMENT', 4300, '조회', '/authority/authorityData.ajax', 'LIST', NULL, '2', 42, 'Y', 'Y'),
  (4303, 'MANAGEMENT_AUTHRT_REG', 'MANAGEMENT', 4300, '등록', '/authority/authorityInsert.ajax', 'REG', NULL, '2', 43, 'Y', 'Y'),
  (4304, 'MANAGEMENT_AUTHRT_MDFCN', 'MANAGEMENT', 4300, '수정', '/authority/authorityUpdate.ajax', 'MDFCN', NULL, '2', 44, 'Y', 'Y'),
  (4305, 'MANAGEMENT_AUTHRT_DEL', 'MANAGEMENT', 4300, '삭제', '/authority/authorityDelete.ajax', 'DEL', NULL, '2', 45, 'Y', 'Y'),
  (4306, 'MANAGEMENT_AUTHRT_SAVE', 'MANAGEMENT', 4300, '권한 저장', '/authority/authoritySave.ajax', 'MDFCN', NULL, '2', 46, 'Y', 'Y')
ON DUPLICATE KEY UPDATE
  WORKSPC_ID = VALUES(WORKSPC_ID),
  UP_MENU_SN = VALUES(UP_MENU_SN),
  MENU_NM = VALUES(MENU_NM),
  MENU_URL_ADDR = VALUES(MENU_URL_ADDR),
  MENU_TYPE_NM = VALUES(MENU_TYPE_NM),
  MENU_ICON_NM = VALUES(MENU_ICON_NM),
  MENU_LV = VALUES(MENU_LV),
  MENU_SORT_SEQ = VALUES(MENU_SORT_SEQ),
  MENU_USE_YN = VALUES(MENU_USE_YN),
  AUTHRT_CHK_YN = VALUES(AUTHRT_CHK_YN),
  MDFCN_DT = current_timestamp();

INSERT INTO user_workspc_rel (USER_ID, WORKSPC_ID, DFLT_YN, USE_YN, RGTR_ID)
SELECT USER_ID, 'WORK', 'Y', 'Y', 'SYSTEM'
FROM user_info
WHERE USE_YN = 'Y'
ON DUPLICATE KEY UPDATE USE_YN = 'Y';

/* 최고관리자는 전체 기능을 사용한다. */
INSERT INTO authrt_menu_rel (AUTHRT_ID, MENU_SN, AUTHRT_GRNT_YN, RGTR_ID)
SELECT 'ADMIN', M.MENU_SN, 'Y', 'SYSTEM'
FROM menu_info M
WHERE M.MENU_USE_YN = 'Y'
ON DUPLICATE KEY UPDATE AUTHRT_GRNT_YN = 'Y';

/* 관리자는 개인·프로젝트·조직·경영 조회/업무 기능을 사용하되 최고관리자 설정은 제외한다. */
INSERT INTO authrt_menu_rel (AUTHRT_ID, MENU_SN, AUTHRT_GRNT_YN, RGTR_ID)
SELECT 'MANAGER', M.MENU_SN, 'Y', 'SYSTEM'
FROM menu_info M
WHERE M.MENU_USE_YN = 'Y'
  AND M.MENU_CD NOT LIKE 'MANAGEMENT_ORG%'
  AND M.MENU_CD NOT LIKE 'MANAGEMENT_USER%'
  AND M.MENU_CD NOT LIKE 'MANAGEMENT_AUTHRT%'
ON DUPLICATE KEY UPDATE AUTHRT_GRNT_YN = 'Y';

/* 일반 사용자는 본인 일정과 기본 대시보드만 사용한다. */
INSERT INTO authrt_menu_rel (AUTHRT_ID, MENU_SN, AUTHRT_GRNT_YN, RGTR_ID)
SELECT 'USER', M.MENU_SN, 'Y', 'SYSTEM'
FROM menu_info M
WHERE M.MENU_CD LIKE 'WORK_%'
ON DUPLICATE KEY UPDATE AUTHRT_GRNT_YN = 'Y';
