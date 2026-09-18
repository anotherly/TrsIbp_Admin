/*
 * 사업관리 2.x 기능 추가 DDL
 * - 공공데이터 공통표준 용어 기준으로 명, 코드, 일자, 금액, 내용, 여부, 순서 계열 컬럼명을 사용한다.
 * - 코드값은 cmn_cd/cmn_cd_group 공통코드로 관리한다.
 * - 인건비는 biz_mnpw.INPUT_MCNT * biz_mnpw.UNTPRC로 계산하고, biz_cst에는 직접비만 저장한다.
 */

USE `trs_ibp`;

INSERT INTO cmn_cd_group (CD_GROUP_ID, CD_GROUP_NM, USE_YN, SORT_SEQ, RMRK_CN, REG_DT)
VALUES
    ('BIZ_STTS_CD', '사업상태코드', 'Y', 10, '사업 진행 상태', NOW()),
    ('INST_SE_CD', '기관구분코드', 'Y', 20, '공공/민간 기관 구분', NOW()),
    ('BIZ_KND_CD', '사업종류코드', 'Y', 30, 'SI, SM, 연구개발 등 사업 종류', NOW()),
    ('BIZ_SE_CD', '사업구분코드', 'Y', 40, '최초개발, 유지보수, 고도화 등 사업 성격', NOW()),
    ('CUST_SE_CD', '고객구분코드', 'Y', 60, '공공/민간 고객사 구분', NOW()),
    ('REL_SE_CD', '계약관계구분코드', 'Y', 70, '최종사용자, 1차계약자, 하도급, 우리회사 등 계약관계', NOW()),
    ('INPUT_SE_CD', '투입구분코드', 'Y', 80, '정/부/계약직/외주 등 투입 형태', NOW()),
    ('CST_SE_CD', '비용구분코드', 'Y', 90, '출장비, 숙박비, 식대, 회의비 등 직접비 구분', NOW()),
    ('SCHDL_SE_CD', '일정구분코드', 'Y', 100, '사전작업, 수주, 종료, 유지보수 등 프로세스 일정', NOW())
ON DUPLICATE KEY UPDATE
    CD_GROUP_NM = VALUES(CD_GROUP_NM),
    USE_YN = VALUES(USE_YN),
    SORT_SEQ = VALUES(SORT_SEQ),
    RMRK_CN = VALUES(RMRK_CN);

INSERT INTO cmn_cd (CD_GROUP_ID, CD, CD_NM, CD_EXPLN, SORT_SEQ, DFLT_YN, USE_YN, REG_DT)
VALUES
    ('CUST_SE_CD', 'PBL', '공공', '공공기관/공공 발주처', 10, 'Y', 'Y', NOW()),
    ('CUST_SE_CD', 'PRIVT', '민간', '민간기업/민간 발주처', 20, 'N', 'Y', NOW()),
    ('REL_SE_CD', 'END_USER', '최종사용자(갑)', '실제 수요기관 또는 최종 사용자', 10, 'Y', 'Y', NOW()),
    ('REL_SE_CD', 'PRIME_CTRTR', '1차계약자(을)', '최종사용자와 직접 계약한 원도급사', 20, 'N', 'Y', NOW()),
    ('REL_SE_CD', 'SUB_CTRTR', '하도급', '하도급 또는 하도급 N차 수행사', 30, 'N', 'Y', NOW()),
    ('REL_SE_CD', 'OUR_CO', '우리회사', '당사 계약/수행 위치', 40, 'N', 'Y', NOW()),
    ('REL_SE_CD', 'ETC', '기타', '기타 계약 관계자', 90, 'N', 'Y', NOW()),
    ('INPUT_SE_CD', 'MAIN', '정', '주 투입 인력', 10, 'Y', 'Y', NOW()),
    ('INPUT_SE_CD', 'SUB', '부', '보조 투입 인력', 20, 'N', 'Y', NOW()),
    ('INPUT_SE_CD', 'CNTR', '계약직', '계약직 투입 인력', 30, 'N', 'Y', NOW()),
    ('INPUT_SE_CD', 'OUTSRC', '외주', '외주 또는 협력업체 인력', 40, 'N', 'Y', NOW()),
    ('INPUT_SE_CD', 'ETC', '기타', '기타 투입 형태', 90, 'N', 'Y', NOW()),
    ('CST_SE_CD', 'TRVL', '출장비', '출장 교통/일비 등', 10, 'Y', 'Y', NOW()),
    ('CST_SE_CD', 'LODG', '숙박비', '출장/현장 숙박비', 20, 'N', 'Y', NOW()),
    ('CST_SE_CD', 'MEAL', '식대', '식대', 30, 'N', 'Y', NOW()),
    ('CST_SE_CD', 'MEET', '회의비', '회의비', 40, 'N', 'Y', NOW()),
    ('CST_SE_CD', 'MTRL', '재료비', '장비/재료 구매비', 50, 'N', 'Y', NOW()),
    ('CST_SE_CD', 'ETC', '기타', '기타 직접비', 90, 'N', 'Y', NOW()),
    ('SCHDL_SE_CD', 'PRE', '사전작업', '제안/분석/착수 전 준비', 10, 'Y', 'Y', NOW()),
    ('SCHDL_SE_CD', 'ORDER', '수주', '계약/수주 이후 주요 수행', 20, 'N', 'Y', NOW()),
    ('SCHDL_SE_CD', 'END', '종료', '납품/검수/완료', 30, 'N', 'Y', NOW()),
    ('SCHDL_SE_CD', 'FREE_MAINT', '무상유지보수', '무상 유지보수 기간 작업', 40, 'N', 'Y', NOW()),
    ('SCHDL_SE_CD', 'PAID_MAINT', '유상유지보수', '유상 유지보수 기간 작업', 50, 'N', 'Y', NOW()),
    ('SCHDL_SE_CD', 'ETC', '기타', '기타 일정', 90, 'N', 'Y', NOW())
