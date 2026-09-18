-- --------------------------------------------------------
-- 호스트:                          127.0.0.1
-- 서버 버전:                        10.6.4-MariaDB - mariadb.org binary distribution
-- 서버 OS:                        Win64
-- HeidiSQL 버전:                  11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- trs_ibp 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `trs_ibp` /*!40100 DEFAULT CHARACTER SET utf8mb3 */;
USE `trs_ibp`;

-- 테이블 trs_ibp.authrt_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `authrt_info` (
  `AUTHRT_ID` varchar(20) NOT NULL COMMENT '권한ID',
  `AUTHRT_NM` varchar(50) NOT NULL COMMENT '권한명',
  `AUTHRT_EXPLN` varchar(200) DEFAULT NULL COMMENT '권한설명',
  `SORT_SEQ` int(11) DEFAULT 0 COMMENT '정렬순서',
  PRIMARY KEY (`AUTHRT_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='권한정보';

-- 테이블 데이터 trs_ibp.authrt_info:~3 rows (대략적) 내보내기
DELETE FROM `authrt_info`;
/*!40000 ALTER TABLE `authrt_info` DISABLE KEYS */;
INSERT INTO `authrt_info` (`AUTHRT_ID`, `AUTHRT_NM`, `AUTHRT_EXPLN`, `SORT_SEQ`) VALUES
	('ADMIN', '최고관리자', '프로젝트 개발자. 전체 시스템 최고 권한', 1),
	('MANAGER', '관리자', '경영/회계팀, 팀장/본부장/대표. 팀원 관리 권한', 2),
	('USER', '사용자', '일반 회사원. 본인 일정/연차 조회 및 출근 기록', 3);
/*!40000 ALTER TABLE `authrt_info` ENABLE KEYS */;

-- 테이블 trs_ibp.cmn_cd_group 구조 내보내기
CREATE TABLE IF NOT EXISTS `cmn_cd_group` (
  `CD_GROUP_ID` varchar(50) NOT NULL COMMENT '코드그룹ID',
  `CD_GROUP_NM` varchar(100) NOT NULL COMMENT '코드그룹명',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `SORT_SEQ` int(11) DEFAULT 0 COMMENT '정렬순서',
  `RMRK_CN` varchar(500) DEFAULT NULL COMMENT '비고내용',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`CD_GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='공통코드그룹';

-- 테이블 trs_ibp.cmn_cd 구조 내보내기
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

DELETE FROM `cmn_cd`;
DELETE FROM `cmn_cd_group`;
/*!40000 ALTER TABLE `cmn_cd_group` DISABLE KEYS */;
INSERT INTO `cmn_cd_group` (`CD_GROUP_ID`, `CD_GROUP_NM`, `USE_YN`, `SORT_SEQ`, `RMRK_CN`) VALUES
	('BIZ_STTS_CD', '사업상태코드', 'Y', 10, '사업 진행 상태'),
	('INST_SE_CD', '기관구분코드', 'Y', 20, '공공/민간 기관 구분'),
	('BIZ_KND_CD', '사업종류코드', 'Y', 30, 'SI, SM, 연구개발 등 사업 종류'),
	('BIZ_SE_CD', '사업구분코드', 'Y', 40, '최초개발, 유지보수, 고도화 등 사업 성격'),
	('POWK_SE_CD', '근무장소구분코드', 'Y', 50, '본사, 재택, 외근, 상주 등 근무 장소');
/*!40000 ALTER TABLE `cmn_cd_group` ENABLE KEYS */;
/*!40000 ALTER TABLE `cmn_cd` DISABLE KEYS */;
INSERT INTO `cmn_cd` (`CD_GROUP_ID`, `CD`, `CD_NM`, `CD_EXPLN`, `SORT_SEQ`, `DFLT_YN`, `USE_YN`) VALUES
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
/*!40000 ALTER TABLE `cmn_cd` ENABLE KEYS */;

-- 테이블 trs_ibp.biz_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `biz_info` (
  `BIZ_ID` varchar(20) NOT NULL COMMENT '사업ID',
  `CO_ID` varchar(20) NOT NULL COMMENT '회사ID',
  `BIZ_CD` varchar(30) NOT NULL COMMENT '사업코드',
  `BIZ_NM` varchar(100) NOT NULL COMMENT '사업명',
  `INST_SE_CD` varchar(10) DEFAULT NULL COMMENT '기관구분코드',
  `BIZ_KND_CD` varchar(10) DEFAULT NULL COMMENT '사업종류코드',
  `BIZ_SE_CD` varchar(20) DEFAULT NULL COMMENT '사업구분코드',
  `ORDPL_NM` varchar(100) DEFAULT NULL COMMENT '발주처명',
  `CTRT_YMD` date DEFAULT NULL COMMENT '계약일자',
  `OTST_YMD` date DEFAULT NULL COMMENT '착수일자',
  `BIZ_END_YMD` date DEFAULT NULL COMMENT '사업종료일자',
  `CTRT_AMT` decimal(15,0) DEFAULT NULL COMMENT '계약금액',
  `GIVE_MTHD_CN` varchar(1000) DEFAULT NULL COMMENT '지급방법내용',
  `GIVE_DDT_YMD` date DEFAULT NULL COMMENT '지급기일일자',
  `DFRP_GRNTE_BGNG_YMD` date DEFAULT NULL COMMENT '하자보수보증시작일자',
  `DFRP_GRNTE_END_YMD` date DEFAULT NULL COMMENT '하자보수보증종료일자',
  `RMRK_CN` varchar(4000) DEFAULT NULL COMMENT '비고내용',
  `BIZ_STTS_CD` varchar(10) DEFAULT 'READY' COMMENT '사업상태코드',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`BIZ_ID`),
  UNIQUE KEY `UK_BIZ_INFO_BIZ_CD` (`BIZ_CD`),
  KEY `IDX_BIZ_CO_ID` (`CO_ID`),
  KEY `IDX_BIZ_INFO_ORDPL_NM` (`ORDPL_NM`),
  KEY `IDX_BIZ_INFO_OTST_END` (`OTST_YMD`,`BIZ_END_YMD`),
  CONSTRAINT `FK_BIZ_CO` FOREIGN KEY (`CO_ID`) REFERENCES `co_info` (`CO_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사업정보';

-- 테이블 데이터 trs_ibp.biz_info:~0 rows (대략적) 내보내기
DELETE FROM `biz_info`;
/*!40000 ALTER TABLE `biz_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_info` ENABLE KEYS */;

-- 테이블 trs_ibp.biz_stp_task 구조 내보내기
CREATE TABLE IF NOT EXISTS `biz_stp_task` (
  `TASK_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '업무일련번호',
  `BIZ_ID` varchar(20) NOT NULL COMMENT '사업ID',
  `STP_CD` varchar(10) NOT NULL COMMENT '단계코드',
  `TASK_NM` varchar(200) NOT NULL COMMENT '업무명',
  `PIC_ID` varchar(50) DEFAULT NULL COMMENT '담당자ID',
  `OUTPUT_FILE_NM` varchar(255) DEFAULT NULL COMMENT '산출물파일명',
  `OUTPUT_FILE_PATH_NM` varchar(500) DEFAULT NULL COMMENT '산출물파일경로명',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`TASK_SN`),
  KEY `IDX_BIZ_STP_TASK_BIZ_ID` (`BIZ_ID`),
  KEY `IDX_BIZ_STP_TASK_PIC_ID` (`PIC_ID`),
  CONSTRAINT `FK_BIZ_STP_TASK_BIZ` FOREIGN KEY (`BIZ_ID`) REFERENCES `biz_info` (`BIZ_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_BIZ_STP_TASK_PIC` FOREIGN KEY (`PIC_ID`) REFERENCES `user_info` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사업단계업무';

-- 테이블 데이터 trs_ibp.biz_stp_task:~0 rows (대략적) 내보내기
DELETE FROM `biz_stp_task`;
/*!40000 ALTER TABLE `biz_stp_task` DISABLE KEYS */;
/*!40000 ALTER TABLE `biz_stp_task` ENABLE KEYS */;

-- 테이블 trs_ibp.co_aply_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `co_aply_info` (
  `APLY_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '신청일련번호',
  `CO_NM` varchar(100) NOT NULL COMMENT '회사명',
  `BRNO` varchar(20) NOT NULL COMMENT '사업자등록번호',
  `APLCNT_NM` varchar(50) NOT NULL COMMENT '신청자명',
  `RPRSV_NM` varchar(50) NOT NULL COMMENT '대표자명',
  `PIC_TELNO` varchar(20) NOT NULL COMMENT '담당자전화번호',
  `PIC_EML_ADDR` varchar(100) NOT NULL COMMENT '담당자이메일주소',
  `ORGNL_FILE_NM` varchar(255) DEFAULT NULL COMMENT '원본파일명',
  `ENCPT_FILE_NM` varchar(255) DEFAULT NULL COMMENT '암호화파일명',
  `FILE_PATH_NM` varchar(500) DEFAULT NULL COMMENT '파일경로명',
  `PRCS_STTS_CD` varchar(10) DEFAULT 'WAIT' COMMENT '처리상태코드',
  `RJCT_RSN` varchar(500) DEFAULT NULL COMMENT '반려사유',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `PRCS_DT` datetime DEFAULT NULL COMMENT '처리일시',
  PRIMARY KEY (`APLY_SN`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COMMENT='회사신청정보';

-- 테이블 데이터 trs_ibp.co_aply_info:~4 rows (대략적) 내보내기
DELETE FROM `co_aply_info`;
/*!40000 ALTER TABLE `co_aply_info` DISABLE KEYS */;
INSERT INTO `co_aply_info` (`APLY_SN`, `CO_NM`, `BRNO`, `APLCNT_NM`, `RPRSV_NM`, `PIC_TELNO`, `PIC_EML_ADDR`, `ORGNL_FILE_NM`, `ENCPT_FILE_NM`, `FILE_PATH_NM`, `PRCS_STTS_CD`, `RJCT_RSN`, `REG_DT`, `PRCS_DT`) VALUES
	(3, '쓰리알솔루션', '8548603728', '정다빈', '여혜진', '01051856132', 'jdb910624@gmail.com', 'KakaoTalk_20260529_152048364.png', 'f88b5b5c-4f6c-4384-9dde-74c9639f03fd.png', 'C:/trsStorage/request_biz/', 'WAIT', NULL, '2026-05-29 18:11:55', NULL),
	(4, '삼알솔루션', '123456789012', '가나다', '라마바', '01012341234', 'asdfdsfsfsdaaaaaaaaaaaaaaaaaaaaa@gmaaaaaaaaail.com', 'KakaoTalk_20260529_152031363.png', '7e117204-9ac7-463b-b118-d539c34ba555.png', 'C:/trsStorage/request_biz/', 'WAIT', NULL, '2026-06-01 17:56:36', NULL),
	(5, '삼양솔루션', 'ㅁㄴㅇㄹㄴㅇㄻㄴㅇㄹㅇㄴ', '김가나', '다라마', '01023232345', 'sadfasdf@gmaaaill.com', 'KakaoTalk_20260529_152031363.png', '3fee10f6-f109-4762-852c-27b86abc4329.png', 'C:/trsStorage/request_biz/', 'WAIT', NULL, '2026-06-01 18:00:33', NULL),
	(6, '3알솔루션', '123456789012', '홍길동', '이길여', '01012341234', 'asfdsad@gmail.com', 'KakaoTalk_20260508_152731540.png', '30d14c30-26c0-4cba-9613-eaa04973c79b.png', 'C:/trsStorage/request_biz/', 'WAIT', NULL, '2026-06-04 17:10:12', NULL);
/*!40000 ALTER TABLE `co_aply_info` ENABLE KEYS */;

-- 테이블 trs_ibp.co_data_file 구조 내보내기
CREATE TABLE IF NOT EXISTS `co_data_file` (
  `FILE_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '파일일련번호',
  `DATA_SN` int(11) NOT NULL COMMENT '자료일련번호',
  `ORGNL_FILE_NM` varchar(255) NOT NULL COMMENT '원본파일명',
  `ENCPT_FILE_NM` varchar(255) NOT NULL COMMENT '암호화파일명',
  `FILE_PATH_NM` varchar(500) NOT NULL COMMENT '파일경로명',
  `FILE_SZ` bigint(20) NOT NULL COMMENT '파일크기',
  `FILE_EXTN_NM` varchar(10) NOT NULL COMMENT '파일확장자명',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`FILE_SN`),
  KEY `IDX_CO_DATA_FILE_DATA_SN` (`DATA_SN`),
  CONSTRAINT `FK_CO_DATA_FILE_DATA` FOREIGN KEY (`DATA_SN`) REFERENCES `co_data_mng` (`DATA_SN`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='회사자료파일';

-- 테이블 데이터 trs_ibp.co_data_file:~0 rows (대략적) 내보내기
DELETE FROM `co_data_file`;
/*!40000 ALTER TABLE `co_data_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `co_data_file` ENABLE KEYS */;

-- 테이블 trs_ibp.co_data_mng 구조 내보내기
CREATE TABLE IF NOT EXISTS `co_data_mng` (
  `DATA_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '자료일련번호',
  `CO_ID` varchar(20) NOT NULL COMMENT '회사ID',
  `DATA_SE_CD` varchar(50) NOT NULL COMMENT '자료구분코드',
  `DATA_NM` varchar(100) NOT NULL COMMENT '자료명',
  `MNG_PIC_ID` varchar(50) NOT NULL COMMENT '관리담당자ID',
  `EXPRY_YMD` date DEFAULT NULL COMMENT '만료일자',
  `ALRM_SNDNG_YN` char(1) DEFAULT 'N' COMMENT '알림발송여부',
  `RGTR_ID` varchar(50) NOT NULL COMMENT '등록자아이디',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`DATA_SN`),
  KEY `IDX_CO_DATA_MNG_CO_ID` (`CO_ID`),
  KEY `IDX_CO_DATA_MNG_MNG_PIC_ID` (`MNG_PIC_ID`),
  CONSTRAINT `FK_CO_DATA_MNG_CO` FOREIGN KEY (`CO_ID`) REFERENCES `co_info` (`CO_ID`),
  CONSTRAINT `FK_CO_DATA_MNG_PIC` FOREIGN KEY (`MNG_PIC_ID`) REFERENCES `user_info` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='회사자료관리';

-- 테이블 데이터 trs_ibp.co_data_mng:~0 rows (대략적) 내보내기
DELETE FROM `co_data_mng`;
/*!40000 ALTER TABLE `co_data_mng` DISABLE KEYS */;
/*!40000 ALTER TABLE `co_data_mng` ENABLE KEYS */;

-- 테이블 trs_ibp.co_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `co_info` (
  `CO_ID` varchar(20) NOT NULL COMMENT '회사ID',
  `CO_NM` varchar(100) NOT NULL COMMENT '회사명',
  `CO_TELNO` varchar(20) DEFAULT NULL COMMENT '회사전화번호',
  `CO_ADDR` varchar(200) DEFAULT NULL COMMENT '회사주소',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`CO_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='회사정보';

-- 테이블 데이터 trs_ibp.co_info:~0 rows (대략적) 내보내기
DELETE FROM `co_info`;
/*!40000 ALTER TABLE `co_info` DISABLE KEYS */;
INSERT INTO `co_info` (`CO_ID`, `CO_NM`, `CO_TELNO`, `CO_ADDR`, `USE_YN`, `REG_DT`) VALUES
	('COMP001', '쓰리알솔루션', NULL, NULL, 'Y', '2026-05-28 16:13:07');
/*!40000 ALTER TABLE `co_info` ENABLE KEYS */;

-- 테이블 trs_ibp.co_ip_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `co_ip_info` (
  `IP_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT 'IP일련번호',
  `CO_ID` varchar(20) NOT NULL COMMENT '회사ID',
  `PRM_IP_ADDR` varchar(50) NOT NULL COMMENT '허용IP주소',
  `IP_EXPLN` varchar(100) DEFAULT NULL COMMENT 'IP설명',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`IP_SN`),
  KEY `IDX_CO_IP_CO_ID` (`CO_ID`),
  CONSTRAINT `FK_CO_IP_CO` FOREIGN KEY (`CO_ID`) REFERENCES `co_info` (`CO_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='회사IP정보';

-- 테이블 데이터 trs_ibp.co_ip_info:~0 rows (대략적) 내보내기
DELETE FROM `co_ip_info`;
/*!40000 ALTER TABLE `co_ip_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `co_ip_info` ENABLE KEYS */;

-- 테이블 trs_ibp.dept_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `dept_info` (
  `DEPT_ID` varchar(20) NOT NULL COMMENT '부서ID',
  `CO_ID` varchar(20) NOT NULL COMMENT '회사ID',
  `DEPT_NM` varchar(100) NOT NULL COMMENT '부서명',
  `UP_DEPT_ID` varchar(20) DEFAULT NULL COMMENT '상위부서ID',
  `DEPT_SE_CD` varchar(10) NOT NULL DEFAULT 'DEPT' COMMENT '조직구분코드(HQ/DEPT/TEAM)',
  `DEPT_EXPLN` varchar(500) DEFAULT NULL COMMENT '조직설명',
  `MNGR_USER_ID` varchar(50) DEFAULT NULL COMMENT '조직장사용자ID',
  `SORT_SEQ` int(11) DEFAULT 0 COMMENT '정렬순서',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`DEPT_ID`),
  KEY `IDX_DEPT_CO_ID` (`CO_ID`),
  KEY `IDX_DEPT_UP_DEPT_ID` (`UP_DEPT_ID`),
  KEY `IDX_DEPT_MNGR_USER_ID` (`MNGR_USER_ID`),
  CONSTRAINT `FK_DEPT_CO` FOREIGN KEY (`CO_ID`) REFERENCES `co_info` (`CO_ID`),
  CONSTRAINT `FK_DEPT_UP_DEPT` FOREIGN KEY (`UP_DEPT_ID`) REFERENCES `dept_info` (`DEPT_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='부서정보';

-- 테이블 데이터 trs_ibp.dept_info:~6 rows (대략적) 내보내기
DELETE FROM `dept_info`;
/*!40000 ALTER TABLE `dept_info` DISABLE KEYS */;
INSERT INTO `dept_info` (`DEPT_ID`, `CO_ID`, `DEPT_NM`, `UP_DEPT_ID`, `DEPT_SE_CD`, `SORT_SEQ`, `USE_YN`, `REG_DT`) VALUES
	('DEPT001', 'COMP001', '경영지원본부', NULL, 'HQ', 1, 'Y', '2026-05-28 16:13:07'),
	('DEPT002', 'COMP001', '1개발본부', NULL, 'HQ', 2, 'Y', '2026-05-28 16:13:07'),
	('DEPT003', 'COMP001', '인사팀', 'DEPT001', 'TEAM', 1, 'Y', '2026-05-28 16:13:07'),
	('DEPT004', 'COMP001', '재무팀', 'DEPT001', 'TEAM', 2, 'Y', '2026-05-28 16:13:07'),
	('DEPT005', 'COMP001', 'WEB팀', 'DEPT002', 'TEAM', 1, 'Y', '2026-05-28 16:13:07'),
	('DEPT006', 'COMP001', 'APP팀', 'DEPT002', 'TEAM', 2, 'Y', '2026-05-28 16:13:07');
/*!40000 ALTER TABLE `dept_info` ENABLE KEYS */;

-- 테이블 trs_ibp.insd_eml 구조 내보내기
CREATE TABLE IF NOT EXISTS `insd_eml` (
  `EML_SN` int(11) NOT NULL AUTO_INCREMENT COMMENT '이메일일련번호',
  `SNDR_ID` varchar(50) NOT NULL COMMENT '발송자ID',
  `RCVR_ID` varchar(50) NOT NULL COMMENT '수신자ID',
  `TTL` varchar(200) NOT NULL COMMENT '제목',
  `CN` text NOT NULL COMMENT '내용',
  `PRSL_YN` char(1) DEFAULT 'N' COMMENT '열람여부',
  `DSPTCH_DT` datetime DEFAULT current_timestamp() COMMENT '발신일시',
  PRIMARY KEY (`EML_SN`),
  KEY `IDX_INSD_EML_SNDR_ID` (`SNDR_ID`),
  KEY `IDX_INSD_EML_RCVR_ID` (`RCVR_ID`),
  CONSTRAINT `FK_INSD_EML_RCVR` FOREIGN KEY (`RCVR_ID`) REFERENCES `user_info` (`USER_ID`),
  CONSTRAINT `FK_INSD_EML_SNDR` FOREIGN KEY (`SNDR_ID`) REFERENCES `user_info` (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='내부이메일';

-- 테이블 데이터 trs_ibp.insd_eml:~0 rows (대략적) 내보내기
DELETE FROM `insd_eml`;
/*!40000 ALTER TABLE `insd_eml` DISABLE KEYS */;
/*!40000 ALTER TABLE `insd_eml` ENABLE KEYS */;

-- 테이블 trs_ibp.user_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `user_info` (
  `USER_ID` varchar(50) NOT NULL COMMENT '사용자아이디',
  `USER_ENPSWD` varchar(200) NOT NULL COMMENT '사용자암호화비밀번호',
  `USER_NM` varchar(100) NOT NULL COMMENT '사용자명',
  `CO_ID` varchar(20) DEFAULT NULL COMMENT '회사ID',
  `DEPT_ID` varchar(20) DEFAULT NULL COMMENT '부서ID',
  `JBPS_NM` varchar(50) DEFAULT NULL COMMENT '직위명',
  `AUTHRT_ID` varchar(20) DEFAULT NULL COMMENT '권한ID',
  `USER_TELNO` varchar(20) DEFAULT NULL COMMENT '사용자전화번호',
  `EXT_NO` varchar(20) DEFAULT NULL COMMENT '내선번호',
  `USE_YN` char(1) NOT NULL DEFAULT 'Y' COMMENT '사용여부',
  `MEMO_CN` varchar(500) DEFAULT NULL COMMENT '메모내용',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  PRIMARY KEY (`USER_ID`),
  KEY `IDX_USER_CO_ID` (`CO_ID`),
  KEY `IDX_USER_DEPT_ID` (`DEPT_ID`),
  KEY `IDX_USER_AUTHRT_ID` (`AUTHRT_ID`),
  CONSTRAINT `FK_USER_AUTHRT` FOREIGN KEY (`AUTHRT_ID`) REFERENCES `authrt_info` (`AUTHRT_ID`),
  CONSTRAINT `FK_USER_CO` FOREIGN KEY (`CO_ID`) REFERENCES `co_info` (`CO_ID`),
  CONSTRAINT `FK_USER_DEPT` FOREIGN KEY (`DEPT_ID`) REFERENCES `dept_info` (`DEPT_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자정보';

-- 테이블 데이터 trs_ibp.user_info:~4 rows (대략적) 내보내기
DELETE FROM `user_info`;
/*!40000 ALTER TABLE `user_info` DISABLE KEYS */;
INSERT INTO `user_info` (`USER_ID`, `USER_ENPSWD`, `USER_NM`, `CO_ID`, `DEPT_ID`, `JBPS_NM`, `AUTHRT_ID`, `USER_TELNO`, `EXT_NO`, `USE_YN`, `MEMO_CN`, `REG_DT`) VALUES
	('admin1', '$2a$10$4YOHWXdXXeG85cM9g9MC7OWrDuNe96UjHqY5MlsMIlz6voySqYXZm', '시스템관리자', 'COMP001', 'DEPT001', '대표', 'ADMIN', NULL, NULL, 'Y', '초기 관리자 계정 (비밀번호: admin1234)', '2026-05-28 16:13:07'),
	('user1', '$2a$10$27riaQHvKqTfNgWJ315DGurSjBgNavHE33DJtnVMgNoq2LR9F/MPG', '가나다', 'COMP001', 'DEPT001', '대리', 'USER', '01012341234', NULL, 'Y', NULL, '2026-06-01 16:31:57'),
	('user123', '$2a$10$R85TzfyPoz4regLwhs8IMOoxKHth2Qu4nrVle/I7fpHLYypxX.Jt6', '가나다12345678901234567', 'COMP001', 'DEPT001', '대리', 'USER', '01012341234', NULL, 'Y', NULL, '2026-06-01 17:30:23'),
	('user12345', '$2a$10$I0.wjj.UQO7pjv0fIjcwGeIndUfNJb1brY75QbTNBYx1djYCnj.qm', '김과나', 'COMP001', 'DEPT005', '대리', 'USER', '01012341234', NULL, 'Y', NULL, '2026-06-04 16:30:49');
/*!40000 ALTER TABLE `user_info` ENABLE KEYS */;

-- 테이블 trs_ibp.work_hstry 구조 내보내기
CREATE TABLE IF NOT EXISTS `work_hstry` (
  `WORK_HSTRY_SN` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '근무이력일련번호',
  `USER_ID` varchar(50) NOT NULL COMMENT '사용자아이디',
  `WORK_YMD` date NOT NULL COMMENT '근무일자',
  `GTWK_DT` datetime DEFAULT NULL COMMENT '출근일시',
  `LVWK_DT` datetime DEFAULT NULL COMMENT '퇴근일시',
  `POWK_SE_CD` varchar(20) DEFAULT 'OFFICE' COMMENT '근무장소구분코드',
  `WORK_RMRK_CN` varchar(500) DEFAULT NULL COMMENT '근무비고내용',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `MDFCN_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `GTWK_CNTN_IP_ADDR` varchar(50) DEFAULT NULL COMMENT '출근접속IP주소',
  `LVWK_CNTN_IP_ADDR` varchar(50) DEFAULT NULL COMMENT '퇴근접속IP주소',
  PRIMARY KEY (`WORK_HSTRY_SN`),
  UNIQUE KEY `UQ_WORK_USER_YMD` (`USER_ID`,`WORK_YMD`),
  KEY `IDX_WORK_YMD` (`WORK_YMD`),
  CONSTRAINT `FK_WORK_USER` FOREIGN KEY (`USER_ID`) REFERENCES `user_info` (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COMMENT='근무이력';

-- 테이블 데이터 trs_ibp.work_hstry:~9 rows (대략적) 내보내기
DELETE FROM `work_hstry`;
/*!40000 ALTER TABLE `work_hstry` DISABLE KEYS */;
INSERT INTO `work_hstry` (`WORK_HSTRY_SN`, `USER_ID`, `WORK_YMD`, `GTWK_DT`, `LVWK_DT`, `POWK_SE_CD`, `WORK_RMRK_CN`, `REG_DT`, `MDFCN_DT`, `GTWK_CNTN_IP_ADDR`, `LVWK_CNTN_IP_ADDR`) VALUES
	(3, 'admin1', '2026-05-29', '2026-05-29 14:29:34', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-05-29 14:29:34', NULL, NULL, NULL),
	(4, 'admin1', '2026-06-01', '2026-06-01 10:23:37', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-06-01 10:23:37', NULL, NULL, NULL),
	(5, 'user1', '2026-06-01', '2026-06-01 16:32:04', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-06-01 16:32:04', NULL, NULL, NULL),
	(6, 'admin1', '2026-06-02', '2026-06-02 16:00:58', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-06-02 16:00:58', NULL, NULL, NULL),
	(7, 'admin1', '2026-06-04', '2026-06-04 15:41:40', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-06-04 15:41:40', NULL, NULL, NULL),
	(8, 'user12345', '2026-06-04', '2026-06-04 16:31:03', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-06-04 16:31:03', NULL, NULL, NULL),
	(9, 'user12345', '2026-06-05', '2026-06-05 15:51:38', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-06-05 15:51:38', NULL, NULL, NULL),
	(10, 'user12345', '2026-06-22', '2026-06-22 11:15:06', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-06-22 11:15:06', NULL, NULL, NULL),
	(11, 'admin1', '2026-06-29', '2026-06-29 10:12:25', NULL, 'OFFICE', '로그인 시 시스템 자동 출근 처리', '2026-06-29 10:12:25', NULL, NULL, NULL);
/*!40000 ALTER TABLE `work_hstry` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
