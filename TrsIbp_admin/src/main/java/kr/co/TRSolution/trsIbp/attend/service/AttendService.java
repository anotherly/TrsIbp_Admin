package kr.co.TRSolution.trsIbp.attend.service;

import java.util.List;

import kr.co.TRSolution.trsIbp.attend.vo.AttendVO;

/**
 * 근태관리 서비스 인터페이스
 *
 * @author DevSync
 * @since 2026-05-28
 */
public interface AttendService {

    /** 오늘 출근 기록 조회 */
    AttendVO selectTodayAttend(AttendVO attendVO);

    /** 현재 시각에 적용되는 휴가/출장/외근/재택/상주 일정 */
    AttendVO selectTodayScheduleStatus(AttendVO attendVO);

    /** 근무장소 공통코드 */
    List<AttendVO> selectPowkCodeList();

    /** 로그인 사용자와 같은 부서의 현재 상태 */
    List<AttendVO> selectTeamStatusList(AttendVO attendVO);

    /** 기본 근무장소구분코드 조회 */
    String selectDefaultPowkSeCd();

    /** 출근 처리 */
    void checkIn(AttendVO attendVO);

    /** 퇴근 처리 */
    void checkOut(AttendVO attendVO);

    /** 근무지 변경 */
    int updatePowkNm(AttendVO attendVO);
}
