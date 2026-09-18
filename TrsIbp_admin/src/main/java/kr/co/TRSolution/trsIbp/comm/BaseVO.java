package kr.co.TRSolution.trsIbp.comm;

import java.io.Serializable;

/**
 * 전사 공통 Base VO
 * - 검색, 기간검색, 페이징, 목록 정렬 등 화면 공통 파라미터 전용
 * - 업무 테이블의 정렬순서(SORT_SEQ)는 공통 sortSeq 필드로 사용
 */
public class BaseVO implements Serializable {

    private static final long serialVersionUID = 1L;

    // ===================================================
    // 1. 시스템 공통 및 감사(Audit) 필드
    // ===================================================
    /** 등록일시 */
    private String regDt;

    /** 생성일시 */
    private String createdAt;

    /** 수정일시 */
    private String updatedAt;

    // ===================================================
    // 2. 전사 공통 UI 검색(Search) 필드
    // ===================================================
    /** 검색유형 */
    private String searchType;

    /** 검색어 */
    private String searchValue;

    /** 통합 검색 키워드 */
    private String searchKeyword;

    /** 기간 검색 시작일 */
    private String sDate;

    /** 기간 검색 종료일 */
    private String eDate;

    // ===================================================
    // 3. 페이징(Paging) 필드
    // ===================================================
    /** 현재 페이지 번호 */
    private int pageIdx = 1;

    /** 한 페이지당 데이터 수 */
    private int pageRowCnt = 10;

    /** DB LIMIT 시작 offset */
    private int startRow = 0;

    /** eGov/MyBatis LIMIT 시작 위치 호환 필드 */
    private Integer firstIndex;

    /** eGov/MyBatis LIMIT 개수 호환 필드 */
    private Integer recordCountPerPage;

    // ===================================================
    // 4. 목록 정렬 공통 필드
    // ===================================================
    /** 동적 정렬 대상 컬럼명 */
    private String sortColumn;

    /** 동적 정렬 방향: ASC / DESC */
    private String sortOrder = "DESC";

    /** 업무 데이터 정렬순서 */
    private Integer sortSeq;

    // ===================================================
    // Getter & Setter
    // ===================================================
    public String getRegDt() {
        return regDt;
    }

    public void setRegDt(String regDt) {
        this.regDt = regDt;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getSearchType() {
        return searchType;
    }

    public void setSearchType(String searchType) {
        this.searchType = searchType;
    }

    public String getSearchValue() {
        return searchValue;
    }

    public void setSearchValue(String searchValue) {
        this.searchValue = searchValue;
    }

    public String getSearchKeyword() {
        return searchKeyword;
    }

    public void setSearchKeyword(String searchKeyword) {
        this.searchKeyword = searchKeyword;
    }

    public String getsDate() {
        return sDate;
    }

    public void setsDate(String sDate) {
        this.sDate = sDate;
    }

    public String geteDate() {
        return eDate;
    }

    public void seteDate(String eDate) {
        this.eDate = eDate;
    }

    public int getPageIdx() {
        return pageIdx;
    }

    public void setPageIdx(int pageIdx) {
        this.pageIdx = pageIdx;
        this.startRow = (pageIdx - 1) * this.pageRowCnt;
        this.firstIndex = this.startRow;
    }

    public int getPageRowCnt() {
        return pageRowCnt;
    }

    public void setPageRowCnt(int pageRowCnt) {
        this.pageRowCnt = pageRowCnt;
        this.startRow = (this.pageIdx - 1) * pageRowCnt;
        this.firstIndex = this.startRow;
        this.recordCountPerPage = pageRowCnt;
    }

    public int getStartRow() {
        return (this.pageIdx - 1) * this.pageRowCnt;
    }

    public void setStartRow(int startRow) {
        this.startRow = startRow;
        this.firstIndex = startRow;
    }

    public Integer getFirstIndex() {
        if (firstIndex != null) {
            return firstIndex;
        }
        return getStartRow();
    }

    public void setFirstIndex(Integer firstIndex) {
        this.firstIndex = firstIndex;
        if (firstIndex != null) {
            this.startRow = firstIndex;
        }
    }

    public Integer getRecordCountPerPage() {
        if (recordCountPerPage != null) {
            return recordCountPerPage;
        }
        return pageRowCnt;
    }

    public void setRecordCountPerPage(Integer recordCountPerPage) {
        this.recordCountPerPage = recordCountPerPage;
        if (recordCountPerPage != null) {
            this.pageRowCnt = recordCountPerPage;
        }
    }

    public String getSortColumn() {
        return sortColumn;
    }

    public void setSortColumn(String sortColumn) {
        this.sortColumn = sortColumn;
    }

    public String getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(String sortOrder) {
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            this.sortOrder = "ASC";
        } else {
            this.sortOrder = "DESC";
        }
    }

    public Integer getSortSeq() {
        return sortSeq;
    }

    public void setSortSeq(Integer sortSeq) {
        this.sortSeq = sortSeq;
    }

    @Override
    public String toString() {
        return "BaseVO [searchType=" + searchType
                + ", searchValue=" + searchValue
                + ", searchKeyword=" + searchKeyword
                + ", sDate=" + sDate
                + ", eDate=" + eDate
                + ", pageIdx=" + pageIdx
                + ", pageRowCnt=" + pageRowCnt
                + ", sortColumn=" + sortColumn
                + ", sortOrder=" + sortOrder
                + ", sortSeq=" + sortSeq
                + "]";
    }
}
