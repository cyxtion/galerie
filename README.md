# Galerie

Galerie is a full-stack, interactive e-commerce art platform. It replaces the traditional static image grid with a hardware-accelerated WebGL spatial canvas, backed by a secure Java Servlet architecture and a MySQL relational database.

## Core Features

* **Interactive WebGL Gallery:** Infinite spatial canvas rendering using PixiJS and GSAP for fluid, physics-based animations at 60 FPS.
* **Asynchronous Browsing:** AJAX-driven frontend architecture allows users to browse, add items to the cart, and update quantities without page reloads.
* **Session Management:** Cart state and user authentication are managed via server-side Java `HttpSession`.
* **Secure Checkout Processing:** Transaction routing protected by rigorous authentication checks.

## Technology Stack

* **Frontend:** HTML5, CSS3, Vanilla JavaScript (ES6+), PixiJS (WebGL), GSAP
* **Backend:** Java 17+, Jakarta EE (Servlets, JSP)
* **Server Engine:** Apache Tomcat 10
* **Database:** MySQL 8.0+, JDBC Driver
* **Deployment Environment:** Ubuntu Linux, AWS EC2

## System Architecture

The application rigorously follows the Model-View-Controller (MVC) design pattern to maintain a strict separation of concerns:

* **Model:** Java Data Transfer Objects (User, Artwork, CartItem) interact with the MySQL database through dedicated Data Access Objects (DAOs).
* **View:** JavaServer Pages (JSP) present dynamic HTML content and interface elements to the client.
* **Controller:** Java Servlets act as the application's router, intercepting HTTP requests, enforcing business logic, and returning the appropriate JSON payload or View.

## Security Implementations

* **SQL Injection Prevention:** All database transactions execute through JDBC `PreparedStatement` objects, ensuring client input is strictly parameterized before reaching the MySQL engine.
* **Cross-Site Scripting (XSS) Mitigation:** Session tokens are secured using `HttpOnly` cookies, preventing malicious client-side scripts from accessing authentication data.
* **Route Protection:** Backend checkout and account Servlets validate session integrity on every request, rejecting unauthenticated API calls with 401 Unauthorized responses.

## Local Development Setup

### Prerequisites
* Java Development Kit (JDK) 17 or higher
* Apache Tomcat 10
* MySQL Server 8.0+
* Git

### Installation

1.  **Clone the repository:**
    ```bash
    git clone "https://github.com/eakasharma/galerie.git"
    cd galerie
    ```

2.  **Database Configuration:**
    Log into your local MySQL instance and create the database and tables:
    ```sql
    CREATE DATABASE gallery_db;
    USE gallery_db;
    
    -- Execute the schema definitions for Users, Artworks, Orders, and Order_Items
    -- (Schema details located in the project's SQL initialization file)
    ```

3.  **Update Database Credentials:**
    Navigate to `src/main/java/com/gallery/utils/DBUtil.java` and update the connection string, username, and password to match your local MySQL environment.

4.  **Compilation:**
    Compile the Java source files, linking the Tomcat Servlet API and MySQL Connector/J libraries.
    ```bash
    javac -cp ".:/path/to/tomcat10/lib/servlet-api.jar:/path/to/mysql-connector-j.jar:webapp/WEB-INF/classes" -d webapp/WEB-INF/classes src/main/java/com/gallery/models/*.java src/main/java/com/gallery/utils/*.java src/main/java/com/gallery/controllers/*.java
    ```

5.  **Deployment:**
    Move the `webapp` directory into your Tomcat `webapps` folder (rename to `ROOT` to serve as the default application). Start the Tomcat server.

    ```bash
    cp -r webapp /path/to/tomcat10/webapps/ROOT
    ```

6.  **Access the Application:**
    Navigate to `http://localhost:8080` in your web browser.
