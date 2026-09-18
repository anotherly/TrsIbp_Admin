package kr.co.TRSolution.trsIbp.comm.excel.support;

import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.springframework.web.servlet.view.AbstractView;


public class ExportView extends AbstractView {
	
	 String filename;
	 FileOutputStream fileout;
	 public ExportView(){
        //받드시 octet-stream으로 설정해야함
        super.setContentType("application/octet-stream");
     }
	 protected void renderMergedOutputModel(Map model,
			 HttpServletRequest request,
			 HttpServletResponse response) throws Exception{
	 }
	 @SuppressWarnings({ "unused", "unchecked" })
	 public void buildExcelDocument(String filename,
			 						   List Headrlist,
			 						   List DataList,
			 						   HttpServletRequest request,
                                       HttpServletResponse response) {
		try{
			response.setHeader("Cache-Control", "no-cache");
			this.setContentType("application/vnd.ms-excel;charset=UTF-8");
			
			HSSFWorkbook wb = new HSSFWorkbook();
			
			CellStyle titleStyle = wb.createCellStyle();
	        titleStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 가운데 정렬 (가로 기준)
	        titleStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER); // 중앙 정렬 (세로 기준)
	 	    
	 	    Font font = wb.createFont(); // 폰트 객체 생성
	 	    font.setFontHeightInPoints((short) 24); // 폰트 크기 설정
	 	    titleStyle.setFont(font); // 폰트 스타일을 셀 스타일에 적용

	 	    CellStyle mainStyle = wb.createCellStyle();
			mainStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 가운데 정렬 (가로 기준)
			mainStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER); // 중앙 정렬 (세로 기준)
	 	    
	 	    Font mainStylefont = wb.createFont(); // 폰트 객체 생성
	 	    mainStylefont.setFontHeightInPoints((short) 14); // 폰트 크기 설정
	 	    mainStyle.setFont(mainStylefont); // 폰트 스타일을 셀 스타일에 적용