ON DUPLICATE KEY UPDATE
    CD_NM = VALUES(CD_NM),
    CD_EXPLN = VALUES(CD_EXPLN),
    SORT_SEQ = VALUES(SORT_SEQ),
    DFLT_YN = VALUES(DFLT_YN),
    USE_YN = VALUES(USE_YN);

CREATE TABLE IF NOT EXISTS `cust_info` (
  `CUST_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '고객일련번호',
  `CO_ID` varchar(20) NOT NULL COMMENT '회사ID',
  `CUST_CO_NM` varchar(100) NOT NULL COMMENT '고객회사명',
  `CUST_SE_CD` varchar(30) DEFAULT NULL COMMENT '고객구분코드',
  `BRNO` varchar(20) DEFAULT NULL COMMENT '사업자등록번호',
  `RPRSV_NM` varchar(50) DEFAULT NULL COMMENT '대표자명',
  `TELNO` varchar(20) DEFAULT NULL COMMENT '전화번호',
  `ADDR` varchar(300) DEFAULT NULL COMMENT '주소',
  `DADDR` varchar(300) DEFAULT NULL COMMENT '상세주소',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `RGTR_ID` varchar(50) DEFAULT NULL COMMENT '등록자ID',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `MDFR_ID` varchar(50) DEFAULT NULL COMMENT '수정자ID',
  `MDFCN_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`CUST_SN`),
  KEY `IDX_CUST_INFO_CO_ID` (`CO_ID`),
  KEY `IDX_CUST_INFO_NM` (`CUST_CO_NM`),
  CONSTRAINT `FK_CUST_INFO_CO` FOREIGN KEY (`CO_ID`) REFERENCES `co_info` (`CO_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='고객정보';

CREATE TABLE IF NOT EXISTS `biz_cust_rel` (
  `BIZ_CUST_REL_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '사업고객관계일련번호',
  `BIZ_ID` varchar(20) NOT NULL COMMENT '사업ID',
  `CUST_SN` int(11) NOT NULL COMMENT '고객일련번호',
  `REL_SE_CD` varchar(30) NOT NULL COMMENT '관계구분코드',
  `REL_LVL` int(11) DEFAULT NULL COMMENT '관계레벨',
  `SORT_SEQ` int(11) DEFAULT 0 COMMENT '정렬순서',
  `DIRECT_CTRT_YN` char(1) NOT NULL DEFAULT 'N' COMMENT '직접계약여부',
  `OUR_CO_YN` char(1) NOT NULL DEFAULT 'N' COMMENT '자사회사여부',
  `RMRK_CN` varchar(4000) DEFAULT NULL COMMENT '비고내용',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `RGTR_ID` varchar(50) DEFAULT NULL COMMENT '등록자ID',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `MDFR_ID` varchar(50) DEFAULT NULL COMMENT '수정자ID',
  `MDFCN_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`BIZ_CUST_REL_SN`),
  KEY `IDX_BIZ_CUST_REL_BIZ` (`BIZ_ID`),
  KEY `IDX_BIZ_CUST_REL_CUST` (`CUST_SN`),
  CONSTRAINT `FK_BIZ_CUST_REL_BIZ` FOREIGN KEY (`BIZ_ID`) REFERENCES `biz_info` (`BIZ_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_BIZ_CUST_REL_CUST` FOREIGN KEY (`CUST_SN`) REFERENCES `cust_info` (`CUST_SN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사업고객관계';

CREATE TABLE IF NOT EXISTS `biz_mnpw` (
  `BIZ_MNPW_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '사업투입인력일련번호',
  `BIZ_ID` varchar(20) NOT NULL COMMENT '사업ID',
  `USER_ID` varchar(50) DEFAULT NULL COMMENT '사용자ID',
  `INPUT_MNPW_NM` varchar(50) NOT NULL COMMENT '투입인력명',
  `INPUT_SE_CD` varchar(30) DEFAULT NULL COMMENT '투입구분코드',
  `ROLE_NM` varchar(100) DEFAULT NULL COMMENT '역할명',
  `JBPS_NM` varchar(50) DEFAULT NULL COMMENT '직위명',
  `INPUT_BGNG_YMD` date DEFAULT NULL COMMENT '투입시작일자',
  `INPUT_END_YMD` date DEFAULT NULL COMMENT '투입종료일자',
  `INPUT_MCNT` decimal(6,2) DEFAULT 0.00 COMMENT '투입월수',
  `UNTPRC` decimal(15,0) DEFAULT 0 COMMENT '단가',
  `RMRK_CN` varchar(4000) DEFAULT NULL COMMENT '비고내용',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `RGTR_ID` varchar(50) DEFAULT NULL COMMENT '등록자ID',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `MDFR_ID` varchar(50) DEFAULT NULL COMMENT '수정자ID',
  `MDFCN_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`BIZ_MNPW_SN`),
  KEY `IDX_BIZ_MNPW_BIZ` (`BIZ_ID`),
  KEY `IDX_BIZ_MNPW_USER` (`USER_ID`),
  CONSTRAINT `FK_BIZ_MNPW_BIZ` FOREIGN KEY (`BIZ_ID`) REFERENCES `biz_info` (`BIZ_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_BIZ_MNPW_USER` FOREIGN KEY (`USER_ID`) REFERENCES `user_info` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사업투입인력';

CREATE TABLE IF NOT EXISTS `biz_cst` (
  `BIZ_CST_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '사업비용일련번호',
  `BIZ_ID` varchar(20) NOT NULL COMMENT '사업ID',
  `CST_SE_CD` varchar(30) NOT NULL COMMENT '비용구분코드',
  `CST_NM` varchar(100) NOT NULL COMMENT '비용명',
  `OCRN_CST` decimal(15,0) DEFAULT 0 COMMENT '발생비용',
  `OCRN_YMD` date DEFAULT NULL COMMENT '발생일자',
  `RMRK_CN` varchar(4000) DEFAULT NULL COMMENT '비고내용',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `RGTR_ID` varchar(50) DEFAULT NULL COMMENT '등록자ID',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `MDFR_ID` varchar(50) DEFAULT NULL COMMENT '수정자ID',
  `MDFCN_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`BIZ_CST_SN`),
  KEY `IDX_BIZ_CST_BIZ` (`BIZ_ID`),
  KEY `IDX_BIZ_CST_OCRN_YMD` (`OCRN_YMD`),
  CONSTRAINT `FK_BIZ_CST_BIZ` FOREIGN KEY (`BIZ_ID`) REFERENCES `biz_info` (`BIZ_ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사업비용';

CREATE TABLE IF NOT EXISTS `biz_schdl` (
  `BIZ_SCHDL_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '사업일정일련번호',
  `BIZ_ID` varchar(20) NOT NULL COMMENT '사업ID',
  `SCHDL_SE_CD` varchar(30) NOT NULL COMMENT '일정구분코드',
  `SCHDL_NM` varchar(200) NOT NULL COMMENT '일정명',
  `SCHDL_CN` varchar(4000) DEFAULT NULL COMMENT '일정내용',
  `SCHDL_BGNG_YMD` date DEFAULT NULL COMMENT '일정시작일자',
  `SCHDL_END_YMD` date DEFAULT NULL COMMENT '일정종료일자',
  `PIC_ID` varchar(50) DEFAULT NULL COMMENT '담당자ID',
  `RMRK_CN` varchar(4000) DEFAULT NULL COMMENT '비고내용',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `RGTR_ID` varchar(50) DEFAULT NULL COMMENT '등록자ID',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `MDFR_ID` varchar(50) DEFAULT NULL COMMENT '수정자ID',
  `MDFCN_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`BIZ_SCHDL_SN`),
  KEY `IDX_BIZ_SCHDL_BIZ` (`BIZ_ID`),
  KEY `IDX_BIZ_SCHDL_PERIOD` (`SCHDL_BGNG_YMD`, `SCHDL_END_YMD`),
  CONSTRAINT `FK_BIZ_SCHDL_BIZ` FOREIGN KEY (`BIZ_ID`) REFERENCES `biz_info` (`BIZ_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_BIZ_SCHDL_PIC` FOREIGN KEY (`PIC_ID`) REFERENCES `user_info` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사업일정';
