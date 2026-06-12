<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Galerie</title>
    <script src="https://accounts.google.com/gsi/client" async defer></script>
    <style>
        body { background: #111; color: #fff; font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-container { display: flex; flex-direction: column; gap: 15px; width: 300px; background: #0a0a0a; padding: 40px; border: 1px solid #333; }
        form { display: flex; flex-direction: column; gap: 15px; }
        input { padding: 12px; background: #222; border: 1px solid #444; color: #fff; }
        button { padding: 12px; background: #fff; color: #000; border: none; cursor: pointer; font-weight: bold; }
        .divider { display: flex; align-items: center; text-align: center; color: #666; font-size: 12px; margin: 10px 0; }
        .divider::before, .divider::after { content: ''; flex: 1; border-bottom: 1px solid #333; }
        .divider:not(:empty)::before { margin-right: .25em; }
        .divider:not(:empty)::after { margin-left: .25em; }
        #error-msg { color: #ff4444; font-size: 14px; display: none; }
    </style>
</head>
<body>

    <div class="login-container">
        <h2 style="margin-top: 0;">ACCESS PROTOCOL</h2>
        
        <div id="g_id_onload"
             data-client_id="247853928320-u50aog2uhj5eickd5pqbmn9ih1skruk7.apps.googleusercontent.com"
             data-context="signin"
             data-ux_mode="popup"
             data-callback="handleGoogleLogin"
             data-auto_prompt="false">
        </div>

        <div class="g_id_signin"
             data-type="standard"
             data-shape="rectangular"
             data-theme="filled_black"
             data-text="signin_with"
             data-size="large"
             data-logo_alignment="left"
             style="display: flex; justify-content: center; width: 100%;">
        </div>

        <div class="divider">OR</div>

        <form id="login-form">
            <input type="text" id="username" name="username" placeholder="Username" required>
            <input type="password" id="password" name="password" placeholder="Password" required>
            <button type="submit">ENTER</button>
            <div id="error-msg"></div>
        </form>
    </div>

    <script>
        async function handleGoogleLogin(response) {
            const errorMsg = document.getElementById("error-msg");
            errorMsg.style.display = "none";
            
            try {
                const res = await fetch('/webapp/api/google-login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'credential=' + encodeURIComponent(response.credential)
                });
                
                const data = await res.json();
                
                if (data.success) {
                    if (data.role === 'ADMIN') window.location.href = '/webapp/admin.jsp';
                    else if (data.role === 'ARTIST') window.location.href = '/webapp/artist.jsp';
                    else window.location.href = '/webapp/home';
                } else {
                    errorMsg.textContent = data.message || data.error || "Google authentication failed.";
                    errorMsg.style.display = "block";
                }
            } catch (err) {
                errorMsg.textContent = "Server connection failed.";
                errorMsg.style.display = "block";
            }
        }

        document.getElementById("login-form").addEventListener("submit", async (e) => {
            e.preventDefault();
            const formData = new URLSearchParams(new FormData(e.target));
            const errorMsg = document.getElementById("error-msg");
            
            try {
                const res = await fetch('/webapp/api/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                });
                const data = await res.json();
                
                if (data.success) {
                    if (data.role === 'ADMIN') window.location.href = '/webapp/admin.jsp';
                    else if (data.role === 'ARTIST') window.location.href = '/webapp/artist.jsp';
                    else window.location.href = '/webapp/home';
                } else {
                    errorMsg.textContent = data.message || data.error || "Login failed.";
                    errorMsg.style.display = "block";
                }
            } catch (err) {
                errorMsg.textContent = "Server connection failed.";
                errorMsg.style.display = "block";
            }
        });
    </script>
</body>
</html>