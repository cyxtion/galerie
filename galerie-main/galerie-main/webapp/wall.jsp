<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Galerie | Exhibition View</title>
    <style>
        body { 
            margin: 0; 
            padding: 0; 
            background: radial-gradient(circle at 50% 40%, #1a1a1a 0%, #000000 100%);
            font-family: 'Space Grotesk', sans-serif; 
            overflow: hidden; 
            height: 100vh; 
            color: #fff; 
        }

        #particle-canvas {
            position: absolute;
            top: 55%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 15;
            pointer-events: none;
            mix-blend-mode: screen;
        }

        .header { 
            position: absolute; 
            top: 30px; 
            left: 40px; 
            right: 40px; 
            display: flex; 
            justify-content: space-between; 
            z-index: 50; 
        }

        .brand h1 { 
            margin: 0; 
            font-size: 26px; 
            font-weight: bold; 
            letter-spacing: 2px; 
            color: transparent;
            -webkit-text-stroke: 1.2px rgba(255, 255, 255, 0.9);
        }
        
        .brand p { margin: 5px 0 0 0; font-size: 13px; opacity: 0.7; }
        .nav-links a { color: #fff; text-decoration: none; margin-left: 25px; font-size: 13px; font-weight: bold; opacity: 0.7; transition: opacity 0.3s; }
        .nav-links a:hover { opacity: 1; }

        .gallery-viewport { 
            position: absolute; 
            top: 0; 
            left: 0; 
            width: 100vw; 
            height: 100vh; 
            display: flex; 
            justify-content: center;
            align-items: flex-start;
            padding-top: 10vh;
            box-sizing: border-box;
            z-index: 10;
        }

        .art-station { 
            position: absolute; 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            transition: transform 0.8s cubic-bezier(0.2, 0.8, 0.2, 1), opacity 0.8s ease, filter 0.8s ease; 
            will-change: transform, opacity, filter;
        }

        @keyframes glitchBlink {
            0%    { opacity: 1; filter: brightness(1); }
            45%   { opacity: 1; filter: brightness(1); }
            45.2% { opacity: 0.6; filter: brightness(0.7); }
            45.5% { opacity: 1; filter: brightness(1.1); }
            45.8% { opacity: 0.5; filter: brightness(0.6); }
            46%   { opacity: 1; filter: brightness(1); }
            85%   { opacity: 1; filter: brightness(1); }
            85.1% { opacity: 0.7; filter: brightness(0.8); }
            85.3% { opacity: 1; filter: brightness(1); }
            100%  { opacity: 1; filter: brightness(1); }
        }

        .lightbulb {
            width: 25px;
            height: 25px;
            background: #fff;
            border-radius: 50%;
            box-shadow: 0 0 20px 5px rgba(255,255,255,0.9), 0 20px 60px 20px rgba(255,255,255,0.4);
            margin-bottom: 50px;
            z-index: 3;
            opacity: 0;
            transition: opacity 0.8s ease;
        }

        .wall-glow {
            position: absolute;
            top: 55%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 45vw;
            height: 65vh;
            background: radial-gradient(ellipse at center, rgba(255,255,255,0.12) 0%, rgba(255,255,255,0.03) 50%, transparent 80%);
            filter: blur(40px);
            z-index: 0;
            opacity: 0;
            transition: opacity 0.8s ease;
            pointer-events: none;
        }

        .art-station.active .lightbulb,
        .art-station.active .wall-glow { 
            opacity: 1; 
            animation: glitchBlink 20s infinite linear;
        }

        .frame { 
            position: relative; 
            z-index: 1; 
            background: #e0ddd5;
            border: 4px solid #050505;
            box-shadow: 0 30px 60px rgba(0,0,0,0.9), 0 0 100px rgba(0,0,0,0.7); 
            cursor: pointer;
            transition: transform 0.5s cubic-bezier(0.2, 0.8, 0.2, 1), box-shadow 0.5s ease;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .frame:hover {
            transform: scale(1.03) translateY(-8px);
            box-shadow: 0 40px 80px rgba(0,0,0,1), 0 0 80px rgba(255, 240, 220, 0.08);
        }

        .frame img { 
            display: block; 
            height: 55vh; 
            width: auto;
            max-width: 40vw; 
            object-fit: contain; 
        }

        .nav-arrows { 
            position: absolute; 
            top: 50%; 
            width: 100%; 
            display: flex; 
            justify-content: space-between; 
            transform: translateY(-50%); 
            z-index: 20; 
            pointer-events: none; 
        }

        .arrow { 
            background: none; 
            border: none; 
            color: rgba(255,255,255,0.3); 
            font-size: 60px; 
            font-weight: 100; 
            cursor: pointer; 
            pointer-events: auto; 
            padding: 0 50px; 
            transition: transform 0.3s, color 0.3s; 
        }

        .arrow:hover { 
            transform: scale(1.2); 
            color: #fff; 
        }

        .info-panel { 
            position: absolute; 
            bottom: 50px; 
            width: 100%; 
            text-align: center; 
            z-index: 20; 
            opacity: 0; 
            transform: translateY(15px); 
            transition: opacity 0.6s ease, transform 0.6s ease; 
        }

        .info-panel.visible { 
            opacity: 1; 
            transform: translateY(0); 
        }

        .info-title { font-size: 22px; font-weight: bold; margin: 0 0 8px 0; letter-spacing: 0.5px; text-shadow: 0 2px 10px rgba(0,0,0,0.8); }
        .info-meta { font-size: 13px; margin: 0; opacity: 0.6; letter-spacing: 1px; text-transform: uppercase; }
        
        .counter { position: absolute; bottom: 40px; left: 40px; font-size: 14px; font-weight: bold; opacity: 0.4; letter-spacing: 2px; z-index: 20; }
    </style>
</head>
<body>
    <div class="header">
        <div class="brand">
            <h1>GALERIE</h1>
            <p>PROJECT in 2026</p>
        </div>
        <div class="nav-links">
            <a href="/webapp/home">BACK TO GRID</a>
            <a href="/webapp/store.jsp">STORE</a>
            <a href="/webapp/cart.jsp">CART</a>
        </div>
    </div>
    
    <canvas id="particle-canvas"></canvas>

    <div class="gallery-viewport" id="viewport"></div>

    <div class="nav-arrows">
        <button class="arrow" onclick="move(-1)">&#10094;</button>
        <button class="arrow" onclick="move(1)">&#10095;</button>
    </div>

    <div class="info-panel" id="info">
        <p class="info-title" id="info-title"></p>
        <p class="info-meta" id="info-meta"></p>
    </div>

    <div class="counter" id="counter">0 / 0</div>

    <script>
        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');
        let particles = [];
        let resizeTimeout;

        function resizeCanvas() {
            canvas.width = window.innerWidth * 0.45;
            canvas.height = window.innerHeight * 0.65;
        }

        function initParticles() {
            particles = [];
            for (let i = 0; i < 15; i++) {
                particles.push({
                    x: Math.random() * canvas.width,
                    y: Math.random() * canvas.height,
                    radiusX: Math.random() * 2.5 + 1,
                    radiusY: Math.random() * 1 + 0.5,
                    rotation: Math.random() * Math.PI,
                    vx: (Math.random() - 0.5) * 0.2,
                    vy: Math.random() * 0.4 + 0.1,
                    alpha: Math.random() * 0.4 + 0.1,
                    pulse: Math.random() * 0.02
                });
            }
        }

        function animateParticles() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            particles.forEach(p => {
                p.x += p.vx;
                p.y -= p.vy;
                p.rotation += 0.015;
                p.alpha += Math.sin(Date.now() * p.pulse) * 0.01;

                if (p.y < -10) p.y = canvas.height + 10;
                if (p.x < -10) p.x = canvas.width + 10;
                if (p.x > canvas.width + 10) p.x = -10;

                let currentAlpha = Math.max(0, Math.min(0.6, p.alpha));
                
                ctx.save();
                ctx.translate(p.x, p.y);
                ctx.rotate(p.rotation);
                ctx.fillStyle = `rgba(255, 240, 220, \${currentAlpha})`;
                ctx.fillRect(-p.radiusX/2, -p.radiusY/2, p.radiusX, p.radiusY);
                ctx.restore();
            });
            requestAnimationFrame(animateParticles);
        }

        window.addEventListener('resize', () => {
            clearTimeout(resizeTimeout);
            resizeTimeout = setTimeout(() => {
                resizeCanvas();
                initParticles();
                updateView();
            }, 100);
        });

        resizeCanvas();
        initParticles();
        animateParticles();

        let artworks = [];
        let currentIndex = 0;
        const viewport = document.getElementById('viewport');

        async function initGallery() {
            try {
                const res = await fetch('/webapp/api/artworks');
                artworks = await res.json();
                
                if(artworks.length === 0) {
                    viewport.innerHTML = "<h2 style='text-align:center; margin-top:20vh;'>No artworks available.</h2>";
                    return;
                }

                artworks.forEach((art, index) => {
                    const station = document.createElement('div');
                    station.className = 'art-station';
                    station.id = 'station-' + index;
                    
                    station.innerHTML = `
                        <div class="lightbulb"></div>
                        <div class="wall-glow"></div>
                        <div class="frame" onclick="window.location.href='/webapp/store.jsp'">
                            <img src="/webapp/assets/images/\${art.imageUrl}" alt="Artwork">
                        </div>
                    `;
                    viewport.appendChild(station);
                });

                const urlParams = new URLSearchParams(window.location.search);
                const focusId = urlParams.get('focus');
                if (focusId) {
                    const targetIdx = artworks.findIndex(a => a.id == focusId);
                    if (targetIdx !== -1) currentIndex = targetIdx;
                }
                
                updateView();
            } catch (e) {
            }
        }

        function move(dir) {
            if(artworks.length === 0) return;
            currentIndex = (currentIndex + dir + artworks.length) % artworks.length;
            updateView();
        }

        function updateView() {
            if(artworks.length === 0) return;
            
            const length = artworks.length;
            const spacing = window.innerWidth * 0.35; 

            artworks.forEach((art, index) => {
                const station = document.getElementById('station-' + index);
                
                let diff = index - currentIndex;
                if (diff > length / 2) diff -= length;
                else if (diff < -length / 2) diff += length;
                
                if (Math.abs(diff) > 3) {
                    station.style.opacity = '0';
                    station.style.pointerEvents = 'none';
                    station.style.filter = 'brightness(0)';
                } else {
                    station.style.opacity = (diff === 0) ? '1' : '0.4';
                    station.style.pointerEvents = (diff === 0) ? 'auto' : 'none';
                    station.style.filter = (diff === 0) ? 'brightness(1)' : 'brightness(0.2) contrast(1.1)';
                }
                
                const scale = (diff === 0) ? 1 : 0.85;
                station.style.transform = `translateX(\${diff * spacing}px) scale(\${scale})`;
                
                if (diff === 0) station.classList.add('active');
                else station.classList.remove('active');
            });

            const art = artworks[currentIndex];
            const infoPanel = document.getElementById('info');
            
            infoPanel.classList.remove('visible');
            setTimeout(() => {
                document.getElementById('info-title').textContent = art.title;
                document.getElementById('info-meta').textContent = `\${art.artist} | \${art.category} | $\${art.price}`;
                infoPanel.classList.add('visible');
            }, 300);

            document.getElementById('counter').textContent = `\${currentIndex + 1} / \${artworks.length}`;
        }

        document.addEventListener('keydown', (e) => {
            if(e.key === 'ArrowLeft') move(-1);
            if(e.key === 'ArrowRight') move(1);
        });

        initGallery();
    </script>
</body>
</html>