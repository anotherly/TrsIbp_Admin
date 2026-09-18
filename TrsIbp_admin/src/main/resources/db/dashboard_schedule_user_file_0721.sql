-- ============================================================
-- 대시보드 일정연동 / 사용자 프로필·공통 첨부파일 개선
-- MariaDB 10.6 기준
-- 공공데이터 공통표준의 파일일련번호, 원본파일명, 파일경로명,
-- 파일크기, 파일확장자명, 첨부파일순서 용어를 반영한다.
-- ============================================================

CREATE TABLE IF NOT EXISTS atch_file_info (
    ATCH_FILE_SN BIGINT NOT NULL AUTO_INCREMENT COMMENT '첨부파일일련번호',
    CO_ID VARCHAR(20) NOT NULL COMMENT '회사ID',
    REF_SE_CD VARCHAR(30) NOT NULL COMMENT '참조구분코드',
    REF_ID VARCHAR(100) NOT NULL COMMENT '참조ID',
    FILE_SE_CD VARCHAR(30) NOT NULL COMMENT '파일구분코드',
    ORGNL_FILE_NM VARCHAR(255) NOT NULL COMMENT '원본파일명',
    ENCPT_FILE_NM VARCHAR(255) NOT NULL COMMENT '암호화파일명',
    FILE_PATH_NM VARCHAR(500) NOT NULL COMMENT '파일경로명',
    FILE_SZ BIGINT NOT NULL COMMENT '파일크기',
    FILE_EXTN_NM VARCHAR(20) NOT NULL COMMENT '파일확장자명',
    SORT_SEQ INT NOT NULL DEFAULT 0 COMMENT '첨부파일순서',
    USE_YN CHAR(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
    RGTR_ID VARCHAR(50) DEFAULT NULL COMMENT '등록자아이디',
    REG_DT DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
    MDFCN_DT DATETIME DEFAULT NULL COMMENT '수정일시',
    PRIMARY KEY (ATCH_FILE_SN),
    KEY IDX_ATCH_FILE_REF (CO_ID, REF_SE_CD, REF_ID, FILE_SE_CD, USE_YN),
    CONSTRAINT FK_ATCH_FILE_CO FOREIGN KEY (CO_ID) REFERENCES co_info (CO_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='첨부파일정보';

-- 재택 일정 코드는 기존 DB에 있으므로 활성 상태만 보정한다.
INSERT INTO cmn_cd (
    CD_GROUP_ID, CD, CD_NM, CD_EXPLN, SORT_SEQ, DFLT_YN, USE_YN, REG_DT
)
SELECT 'CAL_SCHDL_SE_CD', 'HOME', '재택', '재택근무 일정', 40, 'N', 'Y', NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM cmn_cd
    WHERE CD_GROUP_ID = 'CAL_SCHDL_SE_CD' AND CD = 'HOME'
);

UPDATE cmn_cd
SET CD_NM = '재택', CD_EXPLN = '재택근무 일정', SORT_SEQ = 40, USE_YN = 'Y'
WHERE CD_GROUP_ID = 'CAL_SCHDL_SE_CD' AND CD = 'HOME';

-- 근무장소 공통코드의 CLIENT와 동일한 코드값을 사용해 일정과 근태를 바로 연동한다.
INSERT INTO cmn_cd (
    CD_GROUP_ID, CD, CD_NM, CD_EXPLN, SORT_SEQ, DFLT_YN, USE_YN, REG_DT
)
SELECT 'CAL_SCHDL_SE_CD', 'CLIENT', '상주', '고객사 상주근무 일정', 45, 'N', 'Y', NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM cmn_cd
    WHERE CD_GROUP_ID = 'CAL_SCHDL_SE_CD' AND CD = 'CLIENT'
);

UPDATE cmn_cd
SET CD_NM = '상주', CD_EXPLN = '고객사 상주근무 일정', SORT_SEQ = 45, USE_YN = 'Y'
WHERE CD_GROUP_ID = 'CAL_SCHDL_SE_CD' AND CD = 'CLIENT';
