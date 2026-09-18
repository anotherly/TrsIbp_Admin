-- 일정 캘린더 코드/기존 오류 데이터 보정
-- 프로젝트/재택은 캘린더 직접 등록 대상에서 제외하고, 기존 값은 기타로 이관한다.

UPDATE cmn_cd
   SET USE_YN = 'N'
 WHERE CD_GROUP_ID = 'CAL_SCHDL_SE_CD'
   AND CD IN ('PROJECT', 'HOME', 'REMOTE', 'BTRP', 'MEET');

UPDATE cmn_cd
   SET USE_YN = 'Y'
 WHERE CD_GROUP_ID = 'CAL_SCHDL_SE_CD'
   AND CD IN ('VAC', 'BIZTRIP', 'OUTSIDE', 'MEETING', 'ETC');

UPDATE schdl_info
   SET SCHDL_SE_CD = 'ETC'
 WHERE SCHDL_SE_CD IN ('PROJECT', 'HOME', 'REMOTE')
   AND USE_YN = 'Y';

UPDATE schdl_info
   SET SCHDL_SE_CD = 'BIZTRIP'
 WHERE SCHDL_SE_CD = 'BTRP';

UPDATE schdl_info
   SET SCHDL_SE_CD = 'MEETING'
 WHERE SCHDL_SE_CD = 'MEET';

-- 잘못 저장된 시작/종료 역전 데이터는 화면/검증 오류 방지를 위해 시작일 + 1시간으로 보정한다.
UPDATE schdl_info
   SET END_DT = DATE_ADD(BGNG_DT, INTERVAL 1 HOUR)
 WHERE END_DT <= BGNG_DT;
