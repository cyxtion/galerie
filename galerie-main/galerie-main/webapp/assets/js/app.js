const cursorStyle = document.createElement('style');
cursorStyle.innerHTML = `* { cursor: none !important; }`;
document.head.appendChild(cursorStyle);

const DEFAULT_TZ = "Asia/Calcutta";
const formatters = new Map();

const getFormatter = (tz) => {
    if (!formatters.has(tz)) {
        formatters.set(tz, new Intl.DateTimeFormat([], {
            timeZone: tz,
            timeZoneName: "short",
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: false,
        }));
    }
    return formatters.get(tz);
};

const parseTime = (str) => str.match(/(\d+):(\d+):(\d+)\s*([\w+]+)/);

const updateTime = () => {
    const now = new Date();
    const el = document.getElementById("clock");
    if (!el) return;

    const match = parseTime(getFormatter(DEFAULT_TZ).format(now));
    if (!match) return;

    const [, hours, minutes, seconds, timezone] = match;
    el.textContent = `${hours}:${minutes}:${seconds} ${timezone}`;
};

setInterval(updateTime, 1000);
updateTime();

document.addEventListener("DOMContentLoaded", async () => {
    const canvas = document.getElementById("gallery-canvas");
    const wrap = document.querySelector(".gallery-canvas-wrap");

    if (!wrap || !canvas) return;

    Object.assign(canvas.style, {
        pointerEvents: "auto",
        touchAction: "none",
        position: "absolute",
        inset: "0",
        zIndex: "2"
    });

    wrap.style.position = wrap.style.position || "relative";
    wrap.style.overflow = "hidden";

    const GAP = 10;
    const TILE_MIN = 280;
    const TILE_MAX = 800;
    const BUFFER_TILES = 1;
    const FRICTION = 0.92;
    const MAX_VEL = 410;
    const STOP_EPS = 0.01;
    const CURVE_POWER = 0.95;

    const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
    const mod = (n, m) => ((n % m) + m) % m;

    function curveY(xMid, viewW, strength) {
        if (!viewW) return 0;
        let t = (xMid / viewW) * 2 - 1;
        t = Math.pow(Math.abs(t), CURVE_POWER) * Math.sign(t);
        return Math.sin(t * Math.PI * 0.5) * strength;
    }

    function computeTileSize() {
        const w = app.renderer.width / app.renderer.resolution;
        return clamp(Math.floor(w / 5.2), TILE_MIN, TILE_MAX);
    }

    const app = new PIXI.Application({
        view: canvas,
        resizeTo: wrap,
        backgroundAlpha: 0,
        antialias: true,
        autoDensity: true,
        resolution: window.devicePixelRatio || 1,
    });

    app.renderer.events.cursorStyles.default = 'none';
    app.renderer.events.cursorStyles.pointer = 'none';

    let texturesData = [];
    try {
        const response = await fetch('/webapp/api/artworks');
        const artworksData = await response.json();
        
        texturesData = await Promise.all(artworksData.map(async (art) => {
            let path = art.imageUrl;
            if (!path.includes("assets/images/")) {
                path = "assets/images/" + path;
            }
            if (!path.startsWith("/webapp/")) {
                path = "/webapp/" + path;
            }
            try {
                return { id: art.id, texture: await PIXI.Assets.load(path) };
            } catch (err) {
                return { id: art.id, texture: PIXI.Texture.WHITE };
            }
        }));
    } catch (e) {
        return;
    }

    const tilesLayer = new PIXI.Container();
    app.stage.addChild(tilesLayer);

    let tiles = [];
    let tileSize = 0;
    let cell = 0;
    let cols = 0;
    let rows = 0;
    let gridW = 0;
    let gridH = 0;

    function clearTiles() {
        tilesLayer.removeChildren();
        tiles = [];
    }

    function buildGrid() {
        if (texturesData.length === 0) return;
        clearTiles();
        tileSize = computeTileSize();
        cell = tileSize + GAP;

        const res = app.renderer.resolution;
        const w = app.renderer.width / res;
        const h = app.renderer.height / res;

        cols = Math.ceil(w / cell) + BUFFER_TILES * 2 + 1;
        rows = Math.ceil(h / cell) + BUFFER_TILES * 2 + 1;
        gridW = cols * cell;
        gridH = rows * cell;

        let gridIndices = Array(cols).fill(null).map(() => Array(rows).fill(-1));
        let lastUsed = Array(texturesData.length).fill(0);
        let stepCounter = 0;

        for (let r = 0; r < rows; r++) {
            for (let c = 0; c < cols; c++) {
                let invalid = new Set();

                for(let dx = -1; dx <= 1; dx++) {
                    for(let dy = -1; dy <= 1; dy++) {
                        if(dx === 0 && dy === 0) continue;
                        let nx = c + dx;
                        let ny = r + dy;
                        if(nx >= 0 && nx < cols && ny >= 0 && ny < rows) {
                            if(gridIndices[nx][ny] !== -1) {
                                invalid.add(gridIndices[nx][ny]);
                            }
                        }
                    }
                }
                
                if (c >= 2 && gridIndices[c-2][r] !== -1) invalid.add(gridIndices[c-2][r]);
                if (r >= 2 && gridIndices[c][r-2] !== -1) invalid.add(gridIndices[c][r-2]);

                let available = [];
                for (let i = 0; i < texturesData.length; i++) {
                    if (!invalid.has(i)) available.push(i);
                }

                if (available.length === 0) {
                    invalid.clear();
                    if (c > 0) invalid.add(gridIndices[c-1][r]);
                    if (r > 0) invalid.add(gridIndices[c][r-1]);
                    for (let i = 0; i < texturesData.length; i++) {
                        if (!invalid.has(i)) available.push(i);
                    }
                }

                if (available.length === 0) {
                    available.push(Math.floor(Math.random() * texturesData.length));
                }

                available.sort((a, b) => lastUsed[a] - lastUsed[b]);
                
                let poolSize = Math.min(3, available.length);
                let idx = available[Math.floor(Math.random() * poolSize)];

                gridIndices[c][r] = idx;
                lastUsed[idx] = ++stepCounter;

                const tile = new PIXI.Container();

                const bg = new PIXI.Graphics();
                bg.beginFill(0x2a2a35, 1);
                bg.drawRect(0, 0, tileSize, tileSize);
                bg.endFill();
                tile.addChild(bg);

                const img = new PIXI.Sprite(texturesData[idx].texture);
                const scale = Math.max(tileSize / (img.texture.width || 1), tileSize / (img.texture.height || 1));
                img.scale.set(scale);
                img.anchor.set(0.5);
                img.x = tileSize / 2;
                img.y = tileSize / 2;

                const mask = new PIXI.Graphics().beginFill(0xffffff).drawRect(0, 0, tileSize, tileSize).endFill();
                img.mask = mask;
                
                tile.addChild(img);
                tile.addChild(mask);

                tile.hitArea = new PIXI.Rectangle(0, 0, tileSize, tileSize);
                tile.interactive = true; 
                tile.eventMode = 'static';
                tile.cursor = 'none';
                
                tile.on('pointertap', () => {
                    if (dragDist < 10) {
                        window.location.href = '/webapp/wall.jsp?focus=' + texturesData[idx].id;
                    }
                });

                tilesLayer.addChild(tile);
                tiles.push({ c, r, tile });
            }
        }
    }

    let scrollX = 0, scrollY = 0;
    let velX = 0, velY = 0;
    let dragging = false;
    let dragDist = 0;
    let lastClientX = 0, lastClientY = 0;

    function onWheel(e) {
        e.preventDefault();
        velX += -(e.deltaX || 0) * 0.20;
        velY += -(e.deltaY || 0) * 0.20;
    }

    function onPointerDown(e) {
        dragging = true;
        dragDist = 0;
        lastClientX = e.clientX;
        lastClientY = e.clientY;
    }

    function onPointerMove(e) {
        if (!dragging) return;
        const dx = e.clientX - lastClientX;
        const dy = e.clientY - lastClientY;
        dragDist += Math.hypot(dx, dy);
        lastClientX = e.clientX;
        lastClientY = e.clientY;
        velX += dx * 0.55;
        velY += dy * 0.55;
    }

    const onPointerUp = () => { dragging = false; };

    window.addEventListener("wheel", onWheel, { passive: false });
    window.addEventListener("pointerdown", onPointerDown);
    window.addEventListener("pointermove", onPointerMove);
    window.addEventListener("pointerup", onPointerUp);

    function layout() {
        velX = clamp(velX, -MAX_VEL, MAX_VEL);
        velY = clamp(velY, -MAX_VEL, MAX_VEL);
        scrollX += velX;
        scrollY += velY;
        velX *= FRICTION;
        velY *= FRICTION;

        if (Math.abs(velX) < STOP_EPS) velX = 0;
        if (Math.abs(velY) < STOP_EPS) velY = 0;

        const res = app.renderer.resolution;
        const viewW = app.renderer.width / res;
        const speed = Math.hypot(velX, velY);
        const curveStrength = 30 + speed * 1.15;

        for (const t of tiles) {
            let x = mod(t.c * cell + scrollX, gridW) - cell;
            const columnStagger = (t.c % 2 !== 0) ? (cell * 0.5) : 0;
            let y = mod(t.r * cell + scrollY + columnStagger, gridH) - cell;
            y += curveY(x + tileSize * 0.5, viewW, curveStrength);
            t.tile.x = Math.round(x);
            t.tile.y = Math.round(y);
        }
    }

    let resizeTimer = null;
    window.addEventListener("resize", () => {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(buildGrid, 150);
    });

    buildGrid();
    app.ticker.add(layout);
});

