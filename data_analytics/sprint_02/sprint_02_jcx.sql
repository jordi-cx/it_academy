/*
Sprint 2 - Jordi Calmet Xartó
IT Academy - Data Analytics

https://github.com/jordi-cx/it_academy/tree/main/data_analytics/sprint_02
*/

-- Nivell 1 - Exercici 1
/*
A partir dels documents adjunts (estructura_dades i dades_introduir), 
importa les dues taules. 
Mostra les característiques principals de l'esquema creat 
i explica les diferents taules i variables que existeixen. 
Assegura't d'incloure un diagrama 
que il·lustri la relació entre les diferents taules i variables.
*/

-- Creación de la Base de Datos y tablas:

DROP DATABASE IF EXISTS transactions;
CREATE DATABASE transactions;
USE transactions;

CREATE TABLE IF NOT EXISTS company (
    id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS user (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);


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


-- Modificamos el tipo de dato en la tabla company
ALTER TABLE company
MODIFY id VARCHAR(20);

-- Quito provisionalmente las FOREIGN KEYs en transaction 
-- porque todavía no tengo los datos de user y credit_card
-- pero necesito empezar a trabajar
-- con los datos de transacciones y company

ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_1;

ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_2;


-- Importación de los datos (dades_introduir_sprint2.sql)

-- Inspección de los datos importados
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
SELECT DISTINCT company.country
FROM transaction
INNER JOIN company ON company.id = transaction.company_id;

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
SELECT COUNT(DISTINCT company.country) AS total_paisos
FROM transaction
INNER JOIN company ON company.id = transaction.company_id;
-- 15 countries


-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT 	c.company_name, 
		ROUND(AVG(t.amount), 2) AS promig_vendes
FROM transaction t
JOIN company c ON c.id = t.company_id
GROUP BY c.id
ORDER BY promig_vendes DESC
LIMIT 1;
-- Ac Fermentum Incorporated


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
        FROM transaction
        WHERE transaction.declined = 0
    )
    AND transaction.declined = 0
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


-- Nivell 1 - Exercici 4
/*
La teva tasca és dissenyar i crear una taula anomenada "credit_card" 
que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta 
i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
Després de crear la taula serà necessari que ingressis la informació 
del document denominat "dades_introduir_credit". 
Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
*/

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(50)
);

ALTER TABLE credit_card
ADD COLUMN pan VARCHAR(50),
ADD COLUMN pin INT, -- VARCHAR(5) o INT(4) UNSIGNED ZEROFILL
ADD COLUMN cvv INT, -- VARCHAR(5) o INT(3) UNSIGNED ZEROFILL
ADD COLUMN expiring_date VARCHAR(15);

-- Ingresamos los datos de credit_card desde el fichero datos_introducir_credit.sql
-- 5000 rows

-- Modifico el campo expiring_date para que sea tipo DATE
ALTER TABLE credit_card
ADD COLUMN expiring_date_ok DATE;

UPDATE credit_card
SET expiring_date_ok = STR_TO_DATE(expiring_date, '%m/%d/%y');

ALTER TABLE credit_card
DROP COLUMN expiring_date,
RENAME COLUMN expiring_date_ok TO expiring_date;

-- Añado la FOREIGN KEY (transaction_ibfk_1) en transaction
ALTER TABLE transaction 
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id)


-- Nivell 1 - Exercici 5
/*
El departament de Recursos Humans ha identificat un error 
en el número de compte associat a la targeta de crèdit amb ID CcU-2938. 
La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. 
Recorda mostrar que el canvi es va realitzar.
*/

SELECT id, iban 
FROM credit_card
WHERE id = 'CcU-2938';

/*
Todo esto NO es necesario para el ejercicio:

-- Creo una tabla para monitorizar los cambios en credit_card
CREATE TABLE credit_card_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    credit_card_id VARCHAR(15),
    old_iban VARCHAR(50),  
    new_iban VARCHAR(50),  
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Defino un TRIGGER para monitorizar los cambios en cada UPDATE
DELIMITER //

CREATE TRIGGER log_credit_card_updates
AFTER UPDATE ON credit_card
FOR EACH ROW
BEGIN
    IF OLD.iban <> NEW.iban THEN
        INSERT INTO credit_card_audit (
            credit_card_id, 
            old_iban, new_iban
        )
        VALUES (
            OLD.id, 
            OLD.iban, NEW.iban
        );
    END IF;
END //

DELIMITER ;
*/

-- Modificamos el valor de la credit_card
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';


-- Nivell 1 - Exercici 6
/*
En la taula "transaction" ingressa una nova transacció amb la següent informació:

Id: 108B1D1D-5B23-A76C-55EF-C568E49A99DD 
credit_card_id: CcU-9999 
company_id: b-9999 
user_id: 9999 
lat: 829.999 
longitude: -117.999 
amount: 111.11 
declined: 0 

DELETE FROM transaction
WHERE transaction.id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';
*/

