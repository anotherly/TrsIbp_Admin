/* =====================================================================
 * TRS IBP 2026-09-18 기능확장
 * - 회사별 역할/메뉴권한
 * - 프로젝트 참여자 데이터범위와 기능권한 분리
 * - 개인카드 비용청구(즉시 프로젝트 비용 반영) + 증빙첨부
 * - 사용자 C/U/D 작업이력
 * - 개인업무(일간) -> 주간보고
 * - 회사/시스템 공지사항
 * - 사무실 자원관리/예약 + 일정 연계
 * MariaDB 10.6 기준
 * ===================================================================== */

/* 1. 회사별 역할/권한 -------------------------------------------------- */
CREATE TABLE IF NOT EXISTS co_authrt_info (
    CO_ID varchar(20) NOT NULL COMMENT '회사ID',
    AUTHRT_ID varchar(20) NOT NULL COMMENT '권한ID',
    AUTHRT_NM varchar(50) NOT NULL COMMENT '권한명',
    AUTHRT_EXPLN varchar(200) DEFAULT NULL COMMENT '권한설명',
    DATA_SCOPE_CD varchar(20) NOT NULL DEFAULT 'SELF' COMMENT '데이터범위(SELF/COMPANY)',
    SORT_SEQ int NOT NULL DEFAULT 0 COMMENT '정렬순서',
    USE_YN char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    REG_DT datetime NOT NULL DEFAULT current_timestamp(),
    MDFCN_DT datetime DEFAULT NULL,
    RGTR_ID varchar(50) DEFAULT NULL,
    MDFR_ID varchar(50) DEFAULT NULL,
    PRIMARY KEY (CO_ID, AUTHRT_ID),
    KEY IDX_CO_AUTHRT_ID (AUTHRT_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='회사별권한정보';

CREATE TABLE IF NOT EXISTS co_authrt_menu_rel (
    CO_ID varchar(20) NOT NULL COMMENT '회사ID',
    AUTHRT_ID varchar(20) NOT NULL COMMENT '권한ID',
    MENU_SN bigint NOT NULL COMMENT '메뉴일련번호',
    AUTHRT_GRNT_YN char(1) NOT NULL DEFAULT 'Y',
    REG_DT datetime NOT NULL DEFAULT current_timestamp(),
    MDFCN_DT datetime DEFAULT NULL,
    RGTR_ID varchar(50) DEFAULT NULL,
    MDFR_ID varchar(50) DEFAULT NULL,
    PRIMARY KEY (CO_ID, AUTHRT_ID, MENU_SN),
    KEY IDX_CO_AUTHRT_MENU_MENU (MENU_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='회사별권한메뉴관계';

INSERT INTO co_authrt_info (CO_ID, AUTHRT_ID, AUTHRT_NM, AUTHRT_EXPLN, DATA_SCOPE_CD, SORT_SEQ, USE_YN, RGTR_ID)
SELECT C.CO_ID, A.AUTHRT_ID, A.AUTHRT_NM, A.AUTHRT_EXPLN,
       CASE WHEN A.AUTHRT_ID IN ('ADMIN','MANAGER') THEN 'COMPANY' ELSE 'SELF' END,
       A.SORT_SEQ, 'Y', 'SYSTEM'
  FROM co_info C
 CROSS JOIN authrt_info A
 WHERE C.USE_YN = 'Y'
   AND A.AUTHRT_ID IN ('ADMIN','MANAGER','USER')
ON DUPLICATE KEY UPDATE AUTHRT_NM=VALUES(AUTHRT_NM), AUTHRT_EXPLN=VALUES(AUTHRT_EXPLN), USE_YN='Y';

INSERT INTO co_authrt_menu_rel (CO_ID, AUTHRT_ID, MENU_SN, AUTHRT_GRNT_YN, RGTR_ID)
SELECT C.CO_ID, R.AUTHRT_ID, R.MENU_SN, R.AUTHRT_GRNT_YN, 'SYSTEM'
  FROM co_info C
  JOIN authrt_menu_rel R ON R.AUTHRT_ID IN ('ADMIN','MANAGER','USER')
 WHERE C.USE_YN='Y'
ON DUPLICATE KEY UPDATE AUTHRT_GRNT_YN=VALUES(AUTHRT_GRNT_YN);

/* 대시보드는 로그인 사용자에게 무조건 개방 */
UPDATE menu_info
   SET AUTHRT_CHK_YN='N', MDFCN_DT=NOW()
 WHERE MENU_CD LIKE '%_DASHBOARD_SCREEN';

/* 2. 신규 메뉴 --------------------------------------------------------- */
INSERT INTO menu_info
(MENU_SN, MENU_CD, WORKSPC_ID, UP_MENU_SN, MENU_NM, MENU_URL_ADDR, MENU_TYPE_NM, MENU_ICON_NM, MENU_LV, MENU_SORT_SEQ, MENU_USE_YN, AUTHRT_CHK_YN)
VALUES
(1200,'WORK_EXPENSE','WORK',NULL,'비용 청구',NULL,'GROUP','fa-receipt','1',30,'Y','N'),
(1201,'WORK_EXPENSE_SCREEN','WORK',1200,'비용 청구 화면','/expense/expenseList.do','SCREEN',NULL,'2',31,'Y','Y'),
(1202,'WORK_EXPENSE_LIST','WORK',1200,'비용 청구 조회','/expense/expenseList.ajax','LIST',NULL,'2',32,'Y','Y'),
(1203,'WORK_EXPENSE_REG','WORK',1200,'비용 청구 등록','/expense/expenseSave.ajax','REG',NULL,'2',33,'Y','Y'),
(1204,'WORK_EXPENSE_MDFCN','WORK',1200,'비용 청구 수정','/expense/expenseSave.ajax','MDFCN',NULL,'2',34,'Y','Y'),
(1205,'WORK_EXPENSE_DEL','WORK',1200,'비용 청구 삭제','/expense/expenseDelete.ajax','DEL',NULL,'2',35,'Y','Y'),
(1206,'WORK_EXPENSE_FILE','WORK',1200,'비용 증빙 조회','/expense/expenseFiles.ajax','LIST',NULL,'2',36,'Y','Y'),

(1300,'WORK_DAILY','WORK',NULL,'개인업무 프로세스',NULL,'GROUP','fa-list-check','1',40,'Y','N'),
(1301,'WORK_DAILY_SCREEN','WORK',1300,'일간업무 화면','/worklog/dailyList.do','SCREEN',NULL,'2',41,'Y','Y'),
(1302,'WORK_DAILY_LIST','WORK',1300,'일간업무 조회','/worklog/dailyList.ajax','LIST',NULL,'2',42,'Y','Y'),
(1303,'WORK_DAILY_REG','WORK',1300,'일간업무 등록','/worklog/dailySave.ajax','REG',NULL,'2',43,'Y','Y'),
(1304,'WORK_DAILY_MDFCN','WORK',1300,'일간업무 수정','/worklog/dailySave.ajax','MDFCN',NULL,'2',44,'Y','Y'),
(1305,'WORK_DAILY_DEL','WORK',1300,'일간업무 삭제','/worklog/dailyDelete.ajax','DEL',NULL,'2',45,'Y','Y'),
(1306,'WORK_WEEKLY_REPORT','WORK',1300,'주간보고','/worklog/weeklyReport.do','SCREEN',NULL,'2',46,'Y','Y'),
(1307,'WORK_WEEKLY_EXCEL','WORK',1300,'주간보고 엑셀','/worklog/weeklyExcel.do','LIST',NULL,'2',47,'Y','Y'),

(1400,'WORK_NOTICE','WORK',NULL,'공지사항',NULL,'GROUP','fa-bullhorn','1',50,'Y','N'),
(1401,'WORK_NOTICE_SCREEN','WORK',1400,'공지사항 게시판','/notice/noticeList.do','SCREEN',NULL,'2',51,'Y','Y'),
(1402,'WORK_NOTICE_LIST','WORK',1400,'공지사항 조회','/notice/noticeList.ajax','LIST',NULL,'2',52,'Y','Y'),
(1403,'WORK_NOTICE_DETAIL','WORK',1400,'공지사항 상세','/notice/noticeDetail.ajax','DETAIL',NULL,'2',53,'Y','Y'),
(1404,'WORK_NOTICE_REG','WORK',1400,'회사공지 등록','/notice/noticeSave.ajax','REG',NULL,'2',54,'Y','Y'),
(1405,'WORK_NOTICE_MDFCN','WORK',1400,'회사공지 수정','/notice/noticeSave.ajax','MDFCN',NULL,'2',55,'Y','Y'),
(1406,'WORK_NOTICE_DEL','WORK',1400,'회사공지 삭제','/notice/noticeDelete.ajax','DEL',NULL,'2',56,'Y','Y'),

(1500,'WORK_RESOURCE_BOOK','WORK',NULL,'자원 예약',NULL,'GROUP','fa-calendar-check','1',60,'Y','N'),
(1501,'WORK_RESOURCE_BOOK_SCREEN','WORK',1500,'자원 예약 화면','/resource/reservationList.do','SCREEN',NULL,'2',61,'Y','Y'),
(1502,'WORK_RESOURCE_BOOK_LIST','WORK',1500,'자원 예약 조회','/resource/reservationList.ajax','LIST',NULL,'2',62,'Y','Y'),
(1503,'WORK_RESOURCE_BOOK_REG','WORK',1500,'자원 예약 등록','/resource/reservationSave.ajax','REG',NULL,'2',63,'Y','Y'),
(1504,'WORK_RESOURCE_BOOK_MDFCN','WORK',1500,'자원 예약 수정','/resource/reservationSave.ajax','MDFCN',NULL,'2',64,'Y','Y'),
(1505,'WORK_RESOURCE_BOOK_DEL','WORK',1500,'자원 예약 취소','/resource/reservationDelete.ajax','DEL',NULL,'2',65,'Y','Y'),
(1506,'WORK_RESOURCE_MASTER_LIST','WORK',1500,'예약가능 자원 조회','/resource/resourceList.ajax','LIST',NULL,'2',66,'Y','Y'),

(4400,'MANAGEMENT_RESOURCE','MANAGEMENT',NULL,'사무실 자원 관리',NULL,'GROUP','fa-boxes-stacked','1',50,'Y','N'),
(4401,'MANAGEMENT_RESOURCE_SCREEN','MANAGEMENT',4400,'자원 관리 화면','/resource/resourceManage.do','SCREEN',NULL,'2',51,'Y','Y'),
(4402,'MANAGEMENT_RESOURCE_LIST','MANAGEMENT',4400,'자원 조회','/resource/resourceList.ajax','LIST',NULL,'2',52,'Y','Y'),
(4403,'MANAGEMENT_RESOURCE_REG','MANAGEMENT',4400,'자원 등록','/resource/resourceSave.ajax','REG',NULL,'2',53,'Y','Y'),
(4404,'MANAGEMENT_RESOURCE_MDFCN','MANAGEMENT',4400,'자원 수정','/resource/resourceSave.ajax','MDFCN',NULL,'2',54,'Y','Y'),
(4405,'MANAGEMENT_RESOURCE_DEL','MANAGEMENT',4400,'자원 삭제','/resource/resourceDelete.ajax','DEL',NULL,'2',55,'Y','Y')
ON DUPLICATE KEY UPDATE MENU_NM=VALUES(MENU_NM), MENU_URL_ADDR=VALUES(MENU_URL_ADDR), MENU_TYPE_NM=VALUES(MENU_TYPE_NM), MENU_USE_YN='Y', AUTHRT_CHK_YN=VALUES(AUTHRT_CHK_YN), MDFCN_DT=NOW();

/* 기본 USER: 개인업무/공지/비용청구/자원예약 + 본인 참여 프로젝트 조회 */
INSERT INTO co_authrt_menu_rel (CO_ID, AUTHRT_ID, MENU_SN, AUTHRT_GRNT_YN, RGTR_ID)
SELECT C.CO_ID, 'USER', M.MENU_SN, 'Y', 'SYSTEM'
FROM co_info C JOIN menu_info M
  ON M.MENU_CD IN (
    'PROJECT_DASHBOARD_SCREEN','PROJECT_BIZ_LIST_SCREEN','PROJECT_BIZ_LIST','PROJECT_BIZ_DETAIL',
    'WORK_EXPENSE_SCREEN','WORK_EXPENSE_LIST','WORK_EXPENSE_REG','WORK_EXPENSE_MDFCN','WORK_EXPENSE_DEL','WORK_EXPENSE_FILE',
    'WORK_DAILY_SCREEN','WORK_DAILY_LIST','WORK_DAILY_REG','WORK_DAILY_MDFCN','WORK_DAILY_DEL','WORK_WEEKLY_REPORT','WORK_WEEKLY_EXCEL',
    'WORK_NOTICE_SCREEN','WORK_NOTICE_LIST','WORK_NOTICE_DETAIL',
    'WORK_RESOURCE_BOOK_SCREEN','WORK_RESOURCE_BOOK_LIST','WORK_RESOURCE_BOOK_REG','WORK_RESOURCE_BOOK_MDFCN','WORK_RESOURCE_BOOK_DEL','WORK_RESOURCE_MASTER_LIST')
WHERE C.USE_YN='Y'
ON DUPLICATE KEY UPDATE AUTHRT_GRNT_YN='Y';

/* MANAGER/ADMIN은 신규 기능 전체 */
INSERT INTO co_authrt_menu_rel (CO_ID, AUTHRT_ID, MENU_SN, AUTHRT_GRNT_YN, RGTR_ID)
SELECT C.CO_ID, A.AUTHRT_ID, M.MENU_SN, 'Y', 'SYSTEM'
FROM co_info C
JOIN (SELECT 'ADMIN' AUTHRT_ID UNION ALL SELECT 'MANAGER') A
JOIN menu_info M ON (M.MENU_SN BETWEEN 1200 AND 1506 OR M.MENU_SN BETWEEN 4400 AND 4405)
WHERE C.USE_YN='Y'
ON DUPLICATE KEY UPDATE AUTHRT_GRNT_YN='Y';

/* 3. 비용청구 --------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS expense_claim (
    CLAIM_SN bigint NOT NULL AUTO_INCREMENT,
    CO_ID varchar(20) NOT NULL,
    BIZ_ID varchar(20) NOT NULL,
    BIZ_CST_SN bigint NOT NULL,
    USER_ID varchar(50) NOT NULL,
    EXPNS_SE_CD varchar(30) NOT NULL COMMENT '숙박/물품/식비/교통/유류/기타',
    PMT_MTHD_CD varchar(30) NOT NULL DEFAULT 'PERSONAL_CARD' COMMENT '결제수단',
    USE_YMD date NOT NULL,
    MERCHANT_NM varchar(200) DEFAULT NULL,
    EXPNS_NM varchar(200) NOT NULL,
    CLAIM_AMT decimal(15,0) NOT NULL DEFAULT 0,
    RMRK_CN varchar(2000) DEFAULT NULL,
    STTS_CD varchar(20) NOT NULL DEFAULT 'REFLECTED' COMMENT '즉시반영',
    USE_YN char(1) NOT NULL DEFAULT 'Y',
    REG_DT datetime NOT NULL DEFAULT current_timestamp(),
    MDFCN_DT datetime DEFAULT NULL,
    RGTR_ID varchar(50) DEFAULT NULL,
    MDFR_ID varchar(50) DEFAULT NULL,
    PRIMARY KEY (CLAIM_SN),
    KEY IDX_EXPENSE_CO_USER (CO_ID, USER_ID, USE_YMD),
    KEY IDX_EXPENSE_BIZ (BIZ_ID),
    KEY IDX_EXPENSE_CST (BIZ_CST_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='개인비용청구';

/* 4. 사용자 CUD 작업이력 --------------------------------------------- */
CREATE TABLE IF NOT EXISTS user_action_log (
    ACTION_LOG_SN bigint NOT NULL AUTO_INCREMENT,
    CO_ID varchar(20) DEFAULT NULL,
    USER_ID varchar(50) NOT NULL,
    ACTION_SE_CD varchar(10) NOT NULL COMMENT 'REG/MDFCN/DEL',
    MENU_CD varchar(50) DEFAULT NULL,
    MENU_NM varchar(100) DEFAULT NULL,
    REQUEST_URI varchar(500) NOT NULL,
    TARGET_ID varchar(100) DEFAULT NULL,
    ACTION_CN varchar(1000) DEFAULT NULL,
    CLIENT_IP_ADDR varchar(100) DEFAULT NULL,
    REG_DT datetime NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (ACTION_LOG_SN),
    KEY IDX_USER_ACTION_SEARCH (CO_ID, USER_ID, ACTION_SE_CD, REG_DT),
    KEY IDX_USER_ACTION_DT (REG_DT)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자등록수정삭제작업이력';

/* 5. 개인업무프로세스 -------------------------------------------------- */
CREATE TABLE IF NOT EXISTS daily_work_item (
    WORK_ITEM_SN bigint NOT NULL AUTO_INCREMENT,
    CO_ID varchar(20) NOT NULL,
    USER_ID varchar(50) NOT NULL,
    WORK_YMD date NOT NULL,
    BIZ_ID varchar(20) DEFAULT NULL,
    PARENT_WORK_ITEM_SN bigint DEFAULT NULL,
    SORT_SEQ int NOT NULL DEFAULT 0,
    WORK_SE_CD varchar(30) DEFAULT 'TASK',
    WORK_CN varchar(4000) NOT NULL,
    PRGRS_STTS_CD varchar(20) NOT NULL DEFAULT 'WAIT' COMMENT 'WAIT/PROGRESS/DONE/CARRY',
    PRGRS_RT decimal(5,2) DEFAULT 0,
    ISSUE_CN varchar(2000) DEFAULT NULL,
    NEXT_PLAN_CN varchar(2000) DEFAULT NULL,
    USE_YN char(1) NOT NULL DEFAULT 'Y',
    REG_DT datetime NOT NULL DEFAULT current_timestamp(),
    MDFCN_DT datetime DEFAULT NULL,
    RGTR_ID varchar(50) DEFAULT NULL,
    MDFR_ID varchar(50) DEFAULT NULL,
    PRIMARY KEY (WORK_ITEM_SN),
    KEY IDX_DAILY_WORK_USER_DATE (CO_ID, USER_ID, WORK_YMD),
    KEY IDX_DAILY_WORK_BIZ (BIZ_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='개인일간업무';

/* 6. 공지사항 --------------------------------------------------------- */
CREATE TABLE IF NOT EXISTS notice_info (
    NOTICE_SN bigint NOT NULL AUTO_INCREMENT,
    NOTICE_SCOPE_CD varchar(20) NOT NULL COMMENT 'COMPANY/SYSTEM',
    CO_ID varchar(20) DEFAULT NULL COMMENT '회사공지 회사ID, 시스템공지는 NULL',
    NOTICE_TITLE varchar(300) NOT NULL,
    NOTICE_CN text NOT NULL,
    POPUP_YN char(1) NOT NULL DEFAULT 'Y',
    BGNG_DT datetime DEFAULT NULL,
    END_DT datetime DEFAULT NULL,
    USE_YN char(1) NOT NULL DEFAULT 'Y',
    REG_DT datetime NOT NULL DEFAULT current_timestamp(),
    MDFCN_DT datetime DEFAULT NULL,
    RGTR_ID varchar(50) NOT NULL,
    MDFR_ID varchar(50) DEFAULT NULL,
    PRIMARY KEY (NOTICE_SN),
    KEY IDX_NOTICE_SCOPE_CO (NOTICE_SCOPE_CD, CO_ID, USE_YN, REG_DT)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='공지사항';

/* 7. 자원관리/예약 ----------------------------------------------------- */
CREATE TABLE IF NOT EXISTS resource_info (
    RESOURCE_SN bigint NOT NULL AUTO_INCREMENT,
    CO_ID varchar(20) NOT NULL,
    RESOURCE_NM varchar(200) NOT NULL,
    RESOURCE_TYPE_CD varchar(30) NOT NULL COMMENT 'MEETING_ROOM/VEHICLE/IT_DEVICE/SERVER/ETC',
    LOCATION_NM varchar(200) DEFAULT NULL,
    RESOURCE_EXPLN varchar(2000) DEFAULT NULL,
    BOOKABLE_YN char(1) NOT NULL DEFAULT 'Y',
    USE_MODE_CD varchar(20) NOT NULL DEFAULT 'TIME' COMMENT 'TIME/LOAN/ASSIGN',
    USE_YN char(1) NOT NULL DEFAULT 'Y',
    REG_DT datetime NOT NULL DEFAULT current_timestamp(),
    MDFCN_DT datetime DEFAULT NULL,
    RGTR_ID varchar(50) DEFAULT NULL,
    MDFR_ID varchar(50) DEFAULT NULL,
    PRIMARY KEY (RESOURCE_SN),
    KEY IDX_RESOURCE_CO_TYPE (CO_ID, RESOURCE_TYPE_CD, USE_YN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사무실자원';

CREATE TABLE IF NOT EXISTS resource_attr (
    RESOURCE_ATTR_SN bigint NOT NULL AUTO_INCREMENT,
    RESOURCE_SN bigint NOT NULL,
    ATTR_NM varchar(100) NOT NULL,
    ATTR_VALUE varchar(1000) DEFAULT NULL,
    SORT_SEQ int NOT NULL DEFAULT 0,
    USE_YN char(1) NOT NULL DEFAULT 'Y',
    PRIMARY KEY (RESOURCE_ATTR_SN),
    KEY IDX_RESOURCE_ATTR_RESOURCE (RESOURCE_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='자원부가속성';

CREATE TABLE IF NOT EXISTS resource_reservation (
    RESERVATION_SN bigint NOT NULL AUTO_INCREMENT,
    RESOURCE_SN bigint NOT NULL,
    CO_ID varchar(20) NOT NULL,
    USER_ID varchar(50) NOT NULL,
    BIZ_ID varchar(20) DEFAULT NULL,
    SCHDL_SN bigint DEFAULT NULL COMMENT '캘린더연계 일정일련번호',
    RSV_TITLE varchar(300) NOT NULL,
    BGNG_DT datetime NOT NULL,
    END_DT datetime NOT NULL,
    USE_CN varchar(2000) DEFAULT NULL,
    RSV_STTS_CD varchar(20) NOT NULL DEFAULT 'RESERVED',
    USE_YN char(1) NOT NULL DEFAULT 'Y',
    REG_DT datetime NOT NULL DEFAULT current_timestamp(),
    MDFCN_DT datetime DEFAULT NULL,
    RGTR_ID varchar(50) DEFAULT NULL,
    MDFR_ID varchar(50) DEFAULT NULL,
    PRIMARY KEY (RESERVATION_SN),
    KEY IDX_RESOURCE_RSV_TIME (RESOURCE_SN, BGNG_DT, END_DT, USE_YN),
    KEY IDX_RESOURCE_RSV_USER (CO_ID, USER_ID, BGNG_DT)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='자원예약';

/* 일정구분에 자원예약 코드 보강 */
INSERT INTO cmn_cd (CD_GROUP_ID, CD, CD_NM, SORT_SEQ, USE_YN, REG_DT)
SELECT 'SCHDL_SE_CD','RESOURCE','자원예약',90,'Y',NOW()
WHERE NOT EXISTS (SELECT 1 FROM cmn_cd WHERE CD_GROUP_ID='SCHDL_SE_CD' AND CD='RESOURCE');

INSERT INTO cmn_cd (CD_GROUP_ID, CD, CD_NM, SORT_SEQ, USE_YN, REG_DT)
SELECT 'CAL_SCHDL_SE_CD','RESOURCE','자원예약',90,'Y',NOW()
WHERE NOT EXISTS (SELECT 1 FROM cmn_cd WHERE CD_GROUP_ID='CAL_SCHDL_SE_CD' AND CD='RESOURCE');
