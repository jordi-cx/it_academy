/*
Sprint 1 - Exercicis SQL
Jordi Calmet Xartó - IT Academy

https://github.com/jordi-cx/it_academy/tree/main/data_analytics/sprint_02
*/

-- Nivell 1 - Exercici 1

-- Creació de la base de dades, taules i importació de dades:

-- Creem la base de dades (esborrant si hi havia una versió anterior)
DROP DATABASE IF EXISTS transactions;
CREATE DATABASE transactions;
USE transactions;

-- Creem les taules company (segons l'arxiu estructura_dades.sql)
CREATE TABLE IF NOT EXISTS company (
    id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

-- Creem les taules credit_card i user (amb les seves claus primàries)
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    info VARCHAR(50),
    cvv INT
);

CREATE TABLE IF NOT EXISTS user (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Creem la taula transaction (segons l'arxiu estructura_dades.sql)
CREATE TABLE IF NOT EXISTS transaction (
  	id VARCHAR(255) PRIMARY KEY,
   	credit_card_id VARCHAR(15) REFERENCES credit_card(id),
   	company_id VARCHAR(20), 
   	user_id INT REFERENCES user(id),
   	lat FLOAT,
   	longitude FLOAT,
   	timestamp TIMESTAMP,
   	amount DECIMAL(10, 2),
   	declined BOOLEAN,
  	FOREIGN KEY (company_id) REFERENCES company(id) 
);


-- Modifiquem el tipus de dada a company, per coherència
ALTER TABLE company
MODIFY id VARCHAR(20);

-- Modifiquem la taula transaction per treure els constraints
-- i poder insertar totes les dades sense que em doni error
-- (perquè encara no tinc les dades de user i credit_card)
ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_1;

ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_2;

-- Insertem les dades de transactions i company des de 
-- dades_introduir_sprint2.sql

DESCRIBE transaction;
DESCRIBE company;

SELECT COUNT(*) AS total_empreses
FROM company;
-- 100 empreses

SELECT COUNT(*) AS total_transaccions
FROM transaction;
-- 100000 transaccions


-- Nivell 1 - Exercici 2
/*
Utilitzant JOIN realitzaràs les següents consultes:
*/

-- Llistat dels països que estan fent compres.
SELECT company.country
FROM transaction
JOIN company ON company.id = transaction.company_id
GROUP BY country;


-- Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT company.country) AS total_paisos
FROM transaction
JOIN company ON company.id = transaction.company_id;


-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT 	company.company_name, 
		ROUND(AVG(transaction.amount), 2) AS promig_vendes
FROM transaction
JOIN company ON company.id = transaction.company_id
GROUP BY company.id
ORDER BY promig_vendes DESC
LIMIT 1;


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

-- 13291 transaccions

-- Llista les empreses que han realitzat transaccions 
-- per un amount superior a la mitjana de totes les transaccions.
SELECT company.id, company.company_name, company.country
FROM company
WHERE id IN (
	SELECT DISTINCT transaction.company_id 
	FROM transaction
	WHERE transaction.amount > (
		SELECT AVG(transaction.amount)
		FROM transaction)
);

-- 100 empreses


-- Eliminaran del sistema les empreses que no tenen transaccions registrades, 
-- entrega el llistat d'aquestes empreses.
SELECT company.id, company.company_name
FROM company
WHERE id NOT IN (
	SELECT DISTINCT transaction.company_id 
	FROM transaction
);

-- 0 empreses (totes les 100 empreses tenen alguna transacció registrada)


-- Nivell 2 - Exercici 1
/*
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
Mostra la data de cada transacció juntament amb el total de les vendes.
*/

SELECT 	DATE(transaction.timestamp) AS dia,
		SUM(transaction.amount) AS total_dia
FROM transaction
GROUP BY dia
ORDER BY total_dia DESC
LIMIT 5;


-- Nivell 2 - Exercici 2
/*
Quina és la mitjana de vendes per país? 
Presenta els resultats ordenats de major a menor mitjà.
*/

SELECT	company.country, 
		AVG(transaction.amount) AS mitjana_pais
FROM transaction
JOIN company ON company.id = transaction.company_id
GROUP BY company.country
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
SELECT	transaction.id, 
		transaction.timestamp, 
		transaction.company_id, 
		transaction.amount, 
		company.country
FROM transaction
JOIN company ON company.id = transaction.company_id
WHERE company.country = (
	SELECT company.country
	FROM company
	WHERE company.company_name = 'Non Institute'
)
ORDER BY transaction.timestamp;


-- Amb només Subqueries
SELECT	transaction.id, transaction.company_id, 
		transaction.timestamp, transaction.amount
FROM transaction
WHERE transaction.company_id IN (
	SELECT company.id 
    FROM company
    WHERE company.country = (
		SELECT country
		FROM company
		WHERE company_name = 'Non Institute'
	)
)
ORDER BY transaction.timestamp;

-- 13776 transaccions


-- Nivell 3 - Exercici 1
/*
Presenta el nom, telèfon, país, data i amount, 
d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros
i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
Ordena els resultats de major a menor quantitat.
*/

SELECT	company.company_name, company.phone, company.country, 
		transaction.amount,
        DATE(transaction.timestamp) as data
FROM transaction
JOIN company ON company.id = transaction.company_id
WHERE transaction.amount BETWEEN 100 AND 200
AND DATE(transaction.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY transaction.amount DESC;


-- Nivell 3 - Exercici 2
/*
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
si tenen més de 4 transaccions o menys.
*/

SELECT 	transaction.company_id, 
		company.company_name, 
		company.country, 
		COUNT(*) AS transaccions,
        CASE
			WHEN COUNT(*) > 4 THEN 'Més de 4 transaccions'
			ELSE 'Menys de 4 transaccions'
        END AS mes_de_4
FROM transaction
JOIN company ON company.id = transaction.company_id
GROUP BY transaction.company_id
ORDER BY transaccions DESC;

--
