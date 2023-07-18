-- AFFICHER : 
-- nom des leux qui finissent pas 'um'
SELECT nom_lieu FROM lieu
WHERE nom_lieu LIKE '%um';


-- Nombre de personnages par lieu (trié par nombre de personnages décroissant). 
SELECT nom_lieu , COUNT(personnage.nom_personnage) FROM lieu        
INNER JOIN personnage ON personnage.id_lieu = lieu.id_lieu
GROUP BY nom_lieu ;


-- Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage
SELECT nom_personnage , adresse_personnage , lieu.nom_lieu , specialite.nom_specialite FROM personnage
INNER JOIN specialite ON specialite.id_specialite = personnage.id_specialite
INNER JOIN lieu ON lieu.id_lieu = personnage.id_lieu
ORDER BY personnage.id_lieu , personnage.nom_personnage;


-- Nom des spécialités avec nombre de personnages par spécialité (trié par nombre de personnages décroissant).
SELECT nom_specialite , COUNT( personnage.nom_personnage) FROM specialite
INNER JOIN personnage ON personnage.id_specialite = specialite.id_specialite
GROUP BY nom_specialite 
ORDER BY COUNT(personnage.nom_personnage) ASC;


-- Nom, date et lieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).
SELECT  nom_bataille , DATE_FORMAT(date_bataille, '%d-%m-%Y') AS 'date', lieu.nom_lieu FROM bataille
INNER JOIN lieu ON lieu.id_lieu = bataille.id_lieu
ORDER BY date_bataille DESC;


-- Nom des potions + coût de réalisation de la potion (trié par coût décroissant).
SELECT potion.nom_potion , (ingredient.cout_ingredient * composer.qte) AS 'Cout' FROM composer
INNER JOIN ingredient ON ingredient.id_ingredient = composer.id_ingredient
INNER JOIN potion ON potion.id_potion = composer.id_potion
ORDER BY (ingredient.cout_ingredient * composer.qte) desc;


-- Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'. 
SELECT ingredient.nom_ingredient , ingredient.cout_ingredient , qte FROM composer
INNER JOIN ingredient ON ingredient.id_ingredient = composer.id_ingredient
INNER JOIN potion ON potion.id_potion = composer.id_potion
WHERE potion.nom_potion = 'Santé' ;


-- Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.
SELECT p.nom_personnage, SUM(pc.qte) AS nb_casques
FROM personnage p, bataille b, prendre_casque pc
WHERE p.id_personnage = pc.id_personnage
AND pc.id_bataille = b.id_bataille
AND b.nom_bataille = 'Bataille du village gaulois'
GROUP BY p.id_personnage
HAVING nb_casques >= ALL(
SELECT SUM(pc.qte)
 FROM prendre_casque pc, bataille b
 WHERE b.id_bataille = pc.id_bataille
 AND b.nom_bataille = 'Bataille du village gaulois'
 GROUP BY pc.id_personnage)


-- Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).
SELECT  personnage.nom_personnage , dose_boire FROM boire 
INNER JOIN personnage ON personnage.id_personnage = boire.id_personnage
ORDER BY dose_boire desc;


-- Nom de la bataille où le nombre de casques pris a été le plus important.
SELECT bataille.nom_bataille , COUNT(prendre_casque.id_casque) FROM prendre_casque
INNER JOIN bataille ON bataille.id_bataille = prendre_casque.id_bataille
GROUP BY bataille.nom_bataille 
ORDER BY COUNT(prendre_casque.id_casque) DESC 
LIMIT 1;


-- Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)
SELECT type_casque.nom_type_casque , COUNT(casque.id_type_casque) , SUM(casque.cout_casque) FROM casque
INNER JOIN type_casque ON type_casque.id_type_casque = casque.id_type_casque
GROUP BY type_casque.nom_type_casque
ORDER BY COUNT(casque.id_type_casque) DESC, SUM(casque.cout_casque) ;


