


<style>
        table {
            border-collapse: collapse;
        }

        th,td {
            border: 1px solid black;
            padding: 10px;
        }
    </style>
<?php 

try 
{
$connectionSQL = new PDO('mysql:host=localhost;dbname=gaulois;charse t=utf8','root','');
}
catch(Exception $e)
{
    die('Erreur :'. $e->getMessage());
}
$requete1= 'SELECT * FROM personnage';
$statement= $connectionSQL->prepare($requete1);
$statement->execute();
$personnages = $statement ->fetchALL();

echo"<table>", 
        "<thead>",
            "<tr>",
                "<th>nom_personnage</th>",
                "<th>adresse_personnage</th>",
                "<th>image_personnage</th>",
                "<th>id_lieu</th>",
                "<th>id_specialite</th>",
            "<tr>",
        "<thead>",  
        "<tbody>";
    foreach($personnages as $personnage){  
        echo"<tr>",
                "<td>".$personnage['nom_personnage']."</td>",
                "<td>".$personnage['adresse_personnage']."</td>",
                "<td>".$personnage['image_personnage']."</td>",
                "<td>".$personnage['id_lieu']."</td>",
                "<td>".$personnage['id_specialite']."</td>",
            "</tr>";}

        echo "</tbody>",
    "</table>";

?>
