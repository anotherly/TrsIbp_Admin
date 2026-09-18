package kr.co.TRSolution.trsIbp.schedule.service;

import java.util.List;

import kr.co.TRSolution.trsIbp.schedule.vo.ScheduleVO;

/**
 * 종합 일정 캘린더 Service
 */
public interface ScheduleService {
    public List<ScheduleVO> selectScheduleCodeList(ScheduleVO scheduleVO) throws Exception;
    public List<ScheduleVO> selectMonthScheduleSummaryList(ScheduleVO scheduleVO) throws Exception;
    public List<ScheduleVO> selectDayScheduleList(ScheduleVO scheduleVO) throws Exception;
    public List<ScheduleVO> selectUserDayScheduleList(ScheduleVO scheduleVO) throws Exception;
    public ScheduleVO selectSchedule(ScheduleVO scheduleVO) throws Exception;
    public void saveSchedule(ScheduleVO scheduleVO) throws Exception;
    public int selectScheduleConflictCount(ScheduleVO scheduleVO) throws Exception;
    public List<ScheduleVO> selectScheduleConflictList(ScheduleVO scheduleVO) throws Exception;
    public void deleteSchedule(ScheduleVO scheduleVO) throws Exception;
}
