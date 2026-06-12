<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.gallery.models.User" %>
<% User user = (User) session.getAttribute("user"); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Store | Galerie</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        html, body { 
            background: #0a0a0a !important; 
            color: #fff !important; 
            font-family: 'Space Grotesk', sans-serif !important; 
            margin: 0 !important; 
            padding: 40px !important; 
            overflow-y: auto !important; 
            overflow-x: hidden !important;
            height: auto !important;
            cursor: default !important;
        }
        
        * {
            box-sizing: border-box;
            cursor: default !important;
        }

        a, button, .art-img, .qty-btn, .add-btn, .remove-btn, .checkout-btn, .btn {
            cursor: pointer !important;
        }

        header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            border-bottom: 1px solid #333; 
            padding-bottom: 20px; 
            margin-bottom: 40px; 
        }

        .site-title { 
            margin: 0; 
            font-size: 32px; 
            letter-spacing: 2px; 
            color: transparent;
            -webkit-text-stroke: 1.2px rgba(255, 255, 255, 0.9);
        }

        .btn { padding: 8px 16px; background: #fff; color: #000; text-decoration: none; font-weight: bold; font-size: 14px; border-radius: 4px; border: none; transition: 0.3s; }
        .btn:hover { background: #ccc; }
        .btn-outline { background: transparent; color: #fff; border: 1px solid #fff; }
        .btn-outline:hover { background: #fff; color: #000; }

        .portfolio-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; min-height: 50vh; }
        .art-card { background: #000; border: 1px solid #333; padding: 15px; display: flex; flex-direction: column; transition: transform 0.3s, border-color 0.3s; }
        .art-card:hover { transform: translateY(-5px); border-color: #666; }
        .art-img { width: 100%; height: 200px; object-fit: cover; border: 1px solid #222; margin-bottom: 15px; transition: filter 0.3s; }
        .art-img:hover { filter: brightness(1.2); }
        .art-info h3 { margin: 0 0 10px 0; font-size: 18px; }
        .art-info p { margin: 0 0 15px 0; color: #888; font-size: 14px; }
        
        .add-btn { width: 100%; background: #44ff44; color: #000; padding: 10px; border: none; font-weight: bold; margin-top: auto; transition: background 0.3s; }
        .add-btn:hover { background: #22dd22; }
        .qty-controls { display: flex; width: 100%; margin-top: auto; }
        .qty-btn { flex: 1; background: #fff; color: #000; border: none; font-weight: bold; padding: 10px; font-size: 18px; transition: background 0.3s; }
        .qty-btn:hover { background: #ddd; }
        .qty-display { flex: 2; background: #222; color: #fff; display: flex; align-items: center; justify-content: center; font-weight: bold; border-left: 1px solid #000; border-right: 1px solid #000; }
        
        .ape-footer {
            position: relative;
            background: #000;
            color: #fff;
            margin: 80px -40px -40px -40px; 
            padding: 80px 40px 20px 40px;
            display: flex;
            flex-direction: column;
            border-top: 1px solid #222;
        }

        .footer-top-row {
            display: flex;
            justify-content: flex-end;
            margin-bottom: 40px;
            position: relative;
            z-index: 10;
        }

        .footer-links-grid {
            display: flex;
            gap: 80px;
            text-align: left;
        }

        .footer-links-grid h4 {
            font-size: 26px;
            text-transform: uppercase;
            margin: 0 0 24px 0;
            font-weight: 400;
            letter-spacing: 1px;
            color: #fff;
        }

        .footer-links-grid ul { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 16px; }
        
        .footer-links-grid a {
            color: #fff;
            text-decoration: none;
            font-size: 12px;
            text-transform: uppercase;
            font-family: monospace;
            letter-spacing: 1.5px;
            transition: opacity 0.3s;
            opacity: 0.6;
        }

        .footer-links-grid a:hover { opacity: 1; }

        .footer-massive-wrapper {
            position: relative;
            width: 100%;
            text-align: center;
            padding: 40px 0;
            overflow: visible;
        }

        .footer-massive {
            font-size: clamp(80px, 16vw, 220px);
            font-weight: 600;
            text-transform: uppercase;
            line-height: 1;
            margin: 0;
            letter-spacing: -2px;
            color: transparent;
            -webkit-text-stroke: 1.5px rgba(255,255,255,0.7);
            user-select: none;
            filter: url(#silk-wave);
            display: inline-block;
        }

        .footer-bottom-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #222;
            padding-top: 24px;
            font-family: monospace;
            font-size: 11px;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            position: relative;
            z-index: 10;
        }

        .footer-bottom-links a { 
            color: #888; 
            text-decoration: none; 
            margin-left: 24px; 
            transition: color 0.3s; 
        }

        .footer-bottom-links a:hover { color: #fff; }

        @media (max-width: 768px) {
            body { padding: 20px !important; margin-bottom: -20px !important; }
            .ape-footer { margin: 60px -20px -20px -20px; padding: 60px 20px 20px 20px; }
            .footer-links-grid { flex-direction: column; gap: 40px; }
            .footer-top-row { justify-content: flex-start; }
            .footer-bottom-row { flex-direction: column; gap: 15px; align-items: flex-start; }
            .footer-bottom-links a { margin-left: 0; margin-right: 24px; }
        }
    </style>
</head>
<body>

    <svg style="position: absolute; width: 0; height: 0; pointer-events: none;">
        <filter id="silk-wave" x="-20%" y="-20%" width="140%" height="140%">
            <feTurbulence type="fractalNoise" baseFrequency="0.015 0.02" numOctaves="3" result="noise" id="turb"/>
            <feDisplacementMap in="SourceGraphic" in2="noise" scale="0" xChannelSelector="R" yChannelSelector="G" id="disp"/>
        </filter>
    </svg>

    <header>
        <h1 class="site-title">GALERIE // ACQUISITIONS</h1>
        <div style="display: flex; gap: 15px;">
            <a href="/webapp/home" class="btn btn-outline">WEBGL VIEW</a>
            <a href="/webapp/cart.jsp" class="btn">VIEW CART</a>
            <% if(user != null) { %>
                <a href="/webapp/api/logout" class="btn btn-outline">LOGOUT</a>
            <% } else { %>
                <a href="/webapp/login.jsp" class="btn">LOGIN</a>
            <% } %>
        </div>
    </header>

    <div id="gallery-container" class="portfolio-grid"></div>

    <footer class="ape-footer">
        <div class="footer-top-row">
            <div class="footer-links-grid">
                <div>
                    <h4>Exhibitions</h4>
                    <ul>
                        <li><a href="#">Current Viewings</a></li>
                        <li><a href="#">Upcoming Seasons</a></li>
                        <li><a href="#">Past Archives</a></li>
                        <li><a href="#">Virtual Tours</a></li>
                    </ul>
                </div>
                <div>
                    <h4>Artists</h4>
                    <ul>
                        <li><a href="#">Represented</a></li>
                        <li><a href="#">Emerging Talent</a></li>
                        <li><a href="#">Guest Curators</a></li>
                        <li><a href="#">Submit Portfolio</a></li>
                    </ul>
                </div>
                <div>
                    <h4>Galerie</h4>
                    <ul>
                        <li><a href="#">Our Vision</a></li>
                        <li><a href="#">Press & Media</a></li>
                        <li><a href="#">Location & Hours</a></li>
                        <li><a href="#">Private Acquisitions</a></li>
                    </ul>
                </div>
            </div>
        </div>
        
        <div class="footer-massive-wrapper">
            <h2 class="footer-massive" id="fluid-text">GALERIE</h2>
        </div>
        
        <div class="footer-bottom-row">
            <span>© 2026 Galerie Contemporary Art</span>
            <div class="footer-bottom-links">
                <a href="#">Terms of Service</a>
                <a href="#">Privacy Notice</a>
                <a href="#">Cookie Policy</a>
            </div>
        </div>
    </footer>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script>
        let cartMap = {};

        async function fetchState() {
            try {
                const [storeRes, cartRes] = await Promise.all([
                    fetch('/webapp/api/artworks'),
                    fetch('/webapp/api/cart')
                ]);
                const artworks = await storeRes.json();
                const cart = await cartRes.json();

                cartMap = {};
                cart.forEach(item => {
                    cartMap[item.id] = item.quantity;
                });

                renderStore(artworks);
            } catch (err) {}
        }

        function renderStore(artworks) {
            const container = document.getElementById("gallery-container");
            container.innerHTML = "";
            
            if (artworks.length === 0) {
                container.innerHTML = "<p style='color: #666;'>No available inventory.</p>";
                return;
            }
            
            artworks.forEach(art => {
                const div = document.createElement("div");
                div.className = "art-card";
                
                let controlHtml = "";
                if (cartMap[art.id]) {
                    controlHtml = `
                        <div class='qty-controls'>
                            <button class='qty-btn' onclick='updateQuantity(\${art.id}, -1)'>-</button>
                            <div class='qty-display'>\${cartMap[art.id]} IN CART</div>
                            <button class='qty-btn' onclick='updateQuantity(\${art.id}, 1)'>+</button>
                        </div>
                    `;
                } else {
                    controlHtml = `<button class='add-btn' onclick='addToCart(\${art.id}, "\${encodeURIComponent(art.title)}", \${art.price}, "\${art.imageUrl}")'>ADD TO CART</button>`;
                }

                div.innerHTML = `
                    <img src='/webapp/assets/images/\${art.imageUrl}' class='art-img' onclick='window.location.href="/webapp/wall.jsp?focus=\${art.id}"'>
                    <div class='art-info'>
                        <h3>\${art.title}</h3>
                        <p>Artist: \${art.artist} | Price: $\${art.price}</p>
                    </div>
                    \${controlHtml}
                `;
                container.appendChild(div);
            });
        }

        async function addToCart(id, title, price, imageUrl) {
            try {
                const res = await fetch('/webapp/api/cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: "action=ADD&id=" + id + "&title=" + title + "&price=" + price + "&imageUrl=" + imageUrl
                });
                const data = await res.json();
                if (data.success) fetchState();
            } catch (err) {}
        }

        async function updateQuantity(id, delta) {
            try {
                const res = await fetch('/webapp/api/cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: "action=UPDATE&id=" + id + "&delta=" + delta
                });
                const data = await res.json();
                if (data.success) fetchState();
            } catch (err) {}
        }

        fetchState();

        const fluidText = document.getElementById('fluid-text');
        const dispMap = document.getElementById('disp');
        const turb = document.getElementById('turb');

        let time = 0;
        gsap.ticker.add(() => {
            time += 0.02;
            const freqY = 0.02 + Math.sin(time) * 0.005;
            turb.setAttribute('baseFrequency', `0.015 ${freqY}`);
        });

        fluidText.addEventListener('mousemove', () => {
            gsap.to(dispMap, {
                attr: { scale: 35 },
                duration: 0.5,
                ease: "power2.out"
            });
        });

        fluidText.addEventListener('mouseleave', () => {
            gsap.to(dispMap, {
                attr: { scale: 0 },
                duration: 1.2,
                ease: "elastic.out(1, 0.3)"
            });
        });
    </script>
</body>
</html>