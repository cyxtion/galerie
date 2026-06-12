package com.gallery.controllers;

import com.gallery.models.User;
import com.gallery.utils.DBUtil;
import com.gallery.utils.SecurityUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/api/google-login")
public class GoogleAuthServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String credential = request.getParameter("credential");

        if (credential == null || credential.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Missing Google token\"}");
            return;
        }

        try {
            URL url = new URL("https://oauth2.googleapis.com/tokeninfo?id_token=" + credential);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");

            if (con.getResponseCode() != 200) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\": false, \"message\": \"Invalid Google token\"}");
                return;
            }

            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            String inputLine;
            StringBuilder content = new StringBuilder();
            while ((inputLine = in.readLine()) != null) {
                content.append(inputLine);
            }
            in.close();
            con.disconnect();

            String jsonResponse = content.toString();
            String email = extractJsonField(jsonResponse, "email");
            String name = extractJsonField(jsonResponse, "name");
            
            if (email == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Email not provided by Google\"}");
                return;
            }

            String baseUsername = email.split("@")[0];
            User user = getOrCreateUser(email, name != null ? name : baseUsername);

            if (user != null && "ACTIVE".equals(user.getAccountStatus())) {
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                
                Cookie sessionCookie = new Cookie("JSESSIONID", session.getId());
                sessionCookie.setHttpOnly(true);
                sessionCookie.setPath(request.getContextPath());
                response.addCookie(sessionCookie);
                
                out.print("{\"success\": true, \"role\": \"" + user.getRole() + "\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"success\": false, \"message\": \"Account suspended or creation failed\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Server error processing token\"}");
        }
        out.flush();
    }

    private String extractJsonField(String json, String field) {
        String key = "\"" + field + "\":";
        int startIndex = json.indexOf(key);
        if (startIndex == -1) return null;
        startIndex += key.length();
        while (json.charAt(startIndex) == ' ' || json.charAt(startIndex) == '"') startIndex++;
        int endIndex = json.indexOf("\"", startIndex);
        if (endIndex == -1) return null;
        return json.substring(startIndex, endIndex);
    }

    private User getOrCreateUser(String email, String defaultUsername) throws SQLException, ClassNotFoundException {
        String selectSql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(selectSql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new User(rs.getInt("id"), rs.getString("username"), rs.getString("email"), rs.getString("password"), rs.getString("role"), rs.getString("account_status"));
                }
            }
        }

        String insertSql = "INSERT INTO users (username, email, password, salt, role) VALUES (?, ?, ?, ?, 'CUSTOMER')";
        String dummyPass = SecurityUtil.generateSalt(); 
        String salt = SecurityUtil.generateSalt();
        String hash = SecurityUtil.hashPassword(dummyPass, salt);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, defaultUsername);
            stmt.setString(2, email);
            stmt.setString(3, hash);
            stmt.setString(4, salt);
            stmt.executeUpdate();
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return new User(generatedKeys.getInt(1), defaultUsername, email, hash, "CUSTOMER", "ACTIVE");
                }
            }
        }
        return null;
    }
}