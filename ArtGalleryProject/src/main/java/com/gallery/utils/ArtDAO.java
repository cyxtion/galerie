package com.gallery.utils;

import com.gallery.models.Artwork;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ArtDAO {

    private Artwork extractArtwork(ResultSet rs) throws SQLException {
        boolean isFavorited = false;
        try { isFavorited = rs.getBoolean("is_favorited"); } catch (SQLException e) {}
        
        boolean isTrashed = false;
        try { isTrashed = rs.getTimestamp("deleted_at") != null; } catch (SQLException e) {}

        return new Artwork(
            rs.getInt("id"),
            rs.getInt("artist_id"),
            rs.getString("artist_name"),
            rs.getString("title"),
            rs.getString("category"),
            rs.getDouble("price"),
            rs.getString("image_url"),
            rs.getString("approval_status"),
            rs.getString("sales_status"),
            rs.getBoolean("is_pinned"),
            rs.getInt("popularity"),
            isFavorited,
            isTrashed
        );
    }

    public void cleanupBin() {
        String sql = "DELETE FROM artworks WHERE deleted_at < NOW() - INTERVAL 7 DAY";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.executeUpdate();
        } catch (Exception e) {}
    }

    public List<Artwork> getAllArtworks() {
        List<Artwork> artworks = new ArrayList<>();
        String sql = "SELECT a.*, u.username AS artist_name FROM artworks a JOIN users u ON a.artist_id = u.id WHERE a.approval_status = 'APPROVED' AND a.sales_status = 'AVAILABLE' AND a.deleted_at IS NULL";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) artworks.add(extractArtwork(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return artworks;
    }

    public List<Artwork> getPendingArtworks() {
        List<Artwork> artworks = new ArrayList<>();
        String sql = "SELECT a.*, u.username AS artist_name FROM artworks a JOIN users u ON a.artist_id = u.id WHERE a.approval_status = 'PENDING' AND a.deleted_at IS NULL";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) artworks.add(extractArtwork(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return artworks;
    }

    public List<Artwork> getArtworksByArtist(int artistId, int currentUserId) {
        List<Artwork> artworks = new ArrayList<>();
        String sql = "SELECT a.*, u.username AS artist_name, EXISTS(SELECT 1 FROM favorites WHERE artwork_id = a.id AND user_id = ?) AS is_favorited FROM artworks a JOIN users u ON a.artist_id = u.id WHERE a.artist_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, currentUserId);
            stmt.setInt(2, artistId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) artworks.add(extractArtwork(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return artworks;
    }

    public List<Artwork> getAllArtworksAdmin(int currentUserId) {
        List<Artwork> artworks = new ArrayList<>();
        String sql = "SELECT a.*, u.username AS artist_name, EXISTS(SELECT 1 FROM favorites WHERE artwork_id = a.id AND user_id = ?) AS is_favorited FROM artworks a JOIN users u ON a.artist_id = u.id";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, currentUserId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) artworks.add(extractArtwork(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return artworks;
    }

    public boolean addArtwork(Artwork art) {
        String sql = "INSERT INTO artworks (artist_id, title, category, price, image_url) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, art.getArtistId());
            stmt.setString(2, art.getTitle());
            stmt.setString(3, art.getCategory());
            stmt.setDouble(4, art.getPrice());
            stmt.setString(5, art.getImageUrl());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    public boolean updateApprovalStatus(int id, String status) {
        String sql = "UPDATE artworks SET approval_status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    public boolean updateSalesStatus(int id, String status) {
        String sql = "UPDATE artworks SET sales_status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    public boolean softDeleteArtwork(int id) {
        String sql = "UPDATE artworks SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    public boolean restoreArtwork(int id) {
        String sql = "UPDATE artworks SET deleted_at = NULL WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    public boolean hardDeleteArtwork(int id) {
        String sql = "DELETE FROM artworks WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    public boolean togglePin(int id) {
        String sql = "UPDATE artworks SET is_pinned = NOT is_pinned WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    public boolean toggleFavorite(int userId, int artworkId) {
        try (Connection conn = DBUtil.getConnection()) {
            String checkSql = "SELECT 1 FROM favorites WHERE user_id = ? AND artwork_id = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, userId);
                psCheck.setInt(2, artworkId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        try (PreparedStatement psDel = conn.prepareStatement("DELETE FROM favorites WHERE user_id = ? AND artwork_id = ?")) {
                            psDel.setInt(1, userId);
                            psDel.setInt(2, artworkId);
                            psDel.executeUpdate();
                        }
                        try (PreparedStatement psPop = conn.prepareStatement("UPDATE artworks SET popularity = popularity - 1 WHERE id = ?")) {
                            psPop.setInt(1, artworkId);
                            psPop.executeUpdate();
                        }
                    } else {
                        try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO favorites (user_id, artwork_id) VALUES (?, ?)")) {
                            psIns.setInt(1, userId);
                            psIns.setInt(2, artworkId);
                            psIns.executeUpdate();
                        }
                        try (PreparedStatement psPop = conn.prepareStatement("UPDATE artworks SET popularity = popularity + 1 WHERE id = ?")) {
                            psPop.setInt(1, artworkId);
                            psPop.executeUpdate();
                        }
                    }
                    return true;
                }
            }
        } catch (Exception e) { return false; }
    }
}