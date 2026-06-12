package com.gallery.controllers;

import com.gallery.models.User;
import com.gallery.utils.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/api/login")
public class LoginServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        
        UserDAO dao = new UserDAO();
        User authenticatedUser = dao.authenticate(user, pass);
        
        PrintWriter out = response.getWriter();
        
        if (authenticatedUser != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("user", authenticatedUser);
            
            Cookie sessionCookie = new Cookie("JSESSIONID", session.getId());
            sessionCookie.setHttpOnly(true);
            sessionCookie.setPath(request.getContextPath());
            response.addCookie(sessionCookie);
            
            out.print("{\"success\": true, \"role\": \"" + authenticatedUser.getRole() + "\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Invalid credentials\"}");
        }
        
        out.flush();
    }
}