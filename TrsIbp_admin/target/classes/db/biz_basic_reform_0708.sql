/* =========================================================
   사업 관리 개편(6말7초 회의 기반) DB 변경
   - 지급방법을 코드/상세로 분리
   - 코드값은 공통코드로 관리
   ========================================================= */

ALTER TABLE biz_info
    ADD COLUMN IF NOT EXISTS GIVE_MTHD_CD VARCHAR(30) NULL COMMENT '지급방법코드' AFTER CTRT_AMT;

ALTER TABLE biz_info
    MODIFY COLUMN GIVE_MTHD_CN VARCHAR(1000) NULL COMMENT '지급방법상세내용';

INSERT INTO cmn_cd_group (CD_GROUP_ID, CD_GROUP_NM, USE_YN, SORT_SEQ, RMRK_CN, REG_DT)
VALUES ('GIVE_MTHD_CD', '지급방법코드', 'Y', 110, '선금, 중도금, 잔금 등 계약 지급방법', NOW())
ON DUPLICATE KEY UPDATE
    CD_GROUP_NM = VALUES(CD_GROUP_NM),
    USE_YN = VALUES(USE_YN),
    SORT_SEQ = VALUES(SORT_SEQ),
    RMRK_CN = VALUES(RMRK_CN);

INSERT INTO cmn_cd (CD_GROUP_ID, CD, CD_NM, CD_EXPLN, SORT_SEQ, DFLT_YN, USE_YN, RMRK_CN, REG_DT)
VALUES
    ('GIVE_MTHD_CD', 'ADVANCE', '선금', '계약 선금 지급', 10, 'Y', 'Y', NULL, NOW()),
    ('GIVE_MTHD_CD', 'INTERIM', '중도금', '계약 중도금 지급', 20, 'N', 'Y', NULL, NOW()),
    ('GIVE_MTHD_CD', 'BALANCE', '잔금', '계약 잔금 지급', 30, 'N', 'Y', NULL, NOW()),
    ('GIVE_MTHD_CD', 'ETC', '기타', '기타 지급방법', 90, 'N', 'Y', NULL, NOW())
ON DUPLICATE KEY UPDATE
    CD_NM = VALUES(CD_NM),
    CD_EXPLN = VALUES(CD_EXPLN),
    SORT_SEQ = VALUES(SORT_SEQ),
    DFLT_YN = VALUES(DFLT_YN),
    USE_YN = VALUES(USE_YN),
    RMRK_CN = VALUES(RMRK_CN);
