/*
 * @(#)fileDownloadView.java 1.0 2012/03/09
 * 
 * COPYRIGHT (C) 2011 NEONEXSOFT CO., LTD.
 * ALL RIGHTS RESERVED.
 */
package kr.co.TRSolution.trsIbp.comm.excel;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.util.FileCopyUtils;
import org.springframework.web.servlet.view.AbstractView;

/**파일 다운로드 뷰 클래스이다.
 * @author hjyoon
 *
 */
public class FileDownloadView extends AbstractView {
    /**
     * 파일크기를 반환한다.
     * 
     * @param model 모델
     * @return 파일크기
     */
    private int getFileSz(Map<String, Object> model) {
        Object fileSz = model.get("fileSz");
        
        return Integer.valueOf(fileSz.toString()).intValue();
    }
    
    /**
     * 파일이름을 반환한다.
     * 
     * @param model 모델
     * @return 파일이름
     */
    private String getFileName(Map<String, Object> model) {
        String fileName = (String) model.get("fileName");
        
        try {
            return URLEncoder.encode(fileName, "UTF-8").replace('+', ' ');
        }
        catch (UnsupportedEncodingException uee) {
            return fileName;
        }
    }
    
    // /**
    //  * 파일경로를 반환한다.
    //  * 
    //  * @param model 모델
    //  * @return 파일경로
    //  */
    // private String getFilePathNm(Map<String, Object> model) {
    //     String filePathNm = (String) model.get("filePathNm");
    //     
    //     return filePathNm.replaceAll("\\\\", "/");
    // }
    
    /**
     * 파일내용을 반환한다.
     * 
     * @param model 모델
     * @return 파일내용
     */
    private byte[] getFileContents(Map<String, Object> model) {
        return (byte[]) model.get("fileContents");
    }
    
    /* 
     * (non-Javadoc)
     * @see org.springframework.web.servlet.view.AbstractView#renderMergedOutputModel(java.util.Map, javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
     */
    @Override
    protected void renderMergedOutputModel(Map<String, Object> model, HttpServletRequest request, HttpServletResponse response) throws Exception {
        // FileInputStream fis = null;
        // 
        // try {
        //     setContentType("application/octet-stream");
        //     
        //     response.setContentType(getContentType());
        //     response.setContentLength(getFileSz(model));
        //     response.setHeader("Content-Transfer-Encoding", "binary");
        //     response.setHeader("Content-DisjbpsNm", "attachment;fileName=\"" + getFileName(model) + "\";");
        //     
        //     OutputStream out = response.getOutputStream();
        //     
        //     fis = new FileInputStream(getFilePathNm(model));
        //     
        //     FileCopyUtils.copy(fis, out);
        // }
        // catch (FileNotFoundException fnfe) {
        //     setContentType("text/html;charset=UTF-8");
        //     
        //     response.reset();
        //     
        //     response.setContentType(getContentType());
        //     
        //     PrintWriter out = response.getWriter();
        //     
        //     out.println("<script type=\"text/javascript\">");
        //     out.println("alert(\"첨부파일이 존재하지 않습니다.\");");
        //     out.println("</script>");
        // }
        // finally {
        //     if (fis != null) {
        //         try {
        //             fis.close();
        //         }
        //         catch (IOException ioe) {
        //             // Nothing to do.
        //         }
        //     }
        // }
        setContentType("application/octet-stream");
        
        response.setContentType(getContentType());
        response.setContentLength(getFileSz(model));
        response.setHeader("Content-Transfer-Encoding", "binary");
        response.setHeader("Content-DisjbpsNm", "attachment;fileName=\"" + getFileName(model) + "\";");
        
        FileCopyUtils.copy(getFileContents(model), response.getOutputStream());
    }
}