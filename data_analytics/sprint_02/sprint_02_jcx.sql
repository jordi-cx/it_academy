/*
Sprint 1 - Exercicis SQL
Jordi Calmet Xartó - IT Academy
*/

-- Nivell 1 - Exercici 1
/*
A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
Mostra les característiques principals de l'esquema creat 
i explica les diferents taules i variables que existeixen. 
Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.
*/

DESCRIBE transaction;
DESCRIBE company;

SHOW COLUMNS FROM transaction;
SHOW COLUMNS FROM company;

-- Reverse Engineering (veure esquema adjunt)


-- Nivell 1 - Exercici 2
/*
Utilitzant JOIN realitzaràs les següents consultes:
*/

-- Llistat dels països que estan fent compres.
SELECT company.country
FROM transaction
JOIN company ON company.id = transaction.company_id
GROUP BY country;

/*
'Germany'
'Australia'
'United States'
'New Zealand'
'Norway'
'United Kingdom'
'Italy'
'Belgium'
'Sweden'
'Ireland'
'China'
'Canada'
'France'
'Netherlands'
'Spain'
*/


-- Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT country) AS total_paisos
FROM transaction
JOIN company ON company.id = transaction.company_id;

-- 15


-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT company.company_name, ROUND(AVG(transaction.amount), 2) AS promig_vendes
FROM transaction
JOIN company ON company.id = transaction.company_id
GROUP BY company.id
ORDER BY promig_vendes DESC
LIMIT 1;

-- Eget Ipsum Ltd


-- Nivell 1 - Exercici 3
/*
Utilitzant només subconsultes (sense utilitzar JOIN):
*/

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT * 
FROM transaction
WHERE company_id IN (
	SELECT id
	FROM company
	WHERE country = 'Germany'
);

-- 118 transaccions


-- Llista les empreses que han realitzat transaccions 
-- per un amount superior a la mitjana de totes les transaccions.
SELECT id, company_name, country
FROM company
WHERE id IN (
	SELECT DISTINCT company_id 
	FROM transaction
	WHERE amount > (
		SELECT AVG(amount) from transaction
	)
);

-- 70 empreses


-- Eliminaran del sistema les empreses que no tenen transaccions registrades, 
-- entrega el llistat d'aquestes empreses.
SELECT id, company_name
FROM company
WHERE id NOT IN (
	SELECT DISTINCT company_id 
	FROM transaction
);

-- 0 empreses (totes les empreses tenen alguna transacció registrada)


-- Nivell 2 - Exercici 1
/*
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
Mostra la data de cada transacció juntament amb el total de les vendes.
*/

SELECT DATE(timestamp) AS dia, SUM(amount) AS total_dia
FROM transaction
GROUP BY dia
ORDER BY total_dia DESC
LIMIT 5;

/*
'2021-03-29','1564.87'
'2021-12-20','1532.36'
'2021-06-15','1469.90'
'2021-05-09','1463.73'
'2021-06-21','1443.11'
*/


-- Nivell 2 - Exercici 2
/*
Quina és la mitjana de vendes per país? 
Presenta els resultats ordenats de major a menor mitjà.
*/

SELECT country, AVG(amount) AS mitjana_pais
FROM transaction
JOIN company ON company.id = transaction.company_id
GROUP BY country
ORDER BY mitjana_pais DESC;


-- Nivell 2 - Exercici 3
/*
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
per a fer competència a la companyia "Non Institute". 
Per a això, et demanen la llista de totes les transaccions realitzades per empreses 
que estan situades en el mateix país que aquesta companyia.
Mostra el llistat aplicant JOIN i subconsultes.
Mostra el llistat aplicant solament subconsultes.
*/

-- Amb Join i Subquery
SELECT transaction.id, transaction.timestamp, company_id, amount, country
FROM transaction
JOIN company ON company.id = transaction.company_id
WHERE country = (
	SELECT country
	FROM company
	WHERE company_name = 'Non Institute'
)
ORDER BY transaction.timestamp;


-- Amb només Subqueries
SELECT id, company_id, transaction.timestamp, amount
FROM transaction
WHERE company_id IN (
	SELECT id FROM company
    WHERE country = (
		SELECT country
		FROM company
		WHERE company_name = 'Non Institute'
	)
)
ORDER BY transaction.timestamp;


-- Nivell 3 - Exercici 1
/*
Presenta el nom, telèfon, país, data i amount, 
d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros
i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
Ordena els resultats de major a menor quantitat.
*/

SELECT company_name, phone, country, DATE(timestamp) as data, amount
FROM transaction
JOIN company ON company.id = transaction.company_id
WHERE amount BETWEEN 100 AND 200
AND DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY amount DESC;


-- Nivell 3 - Exercici 2
/*
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
si tenen més de 4 transaccions o menys.
*/

SELECT 	company_id, company_name, country, 
		COUNT(*) AS transaccions,
        CASE
			WHEN COUNT(*) > 4 THEN 'Més de 4 transaccions'
			ELSE 'Menys de 4 transaccions'
        END AS mes_de_4
FROM transaction
JOIN company ON company.id = transaction.company_id
GROUP BY company_id
ORDER BY transaccions DESC;

--
