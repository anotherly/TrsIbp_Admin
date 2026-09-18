-- ============================================================
-- DevSync 시스템관리자 사이트 DB 마이그레이션
-- 대상: MariaDB 10.6 / trs_ibp
-- 실행 전 운영 DB 백업 권장
-- ============================================================

START TRANSACTION;

-- 1. 회사 내부 관리자(ADMIN)와 구분되는 시스템관리자 권한
INSERT INTO authrt_info (
     AUTHRT_ID
    ,AUTHRT_NM
    ,AUTHRT_EXPLN
    ,SORT_SEQ
) VALUES (
     'SYS_ADMIN'
    ,'시스템관리자'
    ,'전체 서비스 운영, 기업가입 승인, 전체 기업 및 회원 관리 권한'
    ,0
)
ON DUPLICATE KEY UPDATE
     AUTHRT_NM = VALUES(AUTHRT_NM)
    ,AUTHRT_EXPLN = VALUES(AUTHRT_EXPLN)
    ,SORT_SEQ = VALUES(SORT_SEQ);

-- 2. 기업 신청 처리자 기록
ALTER TABLE co_aply_info
    ADD COLUMN IF NOT EXISTS PRCS_USER_ID VARCHAR(50) NULL
        COMMENT '처리사용자아이디' AFTER PRCS_DT;

-- 동일 신청의 중복 기업생성을 DB에서도 방지
CREATE UNIQUE INDEX IF NOT EXISTS UK_CO_INFO_APLY_SN
    ON co_info (APLY_SN);

-- 3. 시스템 로그
CREATE TABLE IF NOT EXISTS sys_log_info (
    SYS_LOG_SN       BIGINT       NOT NULL AUTO_INCREMENT COMMENT '시스템로그일련번호',
    LOG_SE_CD        VARCHAR(30)  NOT NULL COMMENT '로그구분코드',
    LOG_LEVEL_CD     VARCHAR(10)  NOT NULL COMMENT '로그등급코드',
    LOG_TITLE        VARCHAR(200) NOT NULL COMMENT '로그제목',
    LOG_CN           TEXT             NULL COMMENT '로그내용',
    USER_ID          VARCHAR(50)      NULL COMMENT '관련사용자아이디',
    REQUEST_URI      VARCHAR(500)     NULL COMMENT '요청URI',
    CLIENT_IP_ADDR   VARCHAR(50)      NULL COMMENT '클라이언트IP주소',
    REG_DT           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    PRIMARY KEY (SYS_LOG_SN),
    KEY IDX_SYS_LOG_REG_DT (REG_DT),
    KEY IDX_SYS_LOG_LEVEL (LOG_LEVEL_CD, REG_DT),
    KEY IDX_SYS_LOG_TYPE (LOG_SE_CD, REG_DT)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='시스템로그정보';

-- 4. 관리자 처리 이력
CREATE TABLE IF NOT EXISTS admin_prcs_hstry (
    ADMIN_PRCS_SN BIGINT        NOT NULL AUTO_INCREMENT COMMENT '관리자처리일련번호',
    ADMIN_ID      VARCHAR(50)   NOT NULL COMMENT '관리자아이디',
    ACTION_SE_CD  VARCHAR(50)   NOT NULL COMMENT '처리구분코드',
    TARGET_SE_CD  VARCHAR(50)   NOT NULL COMMENT '대상구분코드',
    TARGET_ID     VARCHAR(100)      NULL COMMENT '대상식별자',
    ACTION_CN     VARCHAR(1000) NOT NULL COMMENT '처리내용',
    REG_DT        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    PRIMARY KEY (ADMIN_PRCS_SN),
    KEY IDX_ADMIN_PRCS_REG_DT (REG_DT),
    KEY IDX_ADMIN_PRCS_ADMIN (ADMIN_ID, REG_DT)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='관리자처리이력';

-- 5. 운영정책
CREATE TABLE IF NOT EXISTS oper_policy (
    POLICY_ID      VARCHAR(50)   NOT NULL COMMENT '정책ID',
    POLICY_NM      VARCHAR(100)  NOT NULL COMMENT '정책명',
    POLICY_VALUE   VARCHAR(1000) NOT NULL COMMENT '정책값',
    POLICY_EXPLN   VARCHAR(500)      NULL COMMENT '정책설명',
    SORT_SEQ       INT           NOT NULL DEFAULT 0 COMMENT '정렬순서',
    MDFR_ID        VARCHAR(50)       NULL COMMENT '수정자아이디',
    MDFCN_DT       DATETIME          NULL COMMENT '수정일시',
    REG_DT         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    PRIMARY KEY (POLICY_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='운영정책';

INSERT INTO oper_policy (
     POLICY_ID, POLICY_NM, POLICY_VALUE, POLICY_EXPLN, SORT_SEQ
) VALUES
 ('COMPANY_APPROVAL_NOTICE', '기업 승인 안내문', '승인 후 기업 사용자가 회원가입을 진행할 수 있습니다.', '기업 승인 처리 후 안내할 기본 문구', 10),
 ('COMPANY_REJECT_NOTICE', '기업 반려 안내문', '신청정보를 보완한 뒤 다시 신청해 주세요.', '기업 반려 처리 후 안내할 기본 문구', 20),
 ('MAINTENANCE_NOTICE', '점검 안내문', '', '서비스 점검 시 로그인 화면 등에 표시할 안내문', 30),
 ('LOGIN_FAIL_ALERT_COUNT', '로그인 실패 경고 기준', '5', '동일 계정 로그인 실패 경고 기준 횟수', 40)
ON DUPLICATE KEY UPDATE
     POLICY_NM = VALUES(POLICY_NM)
    ,POLICY_EXPLN = VALUES(POLICY_EXPLN)
    ,SORT_SEQ = VALUES(SORT_SEQ);

-- 6. 초기 시스템관리자 계정
-- 기존 admin1의 비밀번호 해시를 복사하여 sysadmin 계정을 만든다.
-- 초기 로그인 비밀번호는 현재 admin1 계정과 동일하며 로그인 후 반드시 변경한다.
INSERT INTO user_info (
     USER_ID
    ,USER_ENPSWD
    ,USER_NM
    ,CO_ID
    ,DEPT_ID
    ,JBPS_NM
    ,AUTHRT_ID
    ,USER_TELNO
    ,USE_YN
    ,MEMO_CN
    ,REG_DT
)
SELECT
     'sysadmin'
    ,USER_ENPSWD
    ,'시스템관리자'
    ,NULL
    ,NULL
    ,'시스템관리자'
    ,'SYS_ADMIN'
    ,NULL
    ,'Y'
    ,'시스템관리자 사이트 초기 계정. 최초 로그인 후 비밀번호 변경 필요'
    ,NOW()
FROM user_info
WHERE USER_ID = 'admin1'
  AND NOT EXISTS (
      SELECT 1 FROM user_info WHERE USER_ID = 'sysadmin'
  );

COMMIT;

-- 검증
SELECT AUTHRT_ID, AUTHRT_NM FROM authrt_info WHERE AUTHRT_ID = 'SYS_ADMIN';
SELECT USER_ID, USER_NM, AUTHRT_ID, USE_YN FROM user_info WHERE USER_ID = 'sysadmin';
SHOW COLUMNS FROM co_aply_info LIKE 'PRCS_USER_ID';
SHOW TABLES LIKE 'sys_log_info';
SHOW TABLES LIKE 'admin_prcs_hstry';
SHOW TABLES LIKE 'oper_policy';
