<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.gallery.models.User" %>
<% User user = (User) session.getAttribute("user"); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Galerie</title>
    <style>
        body { background: #0a0a0a; color: #fff; font-family: sans-serif; margin: 0; padding: 40px; }
        header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #333; padding-bottom: 20px; margin-bottom: 40px; }
        h1 { margin: 0; font-size: 24px; letter-spacing: 2px; }
        .logout-btn { padding: 8px 16px; background: #ff4444; color: #fff; text-decoration: none; font-weight: bold; font-size: 14px; border-radius: 4px; }
        .dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 40px; margin-bottom: 40px; }
        .panel { background: #111; padding: 30px; border: 1px solid #222; }
        .queue-item { display: flex; background: #000; border: 1px solid #333; padding: 20px; margin-bottom: 15px; align-items: center; }
        .queue-img { width: 100px; height: 100px; object-fit: cover; border: 1px solid #444; margin-right: 20px; }
        .info { flex-grow: 1; }
        .info h3 { margin: 0 0 5px 0; }
        .info p { margin: 0; color: #888; font-size: 14px; }
        .actions { display: flex; gap: 10px; }
        .approve-btn { padding: 8px 16px; background: #44ff44; color: #000; border: none; cursor: pointer; font-weight: bold; }
        .reject-btn { padding: 8px 16px; background: #ff4444; color: #fff; border: none; cursor: pointer; font-weight: bold; }
        
        .filter-bar { display: flex; gap: 15px; margin-bottom: 20px; background: #111; padding: 15px; border: 1px solid #222; align-items: center; }
        .filter-bar input, .filter-bar select { padding: 12px; background: #000; border: 1px solid #333; color: #fff; margin-bottom: 0; }
        .portfolio-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
        .art-card { background: #000; border: 1px solid #333; padding: 15px; display: flex; flex-direction: column; }
        .art-img { width: 100%; height: 200px; object-fit: cover; border: 1px solid #222; margin-bottom: 15px; }
        .art-info h3 { margin: 0 0 10px 0; font-size: 18px; }
        .art-info p { margin: 0 0 5px 0; color: #888; font-size: 14px; }
        .card-actions { display: flex; gap: 5px; margin-top: auto; padding-top: 15px; flex-wrap: wrap; }
        .btn-sm { padding: 6px 10px; font-size: 12px; flex-grow: 1; border: none; cursor: pointer; font-weight: bold; }
        .btn-del { background: #ff4444; color: white; }
        .btn-pin { background: #4444ff; color: white; }
        .btn-fav { background: #ff44ff; color: white; }
        .btn-hide { background: #ffaa00; color: black; }
        .btn-restore { background: #44ff44; color: black; }
        .fav-active { background: #ffd700; color: black; }
        #bin-toggle { width: auto; background: #333; color: white; padding: 12px 24px; cursor: pointer; border: none; font-weight: bold; }
    </style>
</head>
<body>
    <header>
        <h1>GALERIE // CENTRAL CONTROL</h1>
        <div><span style="margin-right: 20px; color: #888;">Administrator: <%= user.getUsername() %></span><a href="/webapp/api/logout" class="logout-btn">LOGOUT</a></div>
    </header>

    <div class="dashboard-grid">
        <div class="panel">
            <h2 style="margin-top: 0;">Artwork Approval Queue</h2>
            <div id="queue-container"></div>
        </div>
        <div class="panel">
            <h2 style="margin-top: 0;">System Performance</h2>
            <p style="color: #888;">Identity Provider: <strong>Google Identity Services</strong></p>
            <p style="color: #888;">Encryption Engine: <strong>PBKDF2-HMAC-SHA256</strong></p>
        </div>
    </div>

    <h2 style="margin-top: 0;" id="view-title">Global Database Management</h2>
    <div class="filter-bar">
        <button id="bin-toggle" onclick="toggleBin()">VIEW TRASH BIN</button>
        <input type="text" id="search" placeholder="Search titles or artists..." oninput="renderGallery()">
        <select id="sort" onchange="renderGallery()">
            <option value="date">Date (Newest)</option>
            <option value="alpha">Alphabetical (A-Z)</option>
            <option value="price_asc">Price (Low to High)</option>
            <option value="price_desc">Price (High to Low)</option>
            <option value="popularity">Popularity</option>
        </select>
    </div>
    <div id="gallery-container" class="portfolio-grid"></div>

    <script>
        async function loadQueue() {
            const container = document.getElementById("queue-container");
            container.innerHTML = "";
            try {
                const res = await fetch('/webapp/api/admin/artworks/queue');
                const artworks = await res.json();
                if (artworks.length === 0) {
                    container.innerHTML = "<p style='color: #666;'>No pending submissions.</p>";
                    return;
                }
                artworks.forEach(art => {
                    const div = document.createElement("div");
                    div.className = "queue-item";
                    div.innerHTML = "<img src='/webapp/assets/images/" + art.imageUrl + "' class='queue-img'>" +
                        "<div class='info'><h3>" + art.title + "</h3><p>Artist: " + art.artist + " | Price: $" + art.price + "</p></div>" +
                        "<div class='actions'>" +
                            "<button class='approve-btn' onclick='reviewArtwork(" + art.id + ", \"APPROVE\")'>APPROVE</button>" +
                            "<button class='reject-btn' onclick='reviewArtwork(" + art.id + ", \"REJECT\")'>REJECT</button>" +
                        "</div>";
                    container.appendChild(div);
                });
            } catch (err) {}
        }

        async function reviewArtwork(id, action) {
            try {
                const res = await fetch('/webapp/api/admin/artworks/queue', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: "id=" + id + "&action=" + action });
                const data = await res.json();
                if (data.success) { loadQueue(); loadGallery(); }
            } catch (err) {}
        }

        let rawData = [];
        let viewingBin = false;

        function toggleBin() {
            viewingBin = !viewingBin;
            document.getElementById("bin-toggle").textContent = viewingBin ? "VIEW ACTIVE DATABASE" : "VIEW TRASH BIN";
            document.getElementById("view-title").textContent = viewingBin ? "Recycle Bin (Auto-deletes in 7 Days)" : "Global Database Management";
            renderGallery();
        }

        async function loadGallery() {
            try {
                const res = await fetch('/webapp/api/admin/portfolio');
                rawData = await res.json();
                renderGallery();
            } catch (err) {}
        }

        function renderGallery() {
            const container = document.getElementById("gallery-container");
            const search = document.getElementById("search").value.toLowerCase();
            const sort = document.getElementById("sort").value;
            
            let filtered = rawData.filter(a => a.isTrashed === viewingBin && (a.title.toLowerCase().includes(search) || a.artist.toLowerCase().includes(search)));
            
            filtered.sort((a, b) => {
                if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
                if (sort === 'date') return b.id - a.id;
                if (sort === 'alpha') return a.title.localeCompare(b.title);
                if (sort === 'price_asc') return a.price - b.price;
                if (sort === 'price_desc') return b.price - a.price;
                if (sort === 'popularity') return b.popularity - a.popularity;
                return 0;
            });

            container.innerHTML = "";
            filtered.forEach(art => {
                const isHidden = art.salesStatus === 'HIDDEN';
                const div = document.createElement("div");
                div.className = "art-card";
                div.style.opacity = isHidden ? "0.5" : "1";
                
                let actionsHtml = "";
                if (viewingBin) {
                    actionsHtml = "<button class='btn-sm btn-restore' onclick='manageGallery(" + art.id + ", \"RESTORE\")'>RESTORE</button>" +
                                  "<button class='btn-sm btn-del' onclick='manageGallery(" + art.id + ", \"HARD_DELETE\")'>PERMA-DELETE</button>";
                } else {
                    const favClass = art.isFavorited ? "btn-fav fav-active" : "btn-fav";
                    const favText = art.isFavorited ? "★ UNFAV" : "☆ FAV";
                    actionsHtml = "<button class='btn-sm btn-pin' onclick='manageGallery(" + art.id + ", \"PIN\")'>" + (art.isPinned ? "UNPIN" : "PIN") + "</button>" +
                                  "<button class='btn-sm " + favClass + "' onclick='manageGallery(" + art.id + ", \"FAVORITE\")'>" + favText + "</button>" +
                                  "<button class='btn-sm btn-hide' onclick='manageGallery(" + art.id + ", \"" + (isHidden ? "SHOW" : "HIDE") + "\")'>" + (isHidden ? "UNHIDE" : "HIDE") + "</button>" +
                                  "<button class='btn-sm btn-del' onclick='manageGallery(" + art.id + ", \"TRASH\")'>TRASH</button>";
                }

                div.innerHTML = "<img src='/webapp/assets/images/" + art.imageUrl + "' class='art-img'>" +
                    "<div class='art-info'>" +
                        "<h3>" + (art.isPinned ? "📌 " : "") + art.title + "</h3>" +
                        "<p>Artist: " + art.artist + " | Price: $" + art.price + "</p>" +
                        "<p>State: " + art.approvalStatus + " / " + art.salesStatus + " | Pop: " + art.popularity + "</p>" +
                    "</div>" +
                    "<div class='card-actions'>" + actionsHtml + "</div>";
                container.appendChild(div);
            });
        }

        async function manageGallery(id, action) {
            try {
                const res = await fetch('/webapp/api/admin/portfolio', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: "id=" + id + "&action=" + action });
                const data = await res.json();
                if (data.success) loadGallery();
            } catch (err) {}
        }

        loadQueue();
        loadGallery();
    </script>
</body>
</html>