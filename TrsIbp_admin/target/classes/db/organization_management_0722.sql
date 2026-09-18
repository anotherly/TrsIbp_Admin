/*
 * 조직 관리 기능 적용 SQL
 * 적용 대상: 기존 dept_info 테이블이 설치된 TRS_IBP DB
 * 적용 순서: 애플리케이션 배포 전에 1회 실행
 */

USE `trs_ibp`;

SET @se_col_exists = (
    SELECT COUNT(1)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'dept_info'
      AND COLUMN_NAME = 'DEPT_SE_CD'
);

ALTER TABLE `dept_info`
    ADD COLUMN IF NOT EXISTS `DEPT_SE_CD` varchar(10) NOT NULL DEFAULT 'DEPT'
        COMMENT '조직구분코드(HQ/DEPT/TEAM)' AFTER `UP_DEPT_ID`,
    ADD COLUMN IF NOT EXISTS `DEPT_EXPLN` varchar(500) DEFAULT NULL
        COMMENT '조직설명' AFTER `DEPT_SE_CD`,
    ADD COLUMN IF NOT EXISTS `MNGR_USER_ID` varchar(50) DEFAULT NULL
        COMMENT '조직장사용자ID' AFTER `DEPT_EXPLN`;

/* 컬럼을 이번에 처음 추가한 경우에만 기존 최상위 조직=본부, 하위 조직=팀으로 이관한다. */
SET @sql = IF(@se_col_exists = 0,
    'UPDATE dept_info SET DEPT_SE_CD = CASE WHEN UP_DEPT_ID IS NULL THEN ''HQ'' ELSE ''TEAM'' END',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

/* 이미 존재하는 인덱스 환경에서는 중복 오류가 나지 않도록 존재 여부를 확인해 생성한다. */
SET @idx_exists = (
    SELECT COUNT(1)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'dept_info'
      AND INDEX_NAME = 'IDX_DEPT_MNGR_USER_ID'
);
SET @sql = IF(@idx_exists = 0,
    'ALTER TABLE dept_info ADD INDEX IDX_DEPT_MNGR_USER_ID (MNGR_USER_ID)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
