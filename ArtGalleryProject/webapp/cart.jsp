<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.gallery.models.User" %>
<% User user = (User) session.getAttribute("user"); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cart | Galerie</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body { 
            background: #0a0a0a; 
            color: #fff; 
            font-family: 'Space Grotesk', sans-serif; 
            margin: 0; 
            padding: 40px; 
            overflow-x: hidden;
        }
        
        *, *::before, *::after {
            box-sizing: border-box;
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

        .cart-item { display: flex; background: #000; border: 1px solid #333; padding: 20px; margin-bottom: 15px; align-items: center; }
        .cart-img { width: 80px; height: 80px; object-fit: cover; border: 1px solid #444; margin-right: 20px; transition: filter 0.3s; cursor: pointer; }
        .cart-img:hover { filter: brightness(1.2); }
        .info { flex-grow: 1; }
        .info h3 { margin: 0 0 5px 0; }
        .info p { margin: 0; color: #888; font-size: 14px; }
        .qty-controls { display: flex; align-items: center; margin-right: 20px; border: 1px solid #333; }
        .qty-btn { background: #222; color: #fff; border: none; padding: 10px 15px; font-size: 16px; transition: background 0.3s; cursor: pointer; }
        .qty-btn:hover { background: #444; }
        .qty-val { padding: 0 15px; font-weight: bold; }
        .remove-btn { background: #ff4444; color: #fff; padding: 10px 20px; border: none; font-weight: bold; transition: background 0.3s; cursor: pointer; }
        .remove-btn:hover { background: #cc3333; }
        .summary { background: #111; padding: 30px; border: 1px solid #222; text-align: right; margin-top: 40px; }
        .checkout-btn { background: #44ff44; color: #000; padding: 15px 30px; font-size: 16px; border: none; font-weight: bold; margin-top: 20px; transition: background 0.3s; cursor: pointer; }
        .checkout-btn:hover { background: #22dd22; }

        .ape-footer {
            position: relative;
            background: #000;
            color: #fff;
            margin: 80px -40px -40px -40px; 
            padding: 80px 40px 20px 40px;
            overflow: hidden;
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
            overflow: hidden;
            text-align: center;
            padding: 20px 0;
        }

        .footer-massive {
            font-size: 21vw;
            font-weight: 600;
            text-transform: uppercase;
            line-height: 0.8;
            margin: 0;
            letter-spacing: -2px;
            color: transparent;
            -webkit-text-stroke: 1.5px rgba(255,255,255,0.7);
            user-select: none;
            filter: url(#silk-wave);
            cursor: default;
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
        <h1 class="site-title">CART // SECURE CHECKOUT</h1>
        <div style="display: flex; gap: 15px;">
            <a href="/webapp/store.jsp" class="btn btn-outline">BACK TO STORE</a>
            <% if(user != null) { %>
                <a href="/webapp/api/logout" class="btn btn-outline">LOGOUT</a>
            <% } else { %>
                <a href="/webapp/login.jsp" class="btn">LOGIN</a>
            <% } %>
        </div>
    </header>

    <div id="cart-container"></div>
    <div class="summary" id="summary" style="display: none;">
        <h2>TOTAL: $<span id="total-price">0.00</span></h2>
        <button class="checkout-btn" onclick="checkout()">AUTHORIZE ACQUISITION</button>
    </div>

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
        async function loadCart() {
            try {
                const res = await fetch('/webapp/api/cart');
                const cart = await res.json();
                const container = document.getElementById("cart-container");
                const summary = document.getElementById("summary");
                
                if (cart.length === 0) {
                    container.innerHTML = "<p style='color: #666;'>Your cart is empty.</p>";
                    summary.style.display = "none";
                    return;
                }
                
                container.innerHTML = "";
                let total = 0;
                
                cart.forEach(art => {
                    total += (art.price * art.quantity);
                    const div = document.createElement("div");
                    div.className = "cart-item";
                    div.innerHTML = `
                        <img src='/webapp/assets/images/\${art.imageUrl}' class='cart-img' onclick='window.location.href="/webapp/wall.jsp?focus=\${art.id}"'>
                        <div class='info'>
                            <h3>\${decodeURIComponent(art.title)}</h3>
                            <p>$\${art.price} each</p>
                        </div>
                        <div class='qty-controls'>
                            <button class='qty-btn' onclick='updateQuantity(\${art.id}, -1)'>-</button>
                            <div class='qty-val'>\${art.quantity}</div>
                            <button class='qty-btn' onclick='updateQuantity(\${art.id}, 1)'>+</button>
                        </div>
                        <button class='remove-btn' onclick='removeFromCart(\${art.id})'>REMOVE</button>
                    `;
                    container.appendChild(div);
                });
                
                document.getElementById("total-price").textContent = total.toFixed(2);
                summary.style.display = "block";
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
                if (data.success) loadCart();
            } catch (err) {}
        }

        async function removeFromCart(id) {
            try {
                const res = await fetch('/webapp/api/cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: "action=REMOVE&id=" + id
                });
                const data = await res.json();
                if (data.success) loadCart();
            } catch (err) {}
        }

        async function checkout() {
            try {
                const res = await fetch('/webapp/api/cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: "action=CHECKOUT"
                });
                const data = await res.json();
                if (data.success) {
                    alert("Acquisition Successful! The artwork is now yours.");
                    window.location.href = "/webapp/store.jsp";
                } else {
                    if (data.message === 'LOGIN_REQUIRED') {
                        alert("You must be logged in to checkout.");
                        window.location.href = "/webapp/login.jsp";
                    } else {
                        alert("Checkout failed: " + data.message);
                    }
                }
            } catch (err) {}
        }

        loadCart();

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