-- Insertamos primero los valores padre
-- en las tablas company, credit_card y user
INSERT INTO company (id) 
VALUES ('b-9999');

INSERT INTO credit_card (id) 
VALUES ('CcU-9999');

INSERT INTO user (id) 
VALUES ('9999');

-- Insertamos la transacción que se pide
INSERT INTO transaction
(   id, 
    credit_card_id, company_id, user_id, 
    lat, longitude, amount, declined, timestamp) 
VALUES 
(   '108B1D1D-5B23-A76C-55EF-C568E49A99DD', 
    'CcU-9999', 'b-9999', '9999', 
    '829.999', '-117.999', '111.11', '0', CURRENT_TIMESTAMP());

SELECT * FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

/*
Si queremos que el campo timestamp tenga un valor con la hora actual por defecto:

ALTER TABLE transaction 
MODIFY COLUMN timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
*/


-- Nivell 1 - Exercici 7
/*
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. 
Recorda mostrar el canvi realitzat.
*/

-- Borro la columna pan de la tabla credit_card
ALTER TABLE credit_card
DROP COLUMN pan;


-- Mostramos la tabla tal como queda ahora
SHOW COLUMNS FROM credit_card;


-- Nivell 1 - Exercici 8
/*
Descarrega els arxius CSV que trobaràs a l'apartat de recursos.
Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, 
almenys, 4 taules de les quals puguis realitzar les següents consultes:
*/

/*
users: id,name,surname,phone,email,birth_date,country,city,postal_code,address
companies: company_id,company_name,phone,email,country,website
credit_cards: id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date
transactions: id;card_id;business_id;timestamp;amount;declined;product_ids;user_id;lat;longitude
*/

CREATE TABLE users_american (
    id INT,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(100),
    email VARCHAR(100),
    birth_date_aux VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(15),
    address VARCHAR(255)
);

LOAD DATA INFILE '/Users/Shared/Aux Files/american_users.csv'
INTO TABLE users_american
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

/*
Para poder importar debo solucionar un tema de permisos:

SHOW VARIABLES LIKE 'secure_file_priv';

Desde la Terminal:
sudo nano /etc/my.cnf

Escribo el fichero de Configuración:

[mysqld]
secure_file_priv = ""

Paro y arranco de nuevo el servidor para que funcione la importación desde el archivo csv.

SHOW VARIABLES LIKE 'secure_file_priv'; -- Tiene que ser ""

Copio los ficheros en la ruta /Users/Shared/

Bingo, ya he podido leerlos e importar los datos!
*/

ALTER TABLE users_american
ADD COLUMN birth_date DATE;

-- SET SQL_SAFE_UPDATES = 0;

UPDATE users_american
SET birth_date = STR_TO_DATE(birth_date_aux, '%b %d, %Y');

-- SET SQL_SAFE_UPDATES = 1;

ALTER TABLE users_american
DROP COLUMN birth_date_aux;

-- Hacemos igual para los european_users desde el archivo csv:
-- '/Users/Shared/Aux Files/american_users.csv'

-- Creamos una tabla auxiliar para importar datos desde
-- '/Users/Shared/Aux Files/companies.csv'

