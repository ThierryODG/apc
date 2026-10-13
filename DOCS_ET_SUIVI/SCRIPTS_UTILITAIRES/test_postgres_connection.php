<?php
// Test de connexion à la base de données PostgreSQL apc_db
$host = '127.0.0.1';
$port = '5432';
$dbname = 'apc_db';
$user = 'Thierry';
$password = 'Admin';

try {
    $pdo = new PDO("pgsql:host={$host};port={$port};dbname={$dbname}", $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "Connexion réussie à PostgreSQL 17 sur {$dbname} avec l'utilisateur {$user} !\n";
} catch (PDOException $e) {
    echo "Erreur de connexion : " . $e->getMessage() . "\n";
}
