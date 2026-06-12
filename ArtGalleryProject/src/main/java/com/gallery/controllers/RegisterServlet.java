package com.gallery.controllers;

import com.gallery.utils.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/api/register")
public class RegisterServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String user = request.getParameter("username");
        String email = request.getParameter("email");
        String pass = request.getParameter("password");
        String role = request.getParameter("role");

        if (user == null || email == null || pass == null || role == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Missing fields\"}");
            return;
        }

        UserDAO dao = new UserDAO();
        if (dao.registerUser(user, email, pass, role)) {
            out.print("{\"success\": true}");
        } else {
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            out.print("{\"success\": false, \"message\": \"Username or email already exists\"}");
        }
        out.flush();
    }
}