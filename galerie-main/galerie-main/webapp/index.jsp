<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Galerie</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after {
            cursor: none !important;
        }

        .brand h1 {
            color: transparent !important;
            -webkit-text-stroke: 1.2px rgba(255, 255, 255, 0.9) !important;
            text-shadow: none !important;
            letter-spacing: 2px;
        }
    </style>
</head>
<body>
    <div class="cursor">
        <p class="cursor-paragraph"></p>
    </div>

    <div class="gallery-canvas-wrap" data-cursor="ZOOM TO SEE THE ART">
        <canvas id="gallery-canvas"></canvas>
    </div>

    <main class="ui-container">
        <header class="top-container">
            <div class="brand">
                <h1 data-cursor="GO HOME">GALERIE</h1>
                <p>A FUTURISTIC MUSEUM<br>OF EVERYTHING ANCIENT</p>
            </div>
            
            <nav class="menu">
                <p class="menu-title">INDEX</p>
                <div class="menu-links">
                    <a href="cart.jsp" class="nav-link" data-cursor="VIEW CART">CART</a>
                    <a href="login.jsp" class="nav-link" data-cursor="AUTHENTICATE">LOGIN</a>
                </div>
            </nav>
        </header>

        <footer class="bottom-container">
            <div class="location">
                <p>DL, IN</p>
                <p id="clock">00:00:00 GMT+5</p>
            </div>
            
            <div class="credits">
                <p>DRAG / SCROLL TO EXPLORE</p>
            </div>
        </footer>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/pixi.js@7.x/dist/pixi.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
    <script src="assets/js/app.js"></script>
</body>
</html>