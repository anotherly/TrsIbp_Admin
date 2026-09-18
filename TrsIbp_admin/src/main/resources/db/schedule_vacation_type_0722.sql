-- ============================================================
-- 일정 휴가구분 추가
-- MariaDB 10.6 기준 / 2026-07-22 회의 반영
-- ============================================================

ALTER TABLE schdl_info
    ADD COLUMN IF NOT EXISTS VAC_SE_CD VARCHAR(20) NULL COMMENT '휴가구분코드' AFTER SCHDL_SE_CD;

-- 기존 휴가는 종일여부를 기준으로 연차/시간대 휴가로 이관한다.
UPDATE schdl_info
SET VAC_SE_CD = CASE WHEN ALL_DAY_YN = 'Y' THEN 'ANNUAL' ELSE 'HOURLY' END,
    SCHDL_NM = CASE WHEN ALL_DAY_YN = 'Y' THEN '연차' ELSE '시간대' END
WHERE SCHDL_SE_CD = 'VAC'
  AND (VAC_SE_CD IS NULL OR VAC_SE_CD = '');

-- 휴가가 아닌 일정에는 휴가구분을 남기지 않는다.
UPDATE schdl_info
SET VAC_SE_CD = NULL
WHERE SCHDL_SE_CD <> 'VAC'
  AND VAC_SE_CD IS NOT NULL;

-- 재실행해도 오류가 나지 않도록 제약조건이 없을 때만 생성한다.
SET @CHK_SCHDL_VAC_SE_EXISTS := (
    SELECT COUNT(*)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'schdl_info'
      AND CONSTRAINT_NAME = 'CHK_SCHDL_VAC_SE'
);
SET @CHK_SCHDL_VAC_SE_SQL := IF(
    @CHK_SCHDL_VAC_SE_EXISTS = 0,
    'ALTER TABLE schdl_info ADD CONSTRAINT CHK_SCHDL_VAC_SE CHECK ((SCHDL_SE_CD = ''VAC'' AND VAC_SE_CD IS NOT NULL AND ((VAC_SE_CD = ''ANNUAL'' AND ALL_DAY_YN = ''Y'') OR (VAC_SE_CD IN (''HALF'', ''HOURLY'') AND ALL_DAY_YN = ''N''))) OR (SCHDL_SE_CD <> ''VAC'' AND VAC_SE_CD IS NULL))',
    'SELECT 1'
);
PREPARE CHK_SCHDL_VAC_SE_STMT FROM @CHK_SCHDL_VAC_SE_SQL;
EXECUTE CHK_SCHDL_VAC_SE_STMT;
DEALLOCATE PREPARE CHK_SCHDL_VAC_SE_STMT;