	 	    CellStyle headStyle = wb.createCellStyle();
	     	headStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 오른쪽 정렬 (가로 기준)
	     	headStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER); // 중앙 정렬 (세로 기준)
	     	headStyle.setFillForegroundColor(IndexedColors.PALE_BLUE.getIndex()); // 배경색 설정*/ 	   
	     	headStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);  // 배경색이 채워지도록 패턴 설정
	     	headStyle.setBorderRight(HSSFCellStyle.BORDER_THIN); // 테두리 설정
	     	headStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	     	headStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
	     	headStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
			
			Font headStyleF = wb.createFont(); // 폰트 객체 생성
			headStyleF.setFontHeightInPoints((short) 14); // 폰트 크기 설정
			headStyleF.setFontName("굴림체");
			headStyle.setFont(headStyleF); // 폰트 스타일을 셀 스타일에 적용

			CellStyle dataStyle = wb.createCellStyle();
			dataStyle.setAlignment(HSSFCellStyle.ALIGN_LEFT); // 가운데 정렬 (가로 기준)
			dataStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER); // 중앙 정렬 (세로 기준)
			dataStyle.setBorderRight(HSSFCellStyle.BORDER_THIN); // 테두리 설정
			dataStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
			dataStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
			dataStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	 	    
	 	    Font dataStylefont = wb.createFont(); // 폰트 객체 생성
	 	    dataStylefont.setFontHeightInPoints((short) 14); // 폰트 크기 설정
	 	    dataStyle.setFont(dataStylefont); // 폰트 스타일을 셀 스타일에 적용
	 	    
			//sheet 생성
			HSSFSheet sheet1 = wb.createSheet("데이터");
			//header 생성
			HSSFRow headerrow = sheet1.createRow(0);
			for(int i=0;i<Headrlist.size();i++){
				HSSFCell headCell = headerrow.createCell(i);
				headCell.setCellValue(Headrlist.get(i).toString());
				headCell.setCellStyle(headStyle);
			}
			//data 생성
			List dataobject = null;
			for(int j=0;j<DataList.size();j++){
				HSSFRow datarow = sheet1.createRow(j+1);
				dataobject = (List)DataList.get(j);
				for(int k=0;k<dataobject.size();k++){
					if(dataobject.get(k)!=null){
						HSSFCell dataCell = datarow.createCell(k);
						dataCell.setCellValue(dataobject.get(k).toString());
						dataCell.setCellStyle(dataStyle);
					}
				}
			}
			
			sheet1.setColumnWidth(1, 5000);
			sheet1.setColumnWidth(2, 6000);
			sheet1.setColumnWidth(3, 6000);
			sheet1.setColumnWidth(4, 6000);
			sheet1.setColumnWidth(5, 5500);
			sheet1.setColumnWidth(6, 5500);
			sheet1.setColumnWidth(7, 5500);
			sheet1.setColumnWidth(8, 5500);
			sheet1.setColumnWidth(9, 5500);
			sheet1.setColumnWidth(10, 5500);
			sheet1.setColumnWidth(11, 5500);
			
			
			//ListExcelView
			OutputStream out = response.getOutputStream();
			response.setContentType(super.getContentType());
		    response.setHeader("Content-Transfer-Encoding", "binary");
		    response.setHeader("Content-DisjbpsNm","attachment;fileName=\""+filename+"\";");
			wb.write(out);
		}
		catch(Exception ioe){
			ioe.printStackTrace();
		}
	 }
	 
	 @SuppressWarnings({ "unused", "unchecked" })
	 public void buildExcelDocument(String filename,
			 						   String[] sheetlist,
			 						   String[] titleList,
			 						   List[] Headrlist,
			 						   List[] DataList,
			 						   HttpServletRequest request,
                                       HttpServletResponse response) {
		try{
			response.setHeader("Cache-Control", "no-cache");
			this.setContentType("application/vnd.ms-excel;charset=UTF-8");
			HSSFWorkbook wb = new HSSFWorkbook();

			CellStyle titleStyle = wb.createCellStyle();
	        titleStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 가운데 정렬 (가로 기준)
	        titleStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER); // 중앙 정렬 (세로 기준)
	 	    
	 	    Font font = wb.createFont(); // 폰트 객체 생성
	 	    font.setFontHeightInPoints((short) 24); // 폰트 크기 설정
	 	    titleStyle.setFont(font); // 폰트 스타일을 셀 스타일에 적용

	 	    CellStyle mainStyle = wb.createCellStyle();
			mainStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 가운데 정렬 (가로 기준)
			mainStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER); // 중앙 정렬 (세로 기준)
	 	    
	 	    Font mainStylefont = wb.createFont(); // 폰트 객체 생성
	 	    mainStylefont.setFontHeightInPoints((short) 14); // 폰트 크기 설정
	 	    mainStyle.setFont(mainStylefont); // 폰트 스타일을 셀 스타일에 적용

	 	    CellStyle headStyle = wb.createCellStyle();
	     	headStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 오른쪽 정렬 (가로 기준)
	     	headStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER); // 중앙 정렬 (세로 기준)
	     	headStyle.setFillForegroundColor(IndexedColors.PALE_BLUE.getIndex()); // 배경색 설정*/ 	   
	     	headStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);  // 배경색이 채워지도록 패턴 설정
	     	headStyle.setBorderRight(HSSFCellStyle.BORDER_THIN); // 테두리 설정
	     	headStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
	     	headStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
	     	headStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
			
			Font headStyleF = wb.createFont(); // 폰트 객체 생성
			headStyleF.setFontHeightInPoints((short) 14); // 폰트 크기 설정
			headStyleF.setFontName("굴림체");
			headStyle.setFont(headStyleF); // 폰트 스타일을 셀 스타일에 적용

			CellStyle dataStyle = wb.createCellStyle();
			dataStyle.setAlignment(HSSFCellStyle.ALIGN_LEFT); // 가운데 정렬 (가로 기준)
			dataStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER); // 중앙 정렬 (세로 기준)
			dataStyle.setBorderRight(HSSFCellStyle.BORDER_THIN); // 테두리 설정
			dataStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
			dataStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
			dataStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
	 	    
	 	    Font dataStylefont = wb.createFont(); // 폰트 객체 생성
	 	    dataStylefont.setFontHeightInPoints((short) 14); // 폰트 크기 설정
	 	    dataStyle.setFont(dataStylefont); // 폰트 스타일을 셀 스타일에 적용
	 	    
			for(int a = 0 ; a < sheetlist.length; a++){
				//sheet 생성
				HSSFSheet sheet = wb.createSheet(sheetlist[a]); 
				//title 생성
				HSSFRow titlerow = sheet.createRow(0);
				HSSFCell titleCell = titlerow.createCell(0);
				titleCell.setCellValue(titleList[a]);
				titleCell.setCellStyle(titleStyle);
				
				//header 생성
				HSSFRow headerrow = sheet.createRow(1);
				for(int i=0;i<Headrlist[a].size();i++){	
					HSSFCell headCell = headerrow.createCell(i);
					headCell.setCellValue(Headrlist[a].get(i).toString());
					headCell.setCellStyle(headStyle);
				}
				//data 생성
				
				List dataobject = null;
				for(int j=0;j<DataList[a].size();j++){
					HSSFRow datarow = sheet.createRow(j+2);
					dataobject = (List)DataList[a].get(j);
					for(int k=0;k<dataobject.size();k++){
						if(dataobject.get(k)!=null){
							HSSFCell dataCell = datarow.createCell(k);
							dataCell.setCellValue(dataobject.get(k).toString());
							dataCell.setCellStyle(dataStyle);
						}
					}
				}	
				
				
				sheet.setColumnWidth(1, 5000);
				sheet.setColumnWidth(2, 6000);
				sheet.setColumnWidth(3, 6000);
				sheet.setColumnWidth(4, 6000);
				sheet.setColumnWidth(5, 5500);
				sheet.setColumnWidth(6, 5500);
				sheet.setColumnWidth(7, 5500);
				sheet.setColumnWidth(8, 5500);
				sheet.setColumnWidth(9, 5500);
				sheet.setColumnWidth(10, 5500);
				sheet.setColumnWidth(11, 5500);
			}
			
			
			
			
			//ListExcelView
			OutputStream out = response.getOutputStream();
			response.setContentType(super.getContentType());
		    response.setHeader("Content-Transfer-Encoding", "binary");
		    response.setHeader("Content-DisjbpsNm","attachment;fileName=\""+filename+"\";");
			wb.write(out);
		}
		catch(Exception ioe){
			ioe.printStackTrace();
		}
	 }	 
	
	public String getFilename() {
		return filename;
	}
	public FileOutputStream getFileout() {
		return fileout;
	}
	public void setFilename(String filename) {
		this.filename = filename;
	}
	public void setFileout(FileOutputStream fileout) {
		this.fileout = fileout;
	}
}