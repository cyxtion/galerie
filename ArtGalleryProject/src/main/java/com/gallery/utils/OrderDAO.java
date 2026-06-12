package com.gallery.utils;

import com.gallery.models.Artwork;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

public class OrderDAO {
    public boolean processCheckout(int userId, List<Artwork> cartItems, double totalAmount) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String orderSql = "INSERT INTO orders (user_id, total_amount) VALUES (?, ?)";
            int orderId = -1;
            try (PreparedStatement stmt = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, userId);
                stmt.setDouble(2, totalAmount);
                stmt.executeUpdate();
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) orderId = rs.getInt(1);
                }
            }

            if (orderId == -1) {
                conn.rollback();
                return false;
            }

            String updateArtSql = "UPDATE artworks SET sales_status = 'SOLD' WHERE id = ? AND sales_status = 'AVAILABLE'";
            try (PreparedStatement stmt = conn.prepareStatement(updateArtSql)) {
                for (int i = 0; i < cartItems.size(); i++) {
                    stmt.setInt(1, cartItems.get(i).getId());
                    int updated = stmt.executeUpdate();
                    if (updated == 0) {
                        conn.rollback();
                        return false; 
                    }
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) {}
            }
            return false;
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true); 
                    conn.close(); 
                } catch (Exception e) {}
            }
        }
    }
}