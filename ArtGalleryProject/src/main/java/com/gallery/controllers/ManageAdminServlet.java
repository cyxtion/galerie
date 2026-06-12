package com.gallery.controllers;

import com.gallery.models.Artwork;
import com.gallery.models.User;
import com.gallery.utils.ArtDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/admin/portfolio")
public class ManageAdminServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) return;

        ArtDAO dao = new ArtDAO();
        dao.cleanupBin();
        List<Artwork> artworks = dao.getAllArtworksAdmin(user.getId());
        PrintWriter out = response.getWriter();
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < artworks.size(); i++) {
            Artwork a = artworks.get(i);
            json.append("{")
                .append("\"id\":").append(a.getId()).append(",")
                .append("\"artist\":\"").append(a.getArtistName() != null ? a.getArtistName().replace("\"", "\\\"") : "").append("\",")
                .append("\"title\":\"").append(a.getTitle().replace("\"", "\\\"")).append("\",")
                .append("\"category\":\"").append(a.getCategory().replace("\"", "\\\"")).append("\",")
                .append("\"price\":").append(a.getPrice()).append(",")
                .append("\"imageUrl\":\"").append(a.getImageUrl().replace("\"", "\\\"")).append("\",")
                .append("\"approvalStatus\":\"").append(a.getApprovalStatus()).append("\",")
                .append("\"salesStatus\":\"").append(a.getSalesStatus()).append("\",")
                .append("\"isPinned\":").append(a.isPinned()).append(",")
                .append("\"popularity\":").append(a.getPopularity()).append(",")
                .append("\"isFavorited\":").append(a.isFavorited()).append(",")
                .append("\"isTrashed\":").append(a.isTrashed())
                .append("}");
            if (i < artworks.size() - 1) json.append(",");
        }
        json.append("]");
        out.print(json.toString());
        out.flush();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) return;

        String idStr = request.getParameter("id");
        String action = request.getParameter("action");
        if (idStr == null || action == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false}");
            return;
        }
        try {
            int id = Integer.parseInt(idStr);
            ArtDAO dao = new ArtDAO();
            boolean success = false;
            
            if ("TRASH".equals(action)) success = dao.softDeleteArtwork(id);
            else if ("RESTORE".equals(action)) success = dao.restoreArtwork(id);
            else if ("HARD_DELETE".equals(action)) success = dao.hardDeleteArtwork(id);
            else if ("HIDE".equals(action)) success = dao.updateSalesStatus(id, "HIDDEN");
            else if ("SHOW".equals(action)) success = dao.updateSalesStatus(id, "AVAILABLE");
            else if ("PIN".equals(action)) success = dao.togglePin(id);
            else if ("FAVORITE".equals(action)) success = dao.toggleFavorite(user.getId(), id);

            if (success) response.getWriter().print("{\"success\": true}");
            else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().print("{\"success\": false}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false}");
        }
    }
}