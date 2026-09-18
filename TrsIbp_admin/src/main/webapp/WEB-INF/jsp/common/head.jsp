<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.jsp.SkipPageException" %>
<%@ page import="java.util.Set" %>
<%
    if (session.getAttribute("login") == null) {
        response.sendRedirect(request.getContextPath() + "/login/login.do");
        throw new SkipPageException();
    }

    String dsTitle = request.getParameter("dsTitle");
    if (dsTitle == null || dsTitle.trim().isEmpty()) {
        dsTitle = "DevSync System Admin";
    }
%>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%=dsTitle%></title>

<script src="<%=request.getContextPath()%>/protoType/saved_resource"></script>
<script>
    tailwind.config = {
        theme: {
            extend: {
                colors: {
                    brand: {
                        dark: '#0b0f19',
                        card: '#111827',
                        border: '#1f2937',
                        accent: '#3b82f6',
                        neonBlue: '#00d2ff',
                        neonGreen: '#10b981'
                    }
                },
                fontFamily: {
                    sans: ['Inter', 'Noto Sans KR', 'sans-serif']
                }
            }
        }
    };
</script>
<link href="<%=request.getContextPath()%>/protoType/css2" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/vendor/jquery-datetimepicker/jquery.datetimepicker.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/layout.css">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    window.jQuery || document.write('<script src="<%=request.getContextPath()%>/js/vendor/jquery/jquery-3.7.1.min.js"><\/script>');
</script>
<script src="<%=request.getContextPath()%>/js/vendor/jquery-datetimepicker/jquery.datetimepicker.full.min.js"></script>
<script src="<%=request.getContextPath()%>/js/comm/dateTimePicker.js"></script>
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script src="<%=request.getContextPath()%>/js/comm/layout.js"></script>
<script>
    window.dsGrantedMenuCodes = {};
    window.dsIsAdmin = ${sessionScope.login.authrtId eq 'SYS_ADMIN' ? 'true' : 'false'};
    <%
        Set<String> dsHeadMenuCodes = (Set<String>) session.getAttribute("grantedMenuCodes");
        if (dsHeadMenuCodes != null) {
            for (String dsHeadMenuCode : dsHeadMenuCodes) {
    %>
    window.dsGrantedMenuCodes['<%=dsHeadMenuCode%>'] = true;
    <%
            }
        }
    %>
    window.hasAuthorityCode = function(code) {
        return !code || window.dsGrantedMenuCodes[code] === true;
    };
    window.hasAnyAuthorityCode = function(codes) {
        if (!codes) {
            return true;
        }
        return codes.split(',').some(function(code) {
            return window.hasAuthorityCode(code.trim());
        });
    };
    document.addEventListener('DOMContentLoaded', function() {
        var targets = document.querySelectorAll('[data-authority-code], [data-authority-any]');
        Array.prototype.forEach.call(targets, function(target) {
            var allowed = target.hasAttribute('data-authority-any')
                    ? window.hasAnyAuthorityCode(target.getAttribute('data-authority-any'))
                    : window.hasAuthorityCode(target.getAttribute('data-authority-code'));
            if (!allowed) {
                target.style.display = 'none';
            }
        });
    });
</script>
