/*
 * 사업 기본정보 항목 추가
 * - CTRT_NO: 계약번호(공공데이터 공통표준 '계약번호', 영문명 CTRT_NO, 번호V20 기준)
 * - BIZ_ABRV_NM: 사업약칭명(사업명 보조 표시용, 명칭 도메인)
 */
ALTER TABLE biz_info
    ADD COLUMN IF NOT EXISTS CTRT_NO VARCHAR(20) NULL COMMENT '계약번호' AFTER BIZ_CD;

ALTER TABLE biz_info
    ADD COLUMN IF NOT EXISTS BIZ_ABRV_NM VARCHAR(100) NULL COMMENT '사업약칭명' AFTER BIZ_NM;
