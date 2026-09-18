-- ============================================================
-- DevSync IT 그룹웨어 - MySQL/MariaDB DDL 스크립트
-- 작성일: 2026-05-28
-- DB명: trs_ibp
-- 설계: COMPANY_INFO > DEPT_INFO(계층) > USER_INFO > ATTEND_HISTORY
-- ============================================================

-- ============================================================
-- 0. 기존 테이블 삭제 (의존성 역순)
-- ============================================================
DROP TABLE IF EXISTS ATTEND_HISTORY;
DROP TABLE IF EXISTS USER_INFO;
DROP TABLE IF EXISTS DEPT_INFO;
DROP TABLE IF EXISTS COMPANY_INFO;
DROP TABLE IF EXISTS AUTH_INFO;

-- ============================================================
-- 1. 권한 테이블 (AUTH_INFO)
-- AUTH_ID: ADMIN(최고관리자/개발자), MANAGER(관리자), USER(일반사용자)
-- ============================================================
CREATE TABLE AUTH_INFO (
    AUTH_ID     VARCHAR(20)  NOT NULL COMMENT '권한ID (ADMIN/MANAGER/USER)',
    AUTH_NAME   VARCHAR(50)  NOT NULL COMMENT '권한명',
    AUTH_DESC   VARCHAR(200)     NULL COMMENT '권한설명',
    SORT_ORDER  INT              NULL DEFAULT 0 COMMENT '정렬순서',
    PRIMARY KEY (AUTH_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='권한 테이블';

-- ============================================================
-- 2. 회사 테이블 (COMPANY_INFO)
-- ============================================================
CREATE TABLE COMPANY_INFO (
    COMPANY_ID      VARCHAR(20)  NOT NULL COMMENT '회사ID',
    COMPANY_NAME    VARCHAR(100) NOT NULL COMMENT '회사명',
    COMPANY_TEL     VARCHAR(20)      NULL COMMENT '대표전화',
    COMPANY_ADDR    VARCHAR(200)     NULL COMMENT '주소',
    FLAG_USE        CHAR(1)      NOT NULL DEFAULT 'Y' COMMENT '사용여부(Y/N)',
    REG_DT          DATETIME         NULL DEFAULT NOW() COMMENT '등록일시',
    PRIMARY KEY (COMPANY_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='회사 테이블';

-- ============================================================
-- 3. 부서 테이블 (DEPT_INFO)
-- PARENT_DEPT_ID: 셀프조인으로 계층구조 구현
-- 예) 1본부(PARENT=NULL) > WEB팀(PARENT=1본부ID)
-- ============================================================
CREATE TABLE DEPT_INFO (
    DEPT_ID         VARCHAR(20)  NOT NULL COMMENT '부서ID',
    COMPANY_ID      VARCHAR(20)  NOT NULL COMMENT '회사ID (COMPANY_INFO.COMPANY_ID)',
    DEPT_NAME       VARCHAR(100) NOT NULL COMMENT '부서명',
    PARENT_DEPT_ID  VARCHAR(20)      NULL COMMENT '상위부서ID (셀프조인, NULL=최상위)',
    SORT_ORDER      INT              NULL DEFAULT 0 COMMENT '정렬순서',
    FLAG_USE        CHAR(1)      NOT NULL DEFAULT 'Y' COMMENT '사용여부(Y/N)',
    REG_DT          DATETIME         NULL DEFAULT NOW() COMMENT '등록일시',
    PRIMARY KEY (DEPT_ID),
    CONSTRAINT FK_DEPT_COMPANY    FOREIGN KEY (COMPANY_ID)     REFERENCES COMPANY_INFO(COMPANY_ID),
    CONSTRAINT FK_DEPT_PARENT     FOREIGN KEY (PARENT_DEPT_ID) REFERENCES DEPT_INFO(DEPT_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='부서 테이블 (계층구조 셀프조인)';

-- ============================================================
-- 4. 사용자 테이블 (USER_INFO)
-- POSITION: 대표/본부장/팀장/팀원 (직접 텍스트 입력)
-- ============================================================
CREATE TABLE USER_INFO (
    USER_ID     VARCHAR(50)  NOT NULL COMMENT '사용자ID',
    USER_PW     VARCHAR(200) NOT NULL COMMENT '비밀번호(BCrypt 해시)',
    USER_NAME   VARCHAR(100) NOT NULL COMMENT '사용자명',
    COMPANY_ID  VARCHAR(20)      NULL COMMENT '소속회사ID (COMPANY_INFO.COMPANY_ID)',
    DEPT_ID     VARCHAR(20)      NULL COMMENT '소속부서ID (DEPT_INFO.DEPT_ID)',
    POSITION    VARCHAR(50)      NULL COMMENT '직급/직책 (대표/본부장/팀장/팀원 등 자유입력)',
    AUTH_ID     VARCHAR(20)      NULL COMMENT '권한ID (AUTH_INFO.AUTH_ID)',
    USER_TEL    VARCHAR(20)      NULL COMMENT '연락처',
    IN_TEL      VARCHAR(20)      NULL COMMENT '내선번호',
    FLAG_USE    CHAR(1)      NOT NULL DEFAULT 'Y' COMMENT '사용여부(Y/N)',
    MEMO        VARCHAR(500)     NULL COMMENT '메모',
    REG_DT      DATETIME         NULL DEFAULT NOW() COMMENT '가입일시',
    PRIMARY KEY (USER_ID),
    CONSTRAINT FK_USER_COMPANY FOREIGN KEY (COMPANY_ID) REFERENCES COMPANY_INFO(COMPANY_ID),
    CONSTRAINT FK_USER_DEPT    FOREIGN KEY (DEPT_ID)    REFERENCES DEPT_INFO(DEPT_ID),
    CONSTRAINT FK_USER_AUTH    FOREIGN KEY (AUTH_ID)    REFERENCES AUTH_INFO(AUTH_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 테이블';

-- ============================================================
-- 5. 근태 이력 테이블 (ATTEND_HISTORY)
-- ============================================================
CREATE TABLE ATTEND_HISTORY (
    SEQ             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '이력번호',
    USER_ID         VARCHAR(50)  NOT NULL COMMENT '사용자ID (USER_INFO.USER_ID)',
    WORK_DT         DATE         NOT NULL COMMENT '근무일자',
    CHECK_IN_TIME   DATETIME         NULL COMMENT '출근시간',
    CHECK_OUT_TIME  DATETIME         NULL COMMENT '퇴근시간',
    WORK_LOCATION   VARCHAR(20)      NULL DEFAULT 'OFFICE' COMMENT '근무지(OFFICE/HOME/OUTSIDE)',
    WORK_MEMO       VARCHAR(500)     NULL COMMENT '비고',
    REG_DT          DATETIME         NULL DEFAULT NOW() COMMENT '등록일시',
    UPD_DT          DATETIME         NULL COMMENT '수정일시',
    PRIMARY KEY (SEQ),
    UNIQUE KEY UQ_ATTEND_USER_DT (USER_ID, WORK_DT),
    INDEX IDX_ATTEND_DT (WORK_DT),
    CONSTRAINT FK_ATTEND_USER FOREIGN KEY (USER_ID) REFERENCES USER_INFO(USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='근태 이력 테이블';

-- ============================================================
-- 6. 초기 데이터 - 권한 (AUTH_INFO)
-- ============================================================
INSERT INTO AUTH_INFO (AUTH_ID, AUTH_NAME, AUTH_DESC, SORT_ORDER) VALUES
('ADMIN',   '최고관리자', '프로젝트 개발자. 전체 시스템 최고 권한',  1),
('MANAGER', '관리자',     '경영/회계팀, 팀장/본부장/대표. 팀원 관리 권한', 2),
('USER',    '사용자',     '일반 회사원. 본인 일정/연차 조회 및 출근 기록', 3);

-- ============================================================
-- 7. 초기 데이터 - 회사 (COMPANY_INFO)
-- ============================================================
INSERT INTO COMPANY_INFO (COMPANY_ID, COMPANY_NAME, FLAG_USE) VALUES
('COMP001', 'TRSolution', 'Y');

-- ============================================================
-- 8. 초기 데이터 - 부서 (DEPT_INFO, 계층 예시)
-- ============================================================
INSERT INTO DEPT_INFO (DEPT_ID, COMPANY_ID, DEPT_NAME, PARENT_DEPT_ID, SORT_ORDER) VALUES
('DEPT001', 'COMP001', '경영지원본부', NULL,      1),
('DEPT002', 'COMP001', '1개발본부',   NULL,      2),
('DEPT003', 'COMP001', '인사팀',      'DEPT001', 1),
('DEPT004', 'COMP001', '재무팀',      'DEPT001', 2),
('DEPT005', 'COMP001', 'WEB팀',       'DEPT002', 1),
('DEPT006', 'COMP001', 'APP팀',       'DEPT002', 2);

-- ============================================================
-- 9. 초기 데이터 - 관리자 계정 (USER_INFO)
-- 비밀번호: admin1234 → BCrypt 해시
-- ============================================================
INSERT INTO USER_INFO (USER_ID, USER_PW, USER_NAME, COMPANY_ID, DEPT_ID, POSITION, AUTH_ID, FLAG_USE, MEMO)
VALUES (
    'admin',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lHmW',
    '시스템관리자',
    'COMP001',
    'DEPT001',
    '대표',
    'ADMIN',
    'Y',
    '초기 관리자 계정 (비밀번호: admin1234)'
);

-- ============================================================
-- 10. 확인 쿼리
-- ============================================================
-- SELECT * FROM AUTH_INFO;
-- SELECT * FROM COMPANY_INFO;
-- SELECT * FROM DEPT_INFO;
-- SELECT * FROM USER_INFO;
-- SHOW TABLES;
