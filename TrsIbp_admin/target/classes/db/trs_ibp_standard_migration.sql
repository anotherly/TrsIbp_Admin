-- ============================================================
-- TRS_IBP 공공데이터 공통표준 반영 마이그레이션
-- 기준: 공공데이터 공통표준(2025.11월)
-- 적용 대상:
--   1. biz_step_task.STEP_CD -> biz_stp_task.STP_CD
--   2. intrnl_mail.READ_YN -> insd_eml.PRSL_YN
--   3. MAIL_SN -> EML_SN
--   4. biz_info 계약/발주/지급/하자보수보증 컬럼 추가
--   5. 공통코드 테이블 추가 및 CASE 하드코딩 제거 기반 구성
--   6. work_hstry.POWK_NM -> POWK_SE_CD
-- ============================================================

CREATE TABLE IF NOT EXISTS `cmn_cd_group` (
  `CD_GROUP_ID` varchar(50) NOT NULL COMMENT '코드그룹ID',
  `CD_GROUP_NM` varchar(100) NOT NULL COMMENT '코드그룹명',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `SORT_SEQ` int(11) DEFAULT 0 COMMENT '정렬순서',
  `RMRK_CN` varchar(500) DEFAULT NULL COMMENT '비고내용',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`CD_GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='공통코드그룹';

CREATE TABLE IF NOT EXISTS `cmn_cd` (
  `CD_GROUP_ID` varchar(50) NOT NULL COMMENT '코드그룹ID',
  `CD` varchar(30) NOT NULL COMMENT '코드',
  `CD_NM` varchar(100) NOT NULL COMMENT '코드명',
  `CD_EXPLN` varchar(500) DEFAULT NULL COMMENT '코드설명',
  `SORT_SEQ` int(11) DEFAULT 0 COMMENT '정렬순서',
  `DFLT_YN` char(1) NOT NULL DEFAULT 'N' COMMENT '기본여부',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `RMRK_CN` varchar(500) DEFAULT NULL COMMENT '비고내용',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`CD_GROUP_ID`, `CD`),
  KEY `IDX_CMN_CD_GROUP_SORT` (`CD_GROUP_ID`, `SORT_SEQ`),
  CONSTRAINT `FK_CMN_CD_GROUP` FOREIGN KEY (`CD_GROUP_ID`) REFERENCES `cmn_cd_group` (`CD_GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='공통코드';

INSERT IGNORE INTO `cmn_cd_group` (`CD_GROUP_ID`, `CD_GROUP_NM`, `USE_YN`, `SORT_SEQ`, `RMRK_CN`) VALUES
	('BIZ_STTS_CD', '사업상태코드', 'Y', 10, '사업 진행 상태'),
	('INST_SE_CD', '기관구분코드', 'Y', 20, '공공/민간 기관 구분'),
	('BIZ_KND_CD', '사업종류코드', 'Y', 30, 'SI, SM, 연구개발 등 사업 종류'),
	('BIZ_SE_CD', '사업구분코드', 'Y', 40, '최초개발, 유지보수, 고도화 등 사업 성격'),
	('POWK_SE_CD', '근무장소구분코드', 'Y', 50, '본사, 재택, 외근, 상주 등 근무 장소');

INSERT IGNORE INTO `cmn_cd` (`CD_GROUP_ID`, `CD`, `CD_NM`, `CD_EXPLN`, `SORT_SEQ`, `DFLT_YN`, `USE_YN`) VALUES
	('BIZ_STTS_CD', 'READY', '준비', '사업 착수 전 준비 상태', 10, 'Y', 'Y'),
	('BIZ_STTS_CD', 'PRGRS', '진행', '사업 진행 중 상태', 20, 'N', 'Y'),
	('BIZ_STTS_CD', 'CMPTN', '완료', '사업 완료 상태', 30, 'N', 'Y'),
	('BIZ_STTS_CD', 'HOLD', '보류', '사업 보류 상태', 40, 'N', 'Y'),
	('BIZ_STTS_CD', 'CANCEL', '취소', '사업 취소 상태', 50, 'N', 'Y'),
	('INST_SE_CD', 'PBL', '공공', '공공기관 발주 사업', 10, 'Y', 'Y'),
	('INST_SE_CD', 'PRIVT', '민간', '민간기관 발주 사업', 20, 'N', 'Y'),
	('BIZ_KND_CD', 'SI', 'SI', '시스템 구축 사업', 10, 'Y', 'Y'),
	('BIZ_KND_CD', 'SM', 'SM', '운영 및 유지관리 사업', 20, 'N', 'Y'),
	('BIZ_KND_CD', 'RND', '연구개발', '연구개발 사업', 30, 'N', 'Y'),
	('BIZ_KND_CD', 'ETC', '기타', '기타 사업 종류', 90, 'N', 'Y'),
	('BIZ_SE_CD', 'NEW_DVLP', '최초개발', '신규 개발 사업', 10, 'Y', 'Y'),
	('BIZ_SE_CD', 'MNTC', '유지보수', '유지보수 사업', 20, 'N', 'Y'),
	('BIZ_SE_CD', 'ENHNC', '고도화', '고도화 사업', 30, 'N', 'Y'),
	('BIZ_SE_CD', 'IMPRV', '기능개선', '기능개선 사업', 40, 'N', 'Y'),
	('BIZ_SE_CD', 'ETC', '기타', '기타 사업 구분', 90, 'N', 'Y'),
	('POWK_SE_CD', 'OFFICE', '본사', '본사 근무', 10, 'Y', 'Y'),
	('POWK_SE_CD', 'HOME', '재택', '재택 근무', 20, 'N', 'Y'),
	('POWK_SE_CD', 'OUTSIDE', '외근', '외근 또는 출장', 30, 'N', 'Y'),
	('POWK_SE_CD', 'CLIENT', '상주', '고객사 상주', 40, 'N', 'Y');

ALTER TABLE `work_hstry`
    CHANGE COLUMN `POWK_NM` `POWK_SE_CD` varchar(20) DEFAULT 'OFFICE' COMMENT '근무장소구분코드';

ALTER TABLE `biz_info`
    ADD COLUMN `BIZ_CD` varchar(30) NULL COMMENT '사업코드' AFTER `CO_ID`,
    ADD COLUMN `INST_SE_CD` varchar(10) NULL COMMENT '기관구분코드' AFTER `BIZ_NM`,
    ADD COLUMN `BIZ_KND_CD` varchar(10) NULL COMMENT '사업종류코드' AFTER `INST_SE_CD`,
    ADD COLUMN `BIZ_SE_CD` varchar(20) NULL COMMENT '사업구분코드' AFTER `BIZ_KND_CD`,
    ADD COLUMN `ORDPL_NM` varchar(100) NULL COMMENT '발주처명' AFTER `BIZ_SE_CD`,
    ADD COLUMN `CTRT_YMD` date NULL COMMENT '계약일자' AFTER `ORDPL_NM`,
    ADD COLUMN `OTST_YMD` date NULL COMMENT '착수일자' AFTER `CTRT_YMD`,
    ADD COLUMN `CTRT_AMT` decimal(15,0) NULL COMMENT '계약금액' AFTER `BIZ_END_YMD`,
    ADD COLUMN `GIVE_MTHD_CN` varchar(1000) NULL COMMENT '지급방법내용' AFTER `CTRT_AMT`,
    ADD COLUMN `GIVE_DDT_YMD` date NULL COMMENT '지급기일일자' AFTER `GIVE_MTHD_CN`,
    ADD COLUMN `DFRP_GRNTE_BGNG_YMD` date NULL COMMENT '하자보수보증시작일자' AFTER `GIVE_DDT_YMD`,
    ADD COLUMN `DFRP_GRNTE_END_YMD` date NULL COMMENT '하자보수보증종료일자' AFTER `DFRP_GRNTE_BGNG_YMD`,
    ADD COLUMN `RMRK_CN` varchar(4000) NULL COMMENT '비고내용' AFTER `DFRP_GRNTE_END_YMD`;

UPDATE `biz_info`
SET `BIZ_CD` = `BIZ_ID`
WHERE `BIZ_CD` IS NULL OR `BIZ_CD` = '';

UPDATE `biz_info`
SET `OTST_YMD` = `BIZ_BGNG_YMD`
WHERE `OTST_YMD` IS NULL;

ALTER TABLE `biz_info`
    MODIFY COLUMN `BIZ_CD` varchar(30) NOT NULL COMMENT '사업코드',
    ADD UNIQUE KEY `UK_BIZ_INFO_BIZ_CD` (`BIZ_CD`),
    ADD KEY `IDX_BIZ_INFO_ORDPL_NM` (`ORDPL_NM`),
    ADD KEY `IDX_BIZ_INFO_OTST_END` (`OTST_YMD`, `BIZ_END_YMD`);

ALTER TABLE `biz_step_task`
    CHANGE COLUMN `STEP_CD` `STP_CD` varchar(10) NOT NULL COMMENT '단계코드';

RENAME TABLE `biz_step_task` TO `biz_stp_task`;

ALTER TABLE `biz_stp_task`
    MODIFY COLUMN `TASK_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '업무일련번호',
    MODIFY COLUMN `TASK_NM` varchar(200) NOT NULL COMMENT '업무명';

ALTER TABLE `intrnl_mail`
    CHANGE COLUMN `MAIL_SN` `EML_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '이메일일련번호',
    CHANGE COLUMN `READ_YN` `PRSL_YN` char(1) DEFAULT 'N' COMMENT '열람여부';

RENAME TABLE `intrnl_mail` TO `insd_eml`;
