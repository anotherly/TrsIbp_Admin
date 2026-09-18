package kr.co.TRSolution.trsIbp.schedule.mapper;

import java.util.List;

import egovframework.rte.psl.dataaccess.mapper.Mapper;
import kr.co.TRSolution.trsIbp.schedule.vo.ScheduleVO;

/**
 * 종합 일정 캘린더 Mapper
 */
@Mapper("scheduleMapper")
public interface ScheduleMapper {
    public List<ScheduleVO> selectScheduleCodeList(ScheduleVO scheduleVO) throws Exception;
    public List<ScheduleVO> selectMonthScheduleSummaryList(ScheduleVO scheduleVO) throws Exception;
    public List<ScheduleVO> selectDayScheduleList(ScheduleVO scheduleVO) throws Exception;
    public List<ScheduleVO> selectUserDayScheduleList(ScheduleVO scheduleVO) throws Exception;
    public ScheduleVO selectSchedule(ScheduleVO scheduleVO) throws Exception;
    public void insertSchedule(ScheduleVO scheduleVO) throws Exception;
    public void updateSchedule(ScheduleVO scheduleVO) throws Exception;
    public void deleteScheduleUserRel(ScheduleVO scheduleVO) throws Exception;
    public void insertScheduleUserRel(ScheduleVO scheduleVO) throws Exception;
    public int selectScheduleConflictCount(ScheduleVO scheduleVO) throws Exception;
    public List<ScheduleVO> selectScheduleConflictList(ScheduleVO scheduleVO) throws Exception;
    public void deleteSchedule(ScheduleVO scheduleVO) throws Exception;
}
