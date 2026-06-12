package com.gallery.controllers;

import com.gallery.models.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String path = req.getRequestURI();
        String contextPath = req.getContextPath();
        String route = path.substring(contextPath.length());

        boolean isPublic = route.equals("/") ||
                           route.startsWith("/home") ||
                           route.startsWith("/assets") ||
                           route.startsWith("/login.jsp") ||
                           route.startsWith("/register.jsp") ||
                           route.startsWith("/cart.jsp") ||
                           route.startsWith("/store.jsp") ||
                           route.startsWith("/wall.jsp") ||
                           route.startsWith("/api/login") ||
                           route.startsWith("/api/register") ||
                           route.startsWith("/api/google-login") ||
                           route.startsWith("/api/artworks") ||
                           route.startsWith("/api/cart") ||
                           route.matches("/artwork/.*");

        if (isPublic) {
            chain.doFilter(request, response);
            return;
        }

        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        if (!isLoggedIn) {
            if (route.startsWith("/api/")) {
                res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                res.getWriter().write("{\"error\": \"Authentication required\"}");
            } else {
                res.sendRedirect(contextPath + "/login.jsp");
            }
            return;
        }

        User user = (User) session.getAttribute("user");
        String role = user.getRole();

        if (route.startsWith("/admin") || route.startsWith("/api/admin")) {
            if (!"ADMIN".equals(role)) {
                sendForbidden(route, res);
                return;
            }
        }

        if (route.startsWith("/artist") || route.startsWith("/api/artist")) {
            if (!"ARTIST".equals(role)) {
                sendForbidden(route, res);
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private void sendForbidden(String route, HttpServletResponse res) throws IOException {
        if (route.startsWith("/api/")) {
            res.setStatus(HttpServletResponse.SC_FORBIDDEN);
            res.getWriter().write("{\"error\": \"Insufficient privileges\"}");
        } else {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
        }
    }
}