CREATE TABLE companies_aux (
    id VARCHAR(20),
    company_name VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

LOAD DATA INFILE '/Users/Shared/Aux Files/companies.csv'
INTO TABLE companies_aux
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- Puedo ver que todos estos datos de companies ya estaban en la tabla company

-- Ahora importo los datos des del archivo credit_cards.csv
-- credit_cards: id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date

CREATE TABLE credit_card_aux (
    id VARCHAR(15),
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin INT,
    cvv INT,
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date_aux VARCHAR(50)
);

LOAD DATA INFILE '/Users/Shared/Aux Files/credit_cards.csv'
INTO TABLE credit_card_aux
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

/*
ALTER TABLE credit_card_aux
ADD COLUMN expiring_date DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE credit_card_aux
SET expiring_date = STR_TO_DATE(expiring_date_aux, '%m/%d/%y');

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE credit_card_aux
DROP COLUMN expiring_date_aux;
*/

-- Importamos los datos del archivo
-- '/Users/Shared/Aux Files/credit_cards.csv'
-- id;card_id;business_id;timestamp;amount;declined;product_ids;user_id;lat;longitude
-- en otra tabla auxiliar:

-- Hago una copia de seguridad de la tabla original credit_card
CREATE TABLE archive_credit_card (
    credit_card_id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(50), 
    pin INT,
    cvv INT,
    expiring_date DATE
);

INSERT INTO archive_credit_card (id, iban, pin, cvv, expiring_date)
SELECT id, iban, pin, cvv, expiring_date FROM credit_card;


-- Incorporo la columna user_id que no estaba en la primera tabla de credit_card
-- Y añado los datos desde credit_card_aux
ALTER TABLE credit_card
ADD COLUMN user_id INT;

-- SET SQL_SAFE_UPDATES = 0;

UPDATE credit_card cc
JOIN credit_card_aux cx ON cc.id = cx.id
SET cc.user_id = cx.user_id;

-- SET SQL_SAFE_UPDATES = 1;


-- Añado todos los nuevos usuarios (american + european)
ALTER TABLE user
ADD COLUMN surname VARCHAR(100),
ADD COLUMN phone VARCHAR(100),
ADD COLUMN email VARCHAR(100),
ADD COLUMN birth_date DATE,
ADD COLUMN country VARCHAR(100),
ADD COLUMN city VARCHAR(100),
ADD COLUMN postal_code VARCHAR(15),
ADD COLUMN address VARCHAR(255);

INSERT INTO user (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address
FROM users_american;

INSERT INTO user (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
SELECT id, name, surname, phone, email, birth_date, country, city, postal_code, address
FROM users_european;


-- Importamos también los datos de transacciones
CREATE TABLE transactions_aux (
    id VARCHAR(255),
    credit_card_id VARCHAR(15),
    company_id VARCHAR(20), 
    timestamp TIMESTAMP,
    amount DECIMAL(10, 2),
    declined BOOLEAN,
    product_ids VARCHAR(255),
    user_id INT,
    lat FLOAT,
    longitude FLOAT
);

LOAD DATA INFILE '/Users/Shared/Aux Files/transactions.csv'
INTO TABLE transactions_aux
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- Añadimos el campo product_ids que no estaba en la anterior tabla transaction
ALTER TABLE transaction
ADD COLUMN product_ids VARCHAR(255);

-- SET SQL_SAFE_UPDATES = 0;
UPDATE transaction t
JOIN transactions_aux x ON t.id = x.id
SET t.product_ids = x.product_ids;
-- SET SQL_SAFE_UPDATES = 1;

-- Añado la FOREIGN KEY en transaction respecto a user
ALTER TABLE transaction 
ADD CONSTRAINT fk_user 
FOREIGN KEY (user_id) REFERENCES user(id);


-- Nivell 1 - Exercici 9
/*
Realitza una subconsulta que mostri tots els usuaris 
amb més de 80 transaccions utilitzant almenys 2 taules.
*/

SELECT id, name, surname, country
FROM user
WHERE id IN (
    SELECT user_id
    FROM transaction
    GROUP BY user_id
    HAVING COUNT(*) > 80
);

-- 4 users


-- Nivell 1 - Exercici 10
/*
Mostra la mitjana d'amount per IBAN de les targetes de crèdit 
a la companyia Donec Ltd, utilitza almenys 2 taules.
*/

SELECT  c.iban, ROUND(AVG(t.amount), 2) AS avg_amount
FROM transaction t
JOIN credit_card c ON c.id = t.credit_card_id
JOIN company b ON b.id = t.company_id
WHERE b.company_name = 'Donec Ltd'
GROUP BY c.iban
ORDER BY avg_amount DESC;


-- Nivell 2 - Exercici 1
/*
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
Mostra la data de cada transacció juntament amb el total de les vendes.
*/

SELECT 	DATE(transaction.timestamp) AS dia,
		SUM(transaction.amount) AS total_dia
FROM transaction
WHERE transaction.declined = 0
GROUP BY dia
ORDER BY total_dia DESC
LIMIT 5;


-- Nivell 2 - Exercici 2
/*
Presenta el nom, telèfon, país, data i amount, 
d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros
i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
Ordena els resultats de major a menor quantitat.
*/

SELECT	c.company_name, c.phone, c.country, 
		t.amount,
        DATE(t.timestamp) as data
FROM transaction t
JOIN company c ON c.id = t.company_id
WHERE t.amount BETWEEN 350 AND 400
AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;


-- Nivell 2 - Exercici 3
/*
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
si tenen més de 400 transaccions o menys.
*/

SELECT  t.company_id, 
        c.company_name, 
        COUNT(*) AS num_transactions,
        CASE
            WHEN COUNT(*) > 400 THEN 'Más de 400 transacciones'
            ELSE 'Menos de 400 transacciones'
        END 
        AS mas_de_400
FROM transaction t
JOIN company c ON c.id = t.company_id
GROUP BY t.company_id
ORDER BY num_transactions DESC;


-- Nivell 2 - Exercici 4
/*
Elimina de la taula transaction el registre 
amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.
*/

/*
-- Compruebo priimero los datos de este registro:
-- por si necesitara repescarlos más adelante

SELECT * FROM transaction
WHERE transaction.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

id: '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'
credit_card_id: 'CcS-5019'
company_id: 'b-2370'
user_id: 438
lat: 41.5972
longitude: 12.2218
timestamp: '2016-12-21 20:07:18'
amount: 155.63
declined: 0
product_ids: 66, 69, 87'
*/

DELETE FROM transaction
WHERE transaction.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';


-- Nivell 2 - Exercici 5
/*
La secció de màrqueting desitja tenir accés a informació específica 
per a realitzar anàlisi i estratègies efectives. 
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies 
i les seves transaccions. 
Serà necessària que creïs una vista anomenada VistaMarketing 
que contingui la següent informació: 
- Nom de la companyia. 
- Telèfon de contacte. 
- País de residència. 
- Mitjana de compra realitzat per cada companyia. 

Presenta la vista creada, ordenant les dades 
de major a menor mitjana de compra.
*/

CREATE OR REPLACE VIEW VistaMarketing AS
SELECT  b.company_name, 
        b.phone, 
        b.country,
        ROUND(AVG(t.amount), 2) AS avg_company
FROM transaction t
JOIN company b ON b.id = t.company_id
WHERE t.declined = 0
GROUP BY t.company_id;

SELECT * FROM VistaMarketing
ORDER BY avg_company DESC;


-- Nivell 3 - Exercici 1
/*
Crea una nova taula que reflecteixi l'estat de les targetes de crèdit 
basat en si les tres últimes transaccions han estat declinades aleshores és inactiu, 
si almenys una no és rebutjada aleshores és actiu. 
Partint d’aquesta taula respon:

Quantes targetes estan actives?
*/

-- Tabla con todos los usuarios y su status
-- DROP TABLE IF EXISTS users_status;

CREATE TABLE users_status AS

WITH cte_last_three AS (
    SELECT  user_id,
            credit_card_id,
            declined,
            ROW_NUMBER() OVER(PARTITION BY credit_card_id ORDER BY timestamp DESC) AS num_fila
    FROM transaction
)
SELECT  user_id, 
        credit_card_id,
        IF(MIN(declined) = 0, 1, 0) AS active
FROM cte_last_three
WHERE num_fila <= 3
GROUP BY user_id, credit_card_id;

-- Contamos cuantos usuarios activos
SELECT COUNT(*) AS total_active
FROM users_status
WHERE active = 1; 

-- 4996 active users


-- Nivell 3 - Exercici 2
/*
Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv 
amb la base de dades creada, tenint en compte que des de transaction tens product_ids. 
Genera la següent consulta:

Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
*/

-- Creamos una nueva tabla product
-- Luego importamos los datos del archivo products.csv
-- id,product_name,price,colour,weight,warehouse_id

CREATE TABLE product (
    id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price_str VARCHAR(20),
    colour VARCHAR(50),
    weight FLOAT,
    warehouse_id VARCHAR(20)
);

LOAD DATA INFILE '/Users/Shared/Aux Files/products.csv'
INTO TABLE product
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

ALTER TABLE product 
ADD COLUMN price DECIMAL(10, 2) AFTER price_str;

SET SQL_SAFE_UPDATES = 0;

UPDATE product 
SET price = REPLACE(price_str, '$', '');

SET SQL_SAFE_UPDATES = 1;

-- ALTER TABLE product  DROP COLUMN price_str;

-- En transaction creo una nueva columna de tipo JSON
ALTER TABLE transaction
ADD COLUMN product_ids_json JSON;

SET SQL_SAFE_UPDATES = 0;

UPDATE transaction
SET product_ids_json = CAST(CONCAT('[', product_ids, ']') AS JSON)
WHERE product_ids IS NOT NULL AND product_ids != '';
-- WHERE COALESCE(product_ids, '') != '';

SET SQL_SAFE_UPDATES = 1;

-- Creamos una tabla para las relacions n:m (con clave primaria compuesta)
DROP TABLE IF EXISTS transaction_product;

CREATE TABLE transaction_product (
    transaction_id VARCHAR(255),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transaction(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
);

INSERT INTO transaction_product (transaction_id, product_id)
SELECT t.id, j.product_id
FROM transaction t
CROSS JOIN JSON_TABLE(
    t.product_ids_json, 
    '$[*]' COLUMNS (product_id INT PATH '$')
) AS j
WHERE t.product_ids_json IS NOT NULL;

-- Consulta para saber el número de transacciones por producto
SELECT tp.product_id, p.product_name, COUNT(*) AS ventas
FROM transaction_product tp
INNER JOIN product p ON p.id = tp.product_id
INNER JOIN transaction t ON t.id = tp.transaction_id
WHERE t.declined = 0
GROUP BY tp.product_id
ORDER BY tp.product_id;

--
