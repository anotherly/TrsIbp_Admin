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
 */
package kr.co.TRSolution.trsIbp.comm.filter;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

public class HTMLTagFilter implements Filter {

	@SuppressWarnings("unused")
	private FilterConfig config;

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		
		HttpServletRequest req = (HttpServletRequest) request;
		
		boolean bypass = checkUrl(req);
		System.out.println("[HTMLTagFilter] " + req.getMethod() + " " + req.getRequestURI()
		    + " bypass=" + bypass + " CT=" + req.getContentType());
		
		if (checkUrl(req)) {
			/// minking/로 시작하는 url은 filter를 하지 않는다.
			chain.doFilter(request, response);
		} else {
			// 그 외의 경우 filter를 한다.
			chain.doFilter(new HTMLTagFilterRequestWrapper((HttpServletRequest) request), response);
		}
		//chain.doFilter(new HTMLTagFilterRequestWrapper((HttpServletRequest)request),response);
	}

	public void init(FilterConfig config) throws ServletException {
		this.config = config;
	}

	public void destroy() {

	}

	/**
	 * HTMLTagFilterRequestWrapper를 통과하며 JSON 문법용 큰따옴표가 HTML 엔티티로 치환된 경우,
	 * ObjectMapper가 JSON 구조를 파싱할 수 있도록 큰따옴표 계열만 복원한다.
	 * 사용자 입력값의 XSS 방어를 유지하기 위해 &lt;, &gt;, &amp;, 작은따옴표 계열은 복원하지 않는다.
	 *
	 * @param json HTML 엔티티가 포함될 수 있는 JSON 문자열
	 * @return JSON 필드명/문자열 구분에 필요한 큰따옴표만 복원된 JSON 문자열
	 */
	public static String restoreJsonQuoteOnly(String json) {
		if (json == null) {
			return null;
		}
		return json.replace("&quot;", "\"")
				.replace("&#34;", "\"")
				.replace("&#034;", "\"")
				.replace("&#x22;", "\"")
				.replace("&#X22;", "\"");
	}

	// 25년 보안취약점 조치
	// 필터 예외 메소드 수정 변경
	private boolean checkUrl(HttpServletRequest req) {
	    String uri = req.getRequestURI();
	    String ctx = req.getContextPath();   // 예: /TBNWEB

	    // ctx 제거한 “순수 경로”
	    String path = uri.startsWith(ctx) ? uri.substring(ctx.length()) : uri;

	    // /minking/ 제외
	    if (path.startsWith("/minking/")) {
	    	return true;
	    }
	    //  /receipt/ 전체 제외 (요구사항)
	    if (path.startsWith("/receipt/")) {
	    	return true;
	    }

	    return false;
	}

}
