/*
 * 사업 계약관계 불필요 컬럼 제거
 * - 정렬은 SORT_SEQ가 아니라 REL_LVL, BIZ_CUST_REL_SN 기준으로 처리한다.
 * - OUR_CO_YN은 화면/업무 로직에서 사용하지 않으므로 제거한다.
 */

DROP INDEX IF EXISTS IDX_BIZ_CUST_REL_BIZ ON biz_cust_rel;

ALTER TABLE biz_cust_rel
    DROP COLUMN IF EXISTS SORT_SEQ;

ALTER TABLE biz_cust_rel
    DROP COLUMN IF EXISTS OUR_CO_YN;

CREATE INDEX IF NOT EXISTS IDX_BIZ_CUST_REL_BIZ
    ON biz_cust_rel (BIZ_ID, REL_LVL, BIZ_CUST_REL_SN);
