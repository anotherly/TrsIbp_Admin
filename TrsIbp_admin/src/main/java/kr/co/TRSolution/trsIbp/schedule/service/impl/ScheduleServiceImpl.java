package kr.co.TRSolution.trsIbp.schedule.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import kr.co.TRSolution.trsIbp.schedule.mapper.ScheduleMapper;
import kr.co.TRSolution.trsIbp.schedule.service.ScheduleService;
import kr.co.TRSolution.trsIbp.schedule.vo.ScheduleVO;

/**
 * 종합 일정 캘린더 Service 구현체
 */
@Service("scheduleService")
public class ScheduleServiceImpl implements ScheduleService {

    @Resource(name = "scheduleMapper")
    private ScheduleMapper scheduleMapper;

    @Override
    public List<ScheduleVO> selectScheduleCodeList(ScheduleVO scheduleVO) throws Exception {
        return scheduleMapper.selectScheduleCodeList(scheduleVO);
    }

    @Override
    public List<ScheduleVO> selectMonthScheduleSummaryList(ScheduleVO scheduleVO) throws Exception {
        return scheduleMapper.selectMonthScheduleSummaryList(scheduleVO);
    }

    @Override
    public List<ScheduleVO> selectDayScheduleList(ScheduleVO scheduleVO) throws Exception {
        return scheduleMapper.selectDayScheduleList(scheduleVO);
    }

    @Override
    public List<ScheduleVO> selectUserDayScheduleList(ScheduleVO scheduleVO) throws Exception {
        return scheduleMapper.selectUserDayScheduleList(scheduleVO);
    }

    @Override
    public ScheduleVO selectSchedule(ScheduleVO scheduleVO) throws Exception {
        return scheduleMapper.selectSchedule(scheduleVO);
    }

    /**
     * 특정 대상자의 일정 중 저장하려는 시간대와 겹치는 일정 건수를 조회한다.
     * @param scheduleVO 회사ID, 대상자ID, 시작일시, 종료일시, 수정 시 일정일련번호를 포함한 조회조건
     * @return 겹치는 일정 건수
     * @throws Exception 조회 중 예외 발생 시 전달
     */
    @Override
    public int selectScheduleConflictCount(ScheduleVO scheduleVO) throws Exception {
        return scheduleMapper.selectScheduleConflictCount(scheduleVO);
    }

    @Override
    public List<ScheduleVO> selectScheduleConflictList(ScheduleVO scheduleVO) throws Exception {
        return scheduleMapper.selectScheduleConflictList(scheduleVO);
    }

    /**
     * 일정 기본정보와 대상자 관계를 저장한다.
     * @param scheduleVO 저장할 일정 기본정보와 콤마 구분 대상자ID 목록
     * @throws Exception 저장 중 예외 발생 시 전달
     */
    @Override
    public void saveSchedule(ScheduleVO scheduleVO) throws Exception {
        String[] userIds = splitTargetUserIds(scheduleVO.getTargetUserIds());
        java.util.ArrayList<ScheduleVO> conflictList = new java.util.ArrayList<ScheduleVO>();
        for (String userId : userIds) {
            scheduleVO.setTargetUserId(userId);
            conflictList.addAll(scheduleMapper.selectScheduleConflictList(scheduleVO));
        }
        if (!conflictList.isEmpty() && !"Y".equals(scheduleVO.getConflictConfirmedYn())) {
            throw new IllegalArgumentException(buildConflictMessage(conflictList));
        }

        if (scheduleVO.getSchdlSn() == null) {
            scheduleMapper.insertSchedule(scheduleVO);
        } else {
            scheduleMapper.updateSchedule(scheduleVO);
            scheduleMapper.deleteScheduleUserRel(scheduleVO);
        }
        for (String userId : userIds) {
            scheduleVO.setTargetUserId(userId);
            scheduleMapper.insertScheduleUserRel(scheduleVO);
        }
    }

    /**
     * 콤마 구분 대상자ID 문자열을 중복 제거된 배열로 변환한다.
     * @param targetUserIds 콤마 구분 대상자ID 문자열
     * @return 공백과 중복을 제거한 대상자ID 배열
     */
    private String[] splitTargetUserIds(String targetUserIds) {
        if (targetUserIds == null || targetUserIds.trim().isEmpty()) {
            return new String[0];
        }
        java.util.LinkedHashSet<String> userIdSet = new java.util.LinkedHashSet<String>();
        String[] userIds = targetUserIds.split(",");
        for (String userId : userIds) {
            if (userId != null && !userId.trim().isEmpty()) {
                userIdSet.add(userId.trim());
            }
        }
        return userIdSet.toArray(new String[userIdSet.size()]);
    }

    /**
     * 충돌 대상자, 기간, 일정구분과 일정명을 한 번에 확인할 수 있는 안내문을 만든다.
     */
    private String buildConflictMessage(List<ScheduleVO> conflictList) {
        StringBuilder message = new StringBuilder("해당 기간 내 다른 일정이 있는 사용자가 존재합니다. 확인 후 저장해주세요.");
        for (ScheduleVO conflict : conflictList) {
            message.append("\n- ")
                   .append(conflict.getTargetUserNm() == null ? conflict.getTargetUserId() : conflict.getTargetUserNm())
                   .append(": ")
                   .append(conflict.getBgngDt())
                   .append(" ~ ")
                   .append(conflict.getEndDt())
                   .append(" [")
                   .append(conflict.getSchdlSeNm() == null ? conflict.getSchdlSeCd() : conflict.getSchdlSeNm())
                   .append("] ")
                   .append(conflict.getSchdlNm());
        }
        return message.toString();
    }

    @Override
    public void deleteSchedule(ScheduleVO scheduleVO) throws Exception {
        scheduleMapper.deleteSchedule(scheduleVO);
    }
}
