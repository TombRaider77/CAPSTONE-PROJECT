<?php
$servername = "localhost";
$username = "root"; // Your DB username
$password = "";     // Your DB password
$dbname = "uwbdatabase";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} else {
    echo "<p>Database Connection Succeeded!</p>";
}

if(isset($_POST["tagAddress"]) && isset($_POST["distance"])) {
    $addr = $_POST["tagAddress"];
    $Dist = $_POST["distance"];

    $stmt = $conn->prepare("INSERT INTO distancedata (tagAddress, Distance) VALUES (?, ?)");
    $stmt->bind_param("ss", $addr, $Dist);

    // Execute the prepared statement
    if ($stmt->execute()) {
        echo "<div>New record created successfully</div>";
    } else {
        echo "<div>Error: " . $stmt->error . "</div>";
    }
    $stmt->close();
}

$conn->close();