document.addEventListener("DOMContentLoaded", () => {
    const cursor = document.querySelector(".cursor");
    const label = cursor.querySelector(".cursor-paragraph");
    
    gsap.set(cursor, { xPercent: -50, yPercent: -50 });
    
    const xTo = gsap.quickTo(cursor, "x", { duration: 0.02, ease: "none" });
    const yTo = gsap.quickTo(cursor, "y", { duration: 0.02, ease: "none" });
    
    let idleTimer = null;
    let currentText = "";
    let isHoveringDataCursor = false;

    window.addEventListener("pointermove", (e) => {
        xTo(e.clientX);
        yTo(e.clientY);
        
        const rect = label.getBoundingClientRect();
        const margin = 20;
        const nearRight = e.clientX + rect.width + margin > window.innerWidth;
        const nearBottom = e.clientY + rect.height + margin > window.innerHeight;

        Object.assign(label.style, {
            left: nearRight ? "auto" : "calc(100% + 15px)",
            right: nearRight ? "calc(100% + 15px)" : "auto",
            top: nearBottom ? "auto" : "100%",
            bottom: nearBottom ? "calc(100% + 15px)" : "auto",
        });

        cursor.classList.remove("show-text");
        clearTimeout(idleTimer);

        if (isHoveringDataCursor && currentText !== "") {
            idleTimer = setTimeout(() => {
                cursor.classList.add("show-text");
            }, 1000);
        }
    }, { passive: true });

    document.addEventListener("pointerover", (e) => {
        const t = e.target.closest("[data-cursor]");
        if (!t) return;
        currentText = t.getAttribute("data-cursor") || "";
        if (currentText !== "") { 
            label.textContent = currentText;
            isHoveringDataCursor = true;
            clearTimeout(idleTimer);
            idleTimer = setTimeout(() => {
                cursor.classList.add("show-text");
            }, 1000);
        }
    }, true);

    document.addEventListener("pointerout", (e) => {
        const leaving = e.target.closest("[data-cursor]");
        if (!leaving) return;
        if (e.relatedTarget?.closest?.("[data-cursor]")) return;
        isHoveringDataCursor = false;
        currentText = "";
        label.textContent = "";
        cursor.classList.remove("show-text");
        clearTimeout(idleTimer);
    }, true);
});