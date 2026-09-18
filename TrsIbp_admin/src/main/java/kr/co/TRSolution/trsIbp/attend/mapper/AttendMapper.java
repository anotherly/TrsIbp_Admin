package kr.co.TRSolution.trsIbp.attend.mapper;

import java.util.List;

import egovframework.rte.psl.dataaccess.mapper.Mapper;
import kr.co.TRSolution.trsIbp.attend.vo.AttendVO;

/**
 * 근태관리 MyBatis 매퍼 인터페이스
 *
 * @author DevSync
 * @since 2026-05-28
 */
@Mapper("attendMapper")
public interface AttendMapper {

    /**
     * 오늘 출근 기록 조회 (userId + 오늘날짜)
     */
    AttendVO selectTodayAttend(AttendVO attendVO);

    AttendVO selectTodayScheduleStatus(AttendVO attendVO);

    List<AttendVO> selectPowkCodeList();

    List<AttendVO> selectTeamStatusList(AttendVO attendVO);

    /**
     * 공통코드 기준 기본 근무장소구분코드를 조회한다.
     */
    String selectDefaultPowkSeCd();

    /**
     * 출근 기록 INSERT
     */
    void insertCheckIn(AttendVO attendVO);

    /**
     * 퇴근 시간 UPDATE
     */
    void updateCheckOut(AttendVO attendVO);

    /**
     * 근무지 업데이트
     */
    int updatePowkNm(AttendVO attendVO);
}
