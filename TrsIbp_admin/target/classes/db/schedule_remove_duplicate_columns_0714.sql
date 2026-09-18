-- 일정 테이블 중복 컬럼 정리 최종본
-- 기준 구조
--   schdl_info       : 일정 기본정보만 저장
--   schdl_user_rel   : 일정 대상자 다중 관계 저장
-- 유지 컬럼
--   BGNG_DT, END_DT, PLACE_NM
-- 제거 컬럼
--   USER_ID, SCHDL_BGNG_DT, SCHDL_END_DT, LOC_NM

DELIMITER //

DROP PROCEDURE IF EXISTS SP_SCHDL_REMOVE_DUP_COLS//
CREATE PROCEDURE SP_SCHDL_REMOVE_DUP_COLS()
BEGIN
    DECLARE v_cnt INT DEFAULT 0;

    -- 신규 기준 컬럼 보장
    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'BGNG_DT';
    IF v_cnt = 0 THEN
        ALTER TABLE schdl_info ADD COLUMN BGNG_DT DATETIME NULL COMMENT '시작일시' AFTER SCHDL_NM;
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'END_DT';
    IF v_cnt = 0 THEN
        ALTER TABLE schdl_info ADD COLUMN END_DT DATETIME NULL COMMENT '종료일시' AFTER BGNG_DT;
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'PLACE_NM';
    IF v_cnt = 0 THEN
        ALTER TABLE schdl_info ADD COLUMN PLACE_NM VARCHAR(100) NULL COMMENT '장소명' AFTER ALL_DAY_YN;
    END IF;

    -- 구 컬럼 데이터 이관
    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'SCHDL_BGNG_DT';
    IF v_cnt > 0 THEN
        UPDATE schdl_info
           SET BGNG_DT = IFNULL(BGNG_DT, SCHDL_BGNG_DT);
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'SCHDL_END_DT';
    IF v_cnt > 0 THEN
        UPDATE schdl_info
           SET END_DT = IFNULL(END_DT, SCHDL_END_DT);
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'LOC_NM';
    IF v_cnt > 0 THEN
        UPDATE schdl_info
           SET PLACE_NM = IFNULL(PLACE_NM, LOC_NM);
    END IF;

    -- 다중 대상자 관계 테이블 보장
    CREATE TABLE IF NOT EXISTS schdl_user_rel (
        SCHDL_SN BIGINT NOT NULL COMMENT '일정일련번호',
        USER_ID VARCHAR(50) NOT NULL COMMENT '사용자아이디',
        REG_DT DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
        PRIMARY KEY (SCHDL_SN, USER_ID),
        KEY IDX_SCHDL_USER_REL_USER (USER_ID),
        CONSTRAINT FK_SCHDL_USER_REL_SCHDL FOREIGN KEY (SCHDL_SN) REFERENCES schdl_info (SCHDL_SN) ON DELETE CASCADE,
        CONSTRAINT FK_SCHDL_USER_REL_USER FOREIGN KEY (USER_ID) REFERENCES user_info (USER_ID)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='일정사용자관계';

    -- 구 단일 USER_ID 값을 관계 테이블로 이관
    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'USER_ID';
    IF v_cnt > 0 THEN
        INSERT IGNORE INTO schdl_user_rel (SCHDL_SN, USER_ID, REG_DT)
        SELECT S.SCHDL_SN, S.USER_ID, IFNULL(S.REG_DT, NOW())
          FROM schdl_info S
          JOIN user_info U ON U.USER_ID = S.USER_ID
         WHERE S.USER_ID IS NOT NULL
           AND S.USER_ID <> '';
    END IF;

    -- NOT NULL 변경 전 NULL 데이터 방어
    UPDATE schdl_info
       SET BGNG_DT = IFNULL(BGNG_DT, NOW()),
           END_DT = IFNULL(END_DT, IFNULL(BGNG_DT, NOW()));

    ALTER TABLE schdl_info MODIFY COLUMN BGNG_DT DATETIME NOT NULL COMMENT '시작일시';
    ALTER TABLE schdl_info MODIFY COLUMN END_DT DATETIME NOT NULL COMMENT '종료일시';

    -- 구 FK 제거: 제공 스키마 기준 FK_SCHDL_USER
    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.TABLE_CONSTRAINTS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND CONSTRAINT_TYPE = 'FOREIGN KEY'
       AND CONSTRAINT_NAME = 'FK_SCHDL_USER';
    IF v_cnt > 0 THEN
        ALTER TABLE schdl_info DROP FOREIGN KEY FK_SCHDL_USER;
    END IF;

    -- 구 인덱스 제거
    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND INDEX_NAME = 'IDX_SCHDL_USER_DT';
    IF v_cnt > 0 THEN
        ALTER TABLE schdl_info DROP INDEX IDX_SCHDL_USER_DT;
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND INDEX_NAME = 'IDX_SCHDL_CO_DT';
    IF v_cnt > 0 THEN
        ALTER TABLE schdl_info DROP INDEX IDX_SCHDL_CO_DT;
    END IF;

    -- 구 컬럼 제거
    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'USER_ID';
    IF v_cnt > 0 THEN
        ALTER TABLE schdl_info DROP COLUMN USER_ID;
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'SCHDL_BGNG_DT';
    IF v_cnt > 0 THEN
        ALTER TABLE schdl_info DROP COLUMN SCHDL_BGNG_DT;
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'SCHDL_END_DT';
    IF v_cnt > 0 THEN
        ALTER TABLE schdl_info DROP COLUMN SCHDL_END_DT;
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND COLUMN_NAME = 'LOC_NM';
    IF v_cnt > 0 THEN
        ALTER TABLE schdl_info DROP COLUMN LOC_NM;
    END IF;

    -- 신규 기준 인덱스 보장
    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND INDEX_NAME = 'IDX_SCHDL_INFO_CO_DT';
    IF v_cnt = 0 THEN
        ALTER TABLE schdl_info ADD INDEX IDX_SCHDL_INFO_CO_DT (CO_ID, BGNG_DT, END_DT);
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA = DATABASE()
       AND TABLE_NAME = 'schdl_info'
       AND INDEX_NAME = 'IDX_SCHDL_INFO_SE';
    IF v_cnt = 0 THEN
        ALTER TABLE schdl_info ADD INDEX IDX_SCHDL_INFO_SE (SCHDL_SE_CD);
    END IF;

    -- 구 코드값 보정
    UPDATE schdl_info SET SCHDL_SE_CD = 'BIZTRIP' WHERE SCHDL_SE_CD = 'BTRP';
    UPDATE schdl_info SET SCHDL_SE_CD = 'HOME' WHERE SCHDL_SE_CD = 'REMOTE';
    UPDATE schdl_info SET SCHDL_SE_CD = 'MEETING' WHERE SCHDL_SE_CD = 'MEET';
END//

CALL SP_SCHDL_REMOVE_DUP_COLS()//
DROP PROCEDURE IF EXISTS SP_SCHDL_REMOVE_DUP_COLS//

DELIMITER ;
