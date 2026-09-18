package kr.co.TRSolution.trsIbp.comm;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;




@Service
public class ClientChkScheduler {
public static final Logger logger = LoggerFactory.getLogger(ClientChkScheduler.class);
	
	/*@Resource(name="statisticService")
	private StatisticService statisticService;
	
	@Resource(name="areaOptService")
	private AreaOptService areaOptService;
	
	@Resource(name="infrmOptService")
	private InfrmOptService infrmOptService;
	
	@Resource(name="rptOptService")
	private RptOptService rptOptService;*/
	/**
	 * 스케줄러-매일 새벽 3시에 실행
	 * */
	public void clientAutoChk(){
		logger.debug("$$$$$ 스케줄러 실행!!!!!!!!!!!!!!!!");
		/*try {
			//방송국전체
			List<OptAreaVo> alist = new ArrayList<OptAreaVo>();
			OptAreaVo avo = new OptAreaVo();
			alist=areaOptService.selectAreaOpt1(avo);
			//통신원전체
			List<OptInftVo> ilist = new ArrayList<OptInftVo>();
			OptInftVo ivo = new OptInftVo();
			ilist=infrmOptService.selectInft1(ivo);
			//제보유형 전체
			List<OptRptVo> rplist = new ArrayList<OptRptVo>();
			OptRptVo rpvo = new OptRptVo();
			rpvo.setBasLcod("100");
			rplist = rptOptService.selectRpt(rpvo);
			//제보수단 전체
			List<OptInftVo> rtlist = new ArrayList<OptInftVo>();
			rtlist=statisticService.statRtt();
			logger.debug(rtlist.get(0).getIfmId1());
			
			for (int i = 0; i < alist.size(); i++) {
				for (int j = 0; j < ilist.size(); j++) {
					//통신원
					statisticService.statInfrmType(alist.get(i).getAreaCode(),ilist.get(j).getIfmId1());
				}
				for (int j = 0; j < rplist.size(); j++) {
					//제보유형
					statisticService.statRptType(alist.get(i).getAreaCode(),rplist.get(j).getBasScod());
				}
				for (int j = 0; j < rtlist.size(); j++) {
					//제보수단
					statisticService.statRttType(alist.get(i).getAreaCode(),rtlist.get(j).getIfmId1());
				}
			}
			//adsoft 사용으로 연동 시 구성 (향후 삭제 필요)(월별 통신원 건수 새벽  3시마다 갱신)
			statisticService.schmonInfrmDelete();
			statisticService.schmonInfrmInsert();
			
		} catch (Exception e) {
			e.printStackTrace();
		}*/
		
	}
}
