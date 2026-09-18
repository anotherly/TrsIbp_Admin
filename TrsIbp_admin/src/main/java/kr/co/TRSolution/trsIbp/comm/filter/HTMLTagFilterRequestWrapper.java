package kr.co.TRSolution.trsIbp.comm.filter;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

public class HTMLTagFilterRequestWrapper extends HttpServletRequestWrapper {

    // 기존 허용 태그(유지)
    static private String[] whiteListTag = { "<p>", "</p>", "<br />" };

    // MEMO_CN에서만 허용할 “토큰” (태그 전체 허용이 아님)
    private static final String[] memoCnAllowedTokens = { "<긴급>", "<재난>" };

    private final HttpServletRequest originalRequest;

    // sanitize된 parameterMap 캐시(한 요청에서 반복 처리 방지)
    private Map<String, String[]> sanitizedParamMap;

    public HTMLTagFilterRequestWrapper(HttpServletRequest request) {
        super(request);
        this.originalRequest = request;
    }

    @Override
    public String getParameter(String name) {
        String[] values = getParameterValues(name);
        if (values == null || values.length == 0) return null;
        return values[0];
    }

    @Override
    public String[] getParameterValues(String name) {
        Map<String, String[]> map = getParameterMap();
        String[] values = map.get(name);
        return values;
    }

    /**
     * Map 기반으로만 처리(멀티파트에서도 Spring이 만들어 둔 parameterMap을 신뢰)
     */
    @Override
    public Map<String, String[]> getParameterMap() {
        if (sanitizedParamMap != null) {
            return sanitizedParamMap;
        }

        Map<String, String[]> src = super.getParameterMap();
        Map<String, String[]> dst = new HashMap<String, String[]>(src.size());

        for (Map.Entry<String, String[]> e : src.entrySet()) {
            String key = e.getKey();
            String[] vals = e.getValue();

            if (vals == null) {
                dst.put(key, null);
                continue;
            }

            String[] newVals = new String[vals.length];
            for (int i = 0; i < vals.length; i++) {
                newVals[i] = sanitizeParam(key, vals[i]);
            }
            dst.put(key, newVals);
        }

        sanitizedParamMap = dst;
        return sanitizedParamMap;
    }

    /**
     * 파라미터 sanitize (URI + 파라미터명 기반 예외 적용)
     */
    private String sanitizeParam(String paramName, String value) {
        if (value == null) return null;

        // MEMO_CN 예외: 제보 등록/임시저장 URI에서만 "<긴급>", "<재난>" 토큰만 허용
        if (isReceiptMemoCnAllowed(paramName)) {
            return escapeExceptTokens(value, memoCnAllowedTokens);
        }

        // 기본: 기존 화이트리스트 태그(p, br)만 허용 + 나머지는 전부 escape
        return getSafeParamData(value);
    }

    private boolean isReceiptMemoCnAllowed(String paramName) {
        if (!"MEMO_CN".equalsIgnoreCase(paramName)) return false;

        String uri = originalRequest.getRequestURI();
        String ctx = originalRequest.getContextPath();
        if (ctx != null && ctx.length() > 0 && uri.startsWith(ctx)) {
            uri = uri.substring(ctx.length());
        }

        // 사용자님 요구사항: “제보 등록의 MEMO_CN”만 허용
        // 실제 등록/임시저장 URI만 지정 (필요시 여기에 추가)
        return ("/receipt/insertReceipt.do".equals(uri) || "/receipt/tempSave.do".equals(uri));
    }

    /**
     * value 전체를 기본 escape 처리하되, 지정된 토큰("<긴급>", "<재난>")만 원문으로 되돌림
     * - "<svg ...>" 같이 토큰이 아닌 태그는 절대 통과 못함
     */
    private String escapeExceptTokens(String value, String[] allowedTokens) {
        // 1) 먼저 전체를 안전하게 escape
        String escaped = escapeAll(value);

        // 2) allowedTokens는 escape된 형태를 원문 형태로 되돌림
        // "<긴급>" -> "&lt;긴급&gt;" 를 "<긴급>" 로 복원
        for (String token : allowedTokens) {
            String tokenEsc = escapeAll(token);
            escaped = escaped.replace(tokenEsc, token);
        }
        return escaped;
    }