-- Nom des potions dont un des ingrédients est le poisson frais.
SELECT potion.nom_potion, ingredient.nom_ingredient FROM composer
INNER JOIN ingredient ON ingredient.id_ingredient = composer.id_ingredient
INNER JOIN potion ON potion.id_potion = composer.id_potion
HAVING ingredient.nom_ingredient='Poisson frais';


-- Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois 
SELECT lieu.nom_lieu , COUNT(personnage.nom_personnage) FROM personnage
INNER JOIN lieu ON lieu.id_lieu = personnage.id_lieu 
GROUP BY lieu.nom_lieu 
HAVING NOT lieu.nom_lieu = 'Village gaulois' AND COUNT(personnage.nom_personnage) = (
  SELECT MAX(count)
	  	FROM ( SELECT COUNT(personnage.nom_personnage) as count FROM personnage
		INNER JOIN lieu ON lieu.id_lieu = personnage.id_lieu 
		WHERE NOT lieu.nom_lieu = 'Village gaulois'
		GROUP BY lieu.nom_lieu ) AS total ) 
ORDER BY COUNT(personnage.nom_personnage) DESC;


-- Nom des personnages qui n'ont jamais bu aucune potion.
SELECT personnage.nom_personnage FROM personnage
LEFT JOIN boire ON personnage.id_personnage = boire.id_personnage
GROUP BY personnage.nom_personnage
HAVING MAX(boire.dose_boire) IS NULL;


-- Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.
SELECT personnage.nom_personnage FROM autoriser_boire
INNER JOIN personnage ON personnage.id_personnage = autoriser_boire.id_personnage
INNER JOIN potion ON potion.id_potion = autoriser_boire.id_potion
HAVING NOT potion.nom_potion = 'Magique';


-- MODIFIER : 
-- Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus
INSERT INTO personnage (nom_personnage, id_specialite , adresse_personnage , id_lieu ) 
VALUES ('Champdeblix' ,
(SELECT id_specialite FROM specialite WHERE nom_specialite = 'Agriculteur') ,
 'ferme hantassion' ,
(SELECT id_lieu FROM lieu WHERE nom_lieu = 'Rotomagus') ) ;


-- Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine... 
INSERT INTO autoriser_boire (id_potion , id_personnage)
VALUES ((SELECT id_potion FROM potion WHERE nom_potion = 'Magique') ,
 		  (SELECT id_personnage FROM personnage WHERE nom_personnage = 'Bonemine')) ;


-- Supprimez les casques grecs qui n ont jamais été pris lors d une bataille. // en partie generer par chatgpt 
DELETE FROM casque 
WHERE (SELECT id_type_casque FROM type_casque WHERE nom_type_casque = 'Grec') AND WHERE NOT id_casque IN (
SELECT id_casque FROM casque 
WHERE id IN ( SELECT id FROM prendre_casque ));


-- Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.
UPADTE personnage SET 
adresse_personnage = 'prison' , 
id_lieu=(SELECT id_lieu FROM lieu WHERE nom_lieu = 'Condate')
WHERE id_personnage = Zérozérosix ;


-- La potion 'Soupe' ne doit plus contenir de persil.
DELETE FROM composer
WHERE id_potion=(SELECT id_potion FROM potion WHERE nom_potion = 'Soupe') AND 
id_ingredient=(SELECT id_ingredient FROM ingredient WHERE nom_ingredient = 'persil') ;


-- Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 
-- 'Attaque de la banque postale'. Corrigez son erreur ! 
UPDATE prendre_casque SET id_casque=(SELECT id_casque FROM casque WHERE nom_casque = 'Weisenau') , qtt = 42 
WHERE id_personnage=(SELECT id_personnage FROM personnage WHERE nom_personnage = 'Obélix') AND
 id_bataille = (SELECT id_bataille FROM bataille WHERE nom_bataille = 'Attaque de la banque postale') ;










