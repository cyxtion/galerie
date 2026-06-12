package com.gallery.controllers;

import com.gallery.models.Artwork;
import com.gallery.models.User;
import com.gallery.utils.OrderDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/cart")
public class CartServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        List<Artwork> cart = (session != null && session.getAttribute("cart") != null) 
            ? (List<Artwork>) session.getAttribute("cart") : new ArrayList<>();
        
        PrintWriter out = response.getWriter();
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < cart.size(); i++) {
            Artwork a = cart.get(i);
            json.append("{")
                .append("\"id\":").append(a.getId()).append(",")
                .append("\"title\":\"").append(a.getTitle().replace("\"", "\\\"")).append("\",")
                .append("\"price\":").append(a.getPrice()).append(",")
                .append("\"imageUrl\":\"").append(a.getImageUrl().replace("\"", "\\\"")).append("\",")
                .append("\"quantity\":").append(a.getQuantity())
                .append("}");
            if (i < cart.size() - 1) json.append(",");
        }
        json.append("]");
        out.print(json.toString());
        out.flush();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);
        
        String action = request.getParameter("action");
        if (action == null) {
            response.getWriter().print("{\"success\": false}");
            return;
        }

        List<Artwork> cart = (List<Artwork>) session.getAttribute("cart");
        if (cart == null) cart = new ArrayList<>();

        PrintWriter out = response.getWriter();

        if ("ADD".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                String title = request.getParameter("title");
                double price = Double.parseDouble(request.getParameter("price"));
                String imageUrl = request.getParameter("imageUrl");
                
                boolean exists = false;
                for (Artwork art : cart) {
                    if (art.getId() == id) { 
                        art.setQuantity(art.getQuantity() + 1);
                        exists = true; 
                        break; 
                    }
                }
                if (!exists) {
                    Artwork art = new Artwork();
                    art.setId(id);
                    art.setTitle(title);
                    art.setPrice(price);
                    art.setImageUrl(imageUrl);
                    art.setQuantity(1);
                    cart.add(art);
                }
                session.setAttribute("cart", cart);
                out.print("{\"success\": true}");
            } catch (Exception e) { out.print("{\"success\": false}"); }
        } 
        else if ("UPDATE".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                int delta = Integer.parseInt(request.getParameter("delta"));
                
                cart.removeIf(art -> {
                    if (art.getId() == id) {
                        art.setQuantity(art.getQuantity() + delta);
                        return art.getQuantity() <= 0;
                    }
                    return false;
                });
                session.setAttribute("cart", cart);
                out.print("{\"success\": true}");
            } catch (Exception e) { out.print("{\"success\": false}"); }
        }
        else if ("REMOVE".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                cart.removeIf(a -> a.getId() == id);
                session.setAttribute("cart", cart);
                out.print("{\"success\": true}");
            } catch (Exception e) { out.print("{\"success\": false}"); }
        }
        else if ("CHECKOUT".equals(action)) {
            User user = (User) session.getAttribute("user");
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\": false, \"message\": \"LOGIN_REQUIRED\"}");
                return;
            }
            if (cart.isEmpty()) {
                out.print("{\"success\": false, \"message\": \"CART_EMPTY\"}");
                return;
            }
            
            double total = 0;
            for (Artwork a : cart) total += (a.getPrice() * a.getQuantity());
            
            OrderDAO orderDao = new OrderDAO();
            if (orderDao.processCheckout(user.getId(), cart, total)) {
                session.removeAttribute("cart");
                out.print("{\"success\": true}");
            } else {
                out.print("{\"success\": false, \"message\": \"CHECKOUT_FAILED\"}");
            }
        }
    }
}