    /**
     * 모든 위험문자 escape (& 포함)
     * - 이 함수는 "토큰 복원"용으로도 사용되므로 화이트리스트 태그 로직 없이 단순 escape만 수행
     */
    private String escapeAll(String value) {
        StringBuilder sb = new StringBuilder(value.length() + 32);

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '&':
                    sb.append("&amp;");
                    break;
                case '<':
                    sb.append("&lt;");
                    break;
                case '>':
                    sb.append("&gt;");
                    break;
                case '"':
                    sb.append("&quot;");
                    break;
                case '\'':
                    sb.append("&apos;");
                    break;
                default:
                    sb.append(c);
                    break;
            }
        }
        return sb.toString();
    }

    /**
     * 기존 로직 유지하되, & 처리만 활성화(권장) + 화이트리스트(p, br) 유지
     */
    private String getSafeParamData(String value) {
        StringBuffer strBuff = new StringBuffer();

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
            case '&':
                strBuff.append("&amp;"); // ✅ 권장: 기존 주석 해제
                break;
            case '<':
                if (checkNextWhiteListTag(i, value) == false)
                    strBuff.append("&lt;");
                else
                    strBuff.append(c);
                break;
            case '>':
                if (checkPrevWhiteListTag(i, value) == false)
                    strBuff.append("&gt;");
                else
                    strBuff.append(c);
                break;
            case '"':
                strBuff.append("&quot;");
                break;
            case '\'':
                strBuff.append("&apos;");
                break;
            default:
                strBuff.append(c);
                break;
            }
        }

        return strBuff.toString();
    }

    private boolean checkNextWhiteListTag(int index, String data) {
        String extractData = "";
        int endIndex = 0;
        for (String whiteListData : whiteListTag) {
            endIndex = index + whiteListData.length();
            if (data.length() > endIndex)
                extractData = data.substring(index, endIndex);
            else
                extractData = "";
            if (whiteListData.equals(extractData)) return true;
        }
        return false;
    }

    private boolean checkPrevWhiteListTag(int index, String data) {
        String extractData = "";
        int beginIndex = 0;
        int endIndex = 0;
        for (String whiteListData : whiteListTag) {
            beginIndex = index - whiteListData.length() + 1;
            endIndex = index + 1;
            if (beginIndex >= 0)
                extractData = data.substring(beginIndex, endIndex);
            else
                extractData = "";
            if (whiteListData.equals(extractData)) return true;
        }
        return false;
    }
}



