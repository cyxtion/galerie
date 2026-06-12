package com.gallery.controllers;

import com.gallery.models.Artwork;
import com.gallery.models.User;
import com.gallery.utils.ArtDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@WebServlet("/api/artist/artworks/add")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class AddArtworkServlet extends HttpServlet {
    
    private String getPartValue(Part part) throws IOException {
        if (part == null) return null;
        BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"));
        StringBuilder value = new StringBuilder();
        char[] buffer = new char[1024];
        for (int length; (length = reader.read(buffer)) > 0;) {
            value.append(buffer, 0, length);
        }
        return value.toString();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !"ARTIST".equals(user.getRole())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"success\": false}");
            return;
        }

        String title = getPartValue(request.getPart("title"));
        String category = getPartValue(request.getPart("category"));
        String priceStr = getPartValue(request.getPart("price"));
        Part filePart = request.getPart("imageFile");

        if (title == null || title.trim().isEmpty() || category == null || priceStr == null || filePart == null || filePart.getSize() == 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false}");
            return;
        }

        try {
            double price = Double.parseDouble(priceStr);
            String originalFileName = filePart.getSubmittedFileName();
            String uniqueFileName = UUID.randomUUID().toString() + "_" + originalFileName.replaceAll("[^a-zA-Z0-9.\\-]", "_");

            String uploadPath = request.getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            File targetFile = new File(uploadDir, uniqueFileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            Artwork artwork = new Artwork(0, user.getId(), user.getUsername(), title, category, price, uniqueFileName, "PENDING", "AVAILABLE", false, 0, false, false);
            ArtDAO dao = new ArtDAO();
            
            if (dao.addArtwork(artwork)) {
                response.getWriter().print("{\"success\": true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().print("{\"success\": false}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false}");
        }
    }
}