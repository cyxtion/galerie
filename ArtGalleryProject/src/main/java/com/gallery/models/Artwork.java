package com.gallery.models;

public class Artwork {
    private int id;
    private int artistId;
    private String artistName;
    private String title;
    private String category;
    private double price;
    private String imageUrl;
    private String approvalStatus;
    private String salesStatus;
    private boolean isPinned;
    private int popularity;
    private boolean isFavorited;
    private boolean isTrashed;
    private int quantity = 1;

    public Artwork() {}

    public Artwork(int id, int artistId, String artistName, String title, String category, double price, String imageUrl, String approvalStatus, String salesStatus, boolean isPinned, int popularity, boolean isFavorited, boolean isTrashed) {
        this.id = id;
        this.artistId = artistId;
        this.artistName = artistName;
        this.title = title;
        this.category = category;
        this.price = price;
        this.imageUrl = imageUrl;
        this.approvalStatus = approvalStatus;
        this.salesStatus = salesStatus;
        this.isPinned = isPinned;
        this.popularity = popularity;
        this.isFavorited = isFavorited;
        this.isTrashed = isTrashed;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getArtistId() { return artistId; }
    public void setArtistId(int artistId) { this.artistId = artistId; }
    public String getArtistName() { return artistName; }
    public void setArtistName(String artistName) { this.artistName = artistName; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }
    public String getSalesStatus() { return salesStatus; }
    public void setSalesStatus(String salesStatus) { this.salesStatus = salesStatus; }
    public boolean isPinned() { return isPinned; }
    public void setPinned(boolean pinned) { this.isPinned = pinned; }
    public int getPopularity() { return popularity; }
    public void setPopularity(int popularity) { this.popularity = popularity; }
    public boolean isFavorited() { return isFavorited; }
    public void setFavorited(boolean favorited) { this.isFavorited = favorited; }
    public boolean isTrashed() { return isTrashed; }
    public void setTrashed(boolean trashed) { this.isTrashed = trashed; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}