/*
 * Copyright 2008-2009 MOPAS(MINISTRY OF SECURITY AND PUBLIC ADMINISTRATION).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 
package kr.co.TRSolution.trsHome.comm.filter;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

*//**
*
* HTMLTagFilterRequestWrapper 
* @author 공통컴포넌트 팀 신용호
* @since 2018.03.21
* @version 1.0
* @see
*
* <pre>
* << 개정이력(Modification Information) >>
*
*   수정일              수정자              수정내용
*  -------      --------    ---------------------------
*   2018.03.21  신용호              getParameterMap()구현 추가
*   2019.01.31  신용호              whiteList 태그 추가
*
*//*

public class HTMLTagFilterRequestWrapper extends HttpServletRequestWrapper {

	// Tag 화이트 리스트 ( 허용할 태그 등록 )
	static private String[] whiteListTag = { "<p>","</p>","<br />" };
	
	public HTMLTagFilterRequestWrapper(HttpServletRequest request) {
		super(request);
	}

	public String[] getParameterValues(String parameter) {

		String[] values = super.getParameterValues(parameter);
		
		if(values==null){
			return null;			
		}
		
		for (int i = 0; i < values.length; i++) {
			if (values[i] != null) {
				values[i] = getSafeParamData(values[i]);
				//System.out.println( "[HTMLTagFilter getParameterValues] "+ parameter + "===>>>"+values[i] );
			} else {
				values[i] = null;
			}
		}

		return values;
	}

	public String getParameter(String parameter) {
		
		String value = super.getParameter(parameter);
		
		if(value==null){
			return null;
		}
		
		value = getSafeParamData(value);
		//System.out.println( "[HTMLTagFilter getParameter] "+ parameter + "===>>>"+value );
		return value;
	}

	*//**
	 * Map으로 바인딩된 경우를 처리한다.
	 *
	 * @return  Map - String Type Key / String배열타입 값
	 *//*
    public Map<String, String[]> getParameterMap() {
    	Map<String, String[]> valueMap = super.getParameterMap();

    	String[] values;
    	for( String key : valueMap.keySet() ){
    		values = valueMap.get(key);

    		for (int i = 0; i < values.length; i++) {			
    			if (values[i] != null) {				
    				values[i] = getSafeParamData(values[i]);
    				//System.out.println( "[HTMLTagFilter getParameterMap] "+ key + "===>>>"+values[i] );
    			} else {
    				values[i] = null;
    			}
    		}
    		
            //System.out.println( String.format("키 : %s, 값 : %s", key, valueMap.get(key)) );
        }

    	return valueMap;
    }
    
	private String getSafeParamData(String value) {
		StringBuffer strBuff = new StringBuffer();

		for (int i = 0; i < value.length(); i++) {
			char c = value.charAt(i);
			switch (c) {
			case '<':
				if ( checkNextWhiteListTag(i, value) == false )
					strBuff.append("&lt;");
				else 
					strBuff.append(c);
				//System.out.println("checkNextWhiteListTag = "+checkNextWhiteListTag(i, value));
				break;
			case '>':
				if ( checkPrevWhiteListTag(i, value) == false )
					strBuff.append("&gt;");
				else 
					strBuff.append(c);
				//System.out.println("checkPrevWhiteListTag = "+checkPrevWhiteListTag(i, value));
				break;
				//25년 보안취약점 조치 -> case '&' 에 대한 주석 해제 
			case '&':
				strBuff.append("&amp;");
				break;
			case '"':
				strBuff.append("&quot;");
				break;
			case '\'':
				strBuff.append("&apos;");
				break;	
			default:
				strBuff.append(c);
				break;
			}
		}
		
		value = strBuff.toString();
		return value;
	}

	private boolean checkNextWhiteListTag(int index, String data) {
		String extractData = "";
		//int beginIndex = 0;
		int endIndex = 0;
		for(String whiteListData: whiteListTag) {
		    //System.out.println("===>>> whiteListData="+whiteListData);
			endIndex = index+whiteListData.length();
		    if ( data.length() > endIndex )
		    	extractData = data.substring(index, endIndex);
		    else
		    	extractData = "";
		    //System.out.println("extractData="+extractData);
		    if ( whiteListData.equals(extractData) ) return true; // whiteList 대상으로 판정
		}
		
		return false;
	}
	
	private boolean checkPrevWhiteListTag(int index, String data) {
		String extractData = "";
		int beginIndex = 0;
		int endIndex = 0;
		for(String whiteListData: whiteListTag) {
		    //System.out.println("===>>> whiteListData="+whiteListData);
			beginIndex = index-whiteListData.length()+1;
			endIndex = index+1;
		    //System.out.println("  range ["+beginIndex+" ~ "+endIndex+"]");
		    if ( beginIndex >= 0 )
		    	extractData = data.substring(beginIndex, endIndex);
		    else
		    	extractData = "";
		    //System.out.println("extractData="+extractData);
		    if ( whiteListData.equals(extractData) ) return true; // whiteList 대상으로 판정
		}
		
		return false;
	}

}*/