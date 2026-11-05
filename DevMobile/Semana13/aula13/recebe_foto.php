<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Envia a foto</title>
</head>
<body>
    <form action="salva_foto.php" method="post" enctype="multipart/form-data">
        <label for="">Foto:</label>
        <input type="file" name="foto"><br>
        <label for="">Descrição:</label>
        <input type="text" name="desc"><br>
        <input type="submit">
    </form>
</body>
</html>
