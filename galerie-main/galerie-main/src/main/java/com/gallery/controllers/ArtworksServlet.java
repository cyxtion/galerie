package com.gallery.controllers;

import com.gallery.models.Artwork;
import com.gallery.utils.ArtDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/artworks")
public class ArtworksServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        ArtDAO dao = new ArtDAO();
        List<Artwork> artworks = dao.getAllArtworks();

        PrintWriter out = response.getWriter();
        StringBuilder json = new StringBuilder("[");
        
        for (int i = 0; i < artworks.size(); i++) {
            Artwork a = artworks.get(i);
            String title = a.getTitle() != null ? a.getTitle().replace("\"", "\\\"").replace("\r", "").replace("\n", "") : "Untitled";
            String artist = a.getArtistName() != null ? a.getArtistName().replace("\"", "\\\"") : "Unknown";
            String category = a.getCategory() != null ? a.getCategory().replace("\"", "\\\"").replace("\r", "").replace("\n", "") : "None";
            String imageUrl = a.getImageUrl() != null ? a.getImageUrl().replace("\"", "\\\"") : "";
            
            json.append("{")
                .append("\"id\":").append(a.getId()).append(",")
                .append("\"artist\":\"").append(artist).append("\",")
                .append("\"title\":\"").append(title).append("\",")
                .append("\"category\":\"").append(category).append("\",")
                .append("\"price\":").append(a.getPrice()).append(",")
                .append("\"imageUrl\":\"").append(imageUrl).append("\"")
                .append("}");
            if (i < artworks.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        out.print(json.toString());
        out.flush();
    }
}