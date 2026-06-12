<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.gallery.models.User" %>
<% User user = (User) session.getAttribute("user"); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Artist Studio | Galerie</title>
    <style>
        body { background: #0a0a0a; color: #fff; font-family: sans-serif; margin: 0; padding: 40px; }
        header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #333; padding-bottom: 20px; margin-bottom: 40px; }
        h1 { margin: 0; font-size: 24px; letter-spacing: 2px; }
        .logout-btn { padding: 8px 16px; background: #ff4444; color: #fff; text-decoration: none; font-weight: bold; font-size: 14px; border-radius: 4px; }
        .dashboard-grid { display: grid; grid-template-columns: 1fr 2fr; gap: 40px; margin-bottom: 40px; }
        .panel { background: #111; padding: 30px; border: 1px solid #222; }
        input, select { width: 100%; padding: 12px; background: #000; border: 1px solid #333; color: #fff; margin-bottom: 15px; box-sizing: border-box; }
        input[type="file"] { background: #222; cursor: pointer; padding: 10px; }
        button { padding: 12px 24px; background: #fff; color: #000; border: none; cursor: pointer; font-weight: bold; width: 100%; }
        .filter-bar { display: flex; gap: 15px; margin-bottom: 20px; background: #111; padding: 15px; border: 1px solid #222; align-items: center; }
        .filter-bar input, .filter-bar select { margin-bottom: 0; }
        .portfolio-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
        .art-card { background: #000; border: 1px solid #333; padding: 15px; display: flex; flex-direction: column; }
        .art-img { width: 100%; height: 200px; object-fit: cover; border: 1px solid #222; margin-bottom: 15px; }
        .art-info h3 { margin: 0 0 10px 0; font-size: 18px; }
        .art-info p { margin: 0 0 5px 0; color: #888; font-size: 14px; }
        .card-actions { display: flex; gap: 5px; margin-top: auto; padding-top: 15px; flex-wrap: wrap; }
        .btn-sm { padding: 6px 10px; font-size: 12px; flex-grow: 1; }
        .btn-del { background: #ff4444; color: white; }
        .btn-pin { background: #4444ff; color: white; }
        .btn-fav { background: #ff44ff; color: white; }
        .btn-restore { background: #44ff44; color: black; }
        .fav-active { background: #ffd700; color: black; }
        #bin-toggle { width: auto; background: #333; color: white; }
    </style>
</head>
<body>
    <header>
        <h1>STUDIO // <%= user.getUsername().toUpperCase() %></h1>
        <div><span style="margin-right: 20px; color: #888;">Role: ARTIST</span><a href="/webapp/api/logout" class="logout-btn">LOGOUT</a></div>
    </header>
    <div class="dashboard-grid">
        <div class="panel">
            <h2 style="margin-top: 0;">Submit New Artwork</h2>
            <form id="add-art-form" enctype="multipart/form-data">
                <input type="text" name="title" placeholder="Artwork Title" required>
                <select name="category">
                    <option value="Digital">Digital</option><option value="Painting">Painting</option>
                    <option value="Photography">Photography</option><option value="Sculpture">Sculpture</option>
                </select>
                <input type="number" name="price" placeholder="Price ($)" step="0.01" required>
                <label style="display:block; margin-bottom: 5px; font-size: 12px; color: #888;">Upload Image File (JPG/PNG)</label>
                <input type="file" name="imageFile" accept="image/png, image/jpeg, image/webp" required>
                <button type="submit">SUBMIT FOR APPROVAL</button>
            </form>
        </div>
        <div class="panel">
            <h2 style="margin-top: 0;">System Information</h2>
            <p style="color: #888;">Manage your portfolio. Trashed items are auto-deleted after 7 days.</p>
        </div>
    </div>
    
    <h2 style="margin-top: 0;" id="view-title">My Portfolio Management</h2>
    <div class="filter-bar">
        <button id="bin-toggle" onclick="toggleBin()">VIEW TRASH BIN</button>
        <input type="text" id="search" placeholder="Search titles..." oninput="renderPortfolio()">
        <select id="sort" onchange="renderPortfolio()">
            <option value="date">Date (Newest)</option>
            <option value="alpha">Alphabetical (A-Z)</option>
            <option value="price_asc">Price (Low to High)</option>
            <option value="price_desc">Price (High to Low)</option>
            <option value="popularity">Popularity</option>
        </select>
    </div>
    <div id="portfolio-container" class="portfolio-grid"></div>

    <script>
        let rawData = [];
        let viewingBin = false;

        function toggleBin() {
            viewingBin = !viewingBin;
            document.getElementById("bin-toggle").textContent = viewingBin ? "VIEW ACTIVE PORTFOLIO" : "VIEW TRASH BIN";
            document.getElementById("view-title").textContent = viewingBin ? "Recycle Bin (Auto-deletes in 7 Days)" : "My Portfolio Management";
            renderPortfolio();
        }

        async function loadPortfolio() {
            try {
                const res = await fetch('/webapp/api/artist/portfolio');
                rawData = await res.json();
                renderPortfolio();
            } catch (err) {}
        }

        function renderPortfolio() {
            const container = document.getElementById("portfolio-container");
            const search = document.getElementById("search").value.toLowerCase();
            const sort = document.getElementById("sort").value;
            
            let filtered = rawData.filter(a => a.isTrashed === viewingBin && a.title.toLowerCase().includes(search));
            
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
                const div = document.createElement("div");
                div.className = "art-card";
                
                let actionsHtml = "";
                if (viewingBin) {
                    actionsHtml = "<button class='btn-sm btn-restore' onclick='manageArt(" + art.id + ", \"RESTORE\")'>RESTORE</button>" +
                                  "<button class='btn-sm btn-del' onclick='manageArt(" + art.id + ", \"HARD_DELETE\")'>PERMA-DELETE</button>";
                } else {
                    const favClass = art.isFavorited ? "btn-fav fav-active" : "btn-fav";
                    const favText = art.isFavorited ? "★ UNFAV" : "☆ FAV";
                    actionsHtml = "<button class='btn-sm btn-pin' onclick='manageArt(" + art.id + ", \"PIN\")'>" + (art.isPinned ? "UNPIN" : "PIN") + "</button>" +
                                  "<button class='btn-sm " + favClass + "' onclick='manageArt(" + art.id + ", \"FAVORITE\")'>" + favText + "</button>" +
                                  "<button class='btn-sm btn-del' onclick='manageArt(" + art.id + ", \"TRASH\")'>TRASH</button>";
                }

                div.innerHTML = "<img src='/webapp/assets/images/" + art.imageUrl + "' class='art-img'>" +
                    "<div class='art-info'>" +
                        "<h3>" + (art.isPinned ? "📌 " : "") + art.title + "</h3>" +
                        "<p>Category: " + art.category + " | Price: $" + art.price + "</p>" +
                        "<p>Status: " + art.approvalStatus + " | Views: " + art.popularity + "</p>" +
                    "</div>" +
                    "<div class='card-actions'>" + actionsHtml + "</div>";
                container.appendChild(div);
            });
        }

        async function manageArt(id, action) {
            try {
                const res = await fetch('/webapp/api/artist/portfolio', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: "id=" + id + "&action=" + action
                });
                const data = await res.json();
                if (data.success) loadPortfolio();
            } catch (err) {}
        }

        document.getElementById("add-art-form").addEventListener("submit", async (e) => {
            e.preventDefault();
            const btn = e.target.querySelector("button");
            btn.textContent = "UPLOADING...";
            try {
                const res = await fetch('/webapp/api/artist/artworks/add', { method: 'POST', body: new FormData(e.target) });
                const data = await res.json();
                if (data.success) { e.target.reset(); loadPortfolio(); }
            } catch (err) {}
            btn.textContent = "SUBMIT FOR APPROVAL";
        });

        loadPortfolio();
    </script>
</body>
</html>