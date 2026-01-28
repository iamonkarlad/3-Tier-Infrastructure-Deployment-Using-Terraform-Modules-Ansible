<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$host = "terraform-20260128080025515100000004.c4ji0qekmizd.us-east-1.rds.amazonaws.com";
$user = "admin";
$pass = "admin1234";
$db   = "mydatabase";

$conn = new mysqli($host, $user, $pass, $db, 3306);

if ($conn->connect_error) {
    die("DB Connection Failed: " . $conn->connect_error);
}

$name  = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';

if ($name && $email) {
    $sql = "INSERT INTO users (name, email) VALUES ('$name', '$email')";
    if ($conn->query($sql)) {
        echo "Registration Successful";
    } else {
        echo "Insert failed";
    }
} else {
    echo "Invalid input";
}

$conn->close();
?>
