/*
Resum Exercici SQL - Jordi Calmet Xartó
IT Academy - Anàlisis de Dades
*/

/*
Exercicis SELECT
*/

-- 1.Mostra totes les dades de la taula "pacientes".
SELECT *
FROM hospitales.pacientes;

-- 2.Mostra el "nombre", "comunidad_autonoma", "provincia" i "localidad" de la taula "hospitales".
SELECT nombre, comunidad_autonoma, provincia, localidad
FROM hospitales;

-- 3.Mostra els noms dels hospitals i el seu "presupuesto_anual_millones"
-- 	ordenats pel seu "indice_satisfaccion" de major a menor.
SELECT nombre, presupuesto_anual_millones, indice_satisfaccion
FROM hospitales
ORDER BY indice_satisfaccion DESC;
-- muestro también la columna indice_satisfaccion para comprobar la ordenación

-- 4.Mostra el top10 dels hospitals de la consulta anterior.
SELECT nombre, presupuesto_anual_millones, indice_satisfaccion
FROM hospitales
ORDER BY indice_satisfaccion DESC
LIMIT 10;

-- 5.Mostra quines són les "provincia" úniques que hi ha a la taula "hospitales".
SELECT DISTINCT provincia
FROM hospitales;

-- 6.Mostra totes les especialitats mèdiques que hi ha.
SELECT DISTINCT especialidad
FROM especialidades;


/*
Exercicis WHERE
*/

-- 1) Mostra totes les dades dels pacients que comencen per "Ad", de la taula "pacientes".
SELECT *
FROM hospitales.pacientes
WHERE nombre LIKE "Ad%"
OR nacionalidad LIKE "Ad%";

-- 2) De la consulta anterior, mostra les "edad" úniques.
SELECT DISTINCT edad
FROM pacientes
WHERE nombre LIKE 'Ad%';

-- 3) Mostra el "nombre", el camp "ingreso" i el "numero_dias_ingreso"
--    dels pacients que tenen menys de 10 anys de "edad".
SELECT nombre, ingreso, numero_dias_ingreso, edad
FROM pacientes
WHERE edad < 10
ORDER BY numero_dias_ingreso DESC;

-- 4) Mostra els pacients dels "hospital_id" 3, 25, 78 i 155.
SELECT hospital_id, paciente_id, nombre
FROM pacientes
WHERE hospital_id IN (3, 25, 78, 155)
ORDER BY hospital_id;

-- 5) Mostra totes les dades dels hospitals que tenen entre 100 i 120 "num_camas".
SELECT *
FROM hospitales
WHERE num_camas BETWEEN 100 AND 120;

-- 6) Mostra els noms dels hospitals que estan a Barcelona - Catalunya.
SELECT nombre, localidad, provincia, comunidad_autonoma
FROM hospitales
WHERE (localidad = "Barcelona" OR provincia = "Barcelona") 
AND comunidad_autonoma = "Cataluña";


-- 7) Mostra els 3 hospitals amb més "indice_satisfaccion" 
--    del grup d'hospitals de Madrid i Andalusia.
SELECT nombre, comunidad_autonoma, indice_satisfaccion
FROM hospitales
WHERE comunidad_autonoma IN ('Comunidad de Madrid', 'Andalucía')
ORDER BY indice_satisfaccion DESC
LIMIT 3;


-- 8) Mostra els hospitals que comencen per lletra "C" i terminen per lletra "a".
SELECT nombre
FROM hospitales
WHERE nombre LIKE 'C%a';

-- 9) Mostra les especialitats que són fixes.
SELECT DISTINCT especialidad
FROM especialidades
WHERE fija = 'S'
ORDER BY especialidad;


/*
Exercicis GROUP BY
*/

-- 1) Mostra la quantitat de pacients que hi ha a la taula "pacientes"
SELECT COUNT(paciente_id) AS total_pacients
FROM hospitales.pacientes;

-- 2) Mostra la quantitat de pacients que té cada "hospital_id" de la taula "pacientes"
SELECT hospital_id, COUNT(paciente_id) AS num_pacients 
FROM pacientes
GROUP BY hospital_id
ORDER BY hospital_id;

-- 3) Mostra el "numero_dias_ingreso" màxim de cada "hospital_id" de la taula "pacientes"
SELECT hospital_id, MAX(numero_dias_ingreso) AS maximo_dias
FROM pacientes
GROUP BY hospital_id
ORDER BY hospital_id;


-- 4) Mostra el "indice_satisfaccion" mig de cada comunitat autònoma i província de la taula "hospitals"
SELECT comunidad_autonoma, ROUND(AVG(indice_satisfaccion), 2) AS promig_comunitat
FROM hospitales
GROUP BY comunidad_autonoma
ORDER BY promig_comunitat DESC;

SELECT 	comunidad_autonoma, provincia, ROUND(AVG(indice_satisfaccion), 2) AS promig_provincia
FROM hospitales
GROUP BY comunidad_autonoma, provincia
ORDER BY comunidad_autonoma, promig_provincia DESC;

-- Intentar hacer las dos consultas juntos con subquery !?


-- 5) Mostra el "num_camas" total de cada comunitat autònoma
SELECT comunidad_autonoma, SUM(num_camas)
FROM hospitales
GROUP BY comunidad_autonoma
ORDER BY SUM(num_camas) DESC;

-- 6) Mostra el "porcentaje_ocupacion" més petit de cada província de cada comunitat autònoma
SELECT provincia, comunidad_autonoma, MIN(porcentaje_ocupacion)
FROM hospitales
GROUP BY comunidad_autonoma, provincia
ORDER BY comunidad_autonoma, MIN(porcentaje_ocupacion);

-- 7) Mostra quantes províncies i localitats té cada comunitat autònoma
SELECT 	comunidad_autonoma, 
		COUNT(DISTINCT provincia) AS num_provincies, 
        COUNT(DISTINCT localidad) AS num_localitats
FROM hospitales
GROUP BY comunidad_autonoma;

-- 8) Mostra les comunitats autònomes que tenen menys de 5 hospitals
SELECT comunidad_autonoma, COUNT(hospital_id) AS num_hospitals
FROM hospitales
GROUP BY comunidad_autonoma
HAVING num_hospitals < 5
ORDER BY num_hospitals;

-- 9) Mostra la quantitat d'hospitals per "especialidad" i per "fija". 
-- 		És a dir, quants hospitals tenen una especialitat en funció de si és fixa o no
SELECT especialidad, fija, COUNT(hospital_id) AS num_hospitals
FROM especialidades
GROUP BY especialidad, fija
ORDER BY especialidad;

/*
Exercicis JOIN
*/

-- Sobre la BBDD “biblioteca”:

-- 1. Mostra el nom del llibre i el nom de l'autor dels llibres que són d'abans del 1927.
SELECT libros.titulo, autores.nombre, libros.año_publicacion
FROM biblioteca.libros
JOIN autores
ON libros.autor_id = autores.autor_id
WHERE libros.año_publicacion < 1927
ORDER BY año_publicacion;

-- 2. Sobre la pregunta anterior, quin és l'autor amb més llibres publicats abans de 1927?
SELECT autores.nombre, COUNT(libros.titulo) AS num_libros
FROM libros
JOIN autores
ON libros.autor_id = autores.autor_id
WHERE libros.año_publicacion < 1927
GROUP BY autores.autor_id
ORDER BY num_libros DESC
LIMIT 1;

-- 3. Mostra el nom dels llibres i la quantitat de vegades que han estat retornats amb retard.
-- 	També s'ha de mostrar la mitjana dels dies de retard.
SELECT libros.titulo, 
	COUNT(prestamos.libro_id) AS num_prestamos_retraso,
    AVG(prestamos.dias_retraso) AS media_dias_retraso
FROM prestamos
JOIN libros
ON libros.libro_id = prestamos.libro_id
WHERE prestamos.dias_retraso > 0
GROUP BY prestamos.libro_id
ORDER BY libros.titulo;


-- 4. Mostra la quantitat d'usuaris que no han realitzat cap préstec.
SELECT COUNT(usuarios.usuario_id)
FROM usuarios
LEFT JOIN prestamos
ON usuarios.usuario_id = prestamos.usuario_id
WHERE prestamos.usuario_id IS NULL;

-- 5. Mostra el nom dels 3 usuaris que han fet més préstecs.
SELECT usuarios.nombre, usuarios.apellido, COUNT(prestamos.usuario_id) AS num_prestamos
FROM prestamos
JOIN usuarios
ON prestamos.usuario_id = usuarios.usuario_id
GROUP BY prestamos.usuario_id
ORDER BY num_prestamos DESC, usuarios.usuario_id
LIMIT 3;


-- 6. Mostra el nom i l'ID dels usuaris estrangers 
-- 	i que han hagut de pagar una multa per retard en la devolució del préstec superior a 10 euros.
SELECT DISTINCT u.nombre, u.apellido, u.usuario_id, u.nacionalidad, m.importe
FROM usuarios AS u
JOIN prestamos AS p ON p.usuario_id = u.usuario_id
JOIN multas AS m ON m.prestamo_id = p.prestamo_id
WHERE u.nacionalidad = 'extranjera'
AND m.importe > 10 AND m.pagada = 1
ORDER BY u.usuario_id;


-- 7. Mostra l'autor nascut després de 1980 que ha generat més préstecs en usuaris espanyols. 
-- 	A més, només s'han de comptabilitzar els préstecs finalitzats (ok o amb retard).
SELECT a.nombre, a.año_nacimiento, COUNT(a.autor_id) AS total_prestamos
FROM prestamos AS p
JOIN libros AS l ON l.libro_id = p.libro_id
JOIN autores AS a ON a.autor_id = l.autor_id
JOIN usuarios AS u ON u.usuario_id = p.usuario_id
WHERE a.año_nacimiento > 1980 AND u.nacionalidad = 'española' AND p.estado_prestamo LIKE "fin%"
GROUP BY a.autor_id
ORDER BY total_prestamos DESC
LIMIT 1;


-- 8. Quina és la categoria de llibres que més demanen en préstec les persones que tenen targeta de fidelitat?
SELECT c.nombre, COUNT(c.categoria_id) AS total_categoria
FROM prestamos AS p
JOIN libros AS l ON l.libro_id = p.libro_id
JOIN categorias AS c ON c.categoria_id = l.categoria_id
JOIN usuarios AS u ON u.usuario_id = p.usuario_id
WHERE u.tarjeta_fidelidad = 'Si'
GROUP BY c.categoria_id
ORDER BY total_categoria DESC
LIMIT 1;


-- Sobre la BBDD “hospitales”:

-- B1. Mostra el nom dels hospitals i los pacients extranjers
-- que hi ha a la localitat de Toledo.
SELECT h.nombre, p.nombre, p.nacionalidad 
FROM hospitales.hospitales h
JOIN pacientes p ON p.hospital_id = h.hospital_id 
WHERE h.localidad = 'Toledo'
AND p.nacionalidad = 'Extranjera';


-- B2. Mostra el nom dels hospitals i la quantitat d'especialitats
-- que hi ha als hospitals de la consulta anterior.
SELECT h.nombre, COUNT(e.hospital_id) AS num_especialidades
FROM hospitales h
JOIN especialidades e ON e.hospital_id = h.hospital_id 
WHERE h.localidad = 'Toledo'
GROUP BY h.hospital_id
ORDER BY num_especialidades DESC;


-- B3. Mostra el nom de l’hospital i les especialitats
-- que té l’hospital amb identificador 105.
SELECT h.hospital_id, h.nombre, e.especialidad 
FROM hospitales h
JOIN especialidades e ON e.hospital_id = h.hospital_id
WHERE h.hospital_id = 105
ORDER BY e.especialidad;


-- B4. Digues quants hospitals tenen dades a la taula "hospitales", 
-- però no tenen dades a la taula de "pacientes".
SELECT COUNT(*) 
FROM hospitales h
LEFT JOIN pacientes p ON p.hospital_id = h.hospital_id
WHERE p.hospital_id IS NULL;


-- B5. Mostra el nom de l'hospital
-- que té menys especialitats fixes.
SELECT h.nombre, e.fija, COUNT(*) AS num_especialidades
FROM hospitales h
JOIN especialidades e ON e.hospital_id = h.hospital_id
WHERE e.fija = 'S'
GROUP BY e.hospital_id
ORDER BY num_especialidades
LIMIT 2;


-- B6. Mostra el nom i el nombre total de visites
-- de l'hospital amb identificador 45.
SELECT h.nombre, h.hospital_id, SUM(p.numero_visitas) AS total_visitas
FROM hospitales h
JOIN pacientes p ON p.hospital_id = h.hospital_id
WHERE h.hospital_id = 45
GROUP BY h.hospital_id;


-- B7. Mostra el nom de l'hospital, el nom dels seus pacients estrangers i el nombre de visites, 
-- així com les especialitats que NO són fixes.
-- Totes aquestes dades de l'hospital amb identificador 45.
SELECT h.nombre, h.hospital_id, p.nombre, p.numero_visitas, e.especialidad
FROM hospitales h
JOIN pacientes p ON p.hospital_id = h.hospital_id
JOIN especialidades e ON e.hospital_id = h.hospital_id
WHERE h.hospital_id = 45
AND p.nacionalidad = 'Extranjera'
AND e.fija = 'N'
ORDER BY p.nombre, e.especialidad;


-- B8. Suma el "numero_visitas" de la consulta anterior (a mà)
-- i compara-la amb el "numero_visitas" de la consulta núm. 6. 
-- Són iguals? Què està passant?

-- 40 vs. 166
-- A la consulta 6 sumem el total de visites de TOTS els pacients i TOTES les especialitats
-- A la consulta 7 fem la suma només de pacients estrangers i especilitats no fixes. 


/*
Exercicis SUBQUERIES
*/

-- 1) Quin és el nom de l'empleat (o dels empleats) i la seva posició, 
-- amb el mínim any de contractació?
SELECT nombre, apellido, posicion, año_contratacion
FROM biblioteca.empleados
WHERE año_contratacion = (
	SELECT MIN(año_contratacion) 
    FROM biblioteca.empleados);


-- 2) Mostra el nom de la categoria i el nom del llibre (o llibres), 
-- dels llibres amb l'any de publicació més recent de cada categoria.

/*
-- Subquery Auxiliar para comprobar los años recientes de cada categoria:

SELECT c.nombre, MAX(l.año_publicacion) AS año_reciente
FROM libros l
JOIN categorias c ON c.categoria_id = l.categoria_id
GROUP BY l.categoria_id
ORDER BY c.nombre;
*/

-- Subquery en WHERE IN con 2 campos
SELECT c.nombre, l.titulo, l.año_publicacion
FROM libros l
JOIN categorias c ON c.categoria_id = l.categoria_id
WHERE (c.categoria_id, l.año_publicacion) IN (
	SELECT c.categoria_id, MAX(l.año_publicacion)
	FROM libros l
	JOIN categorias c ON c.categoria_id = l.categoria_id
	GROUP BY l.categoria_id)
ORDER BY c.nombre, l.titulo;

-- Con una Tabla derivada
SELECT c.nombre, l.titulo, l.año_publicacion
FROM libros l
JOIN categorias c ON c.categoria_id = l.categoria_id
JOIN (	
	SELECT c.categoria_id, MAX(l.año_publicacion) AS año_reciente
	FROM libros l
	JOIN categorias c ON c.categoria_id = l.categoria_id
	GROUP BY l.categoria_id
) AS t_aux ON t_aux.categoria_id = c.categoria_id
WHERE l.año_publicacion = t_aux.año_reciente
ORDER BY c.nombre, l.titulo;


-- 3) Mostra els llibres que tenen més còpies 
-- que la mitjana del nombre de còpies dels llibres de la seva categoria.

/*
-- Subquery Auxiliar para saber el promedio de copias de cada categoria:
SELECT 	c.categoria_id AS subcat, 
		c.nombre AS categoria, 
        ROUND(AVG(l.cantidad_copias), 2) AS avg_categoria
FROM libros l
JOIN categorias c ON c.categoria_id = l.categoria_id
GROUP BY l.categoria_id
ORDER BY categoria;
*/

-- Subquery en JOIN (tabla derivada)
SELECT l.titulo, c.nombre AS categoria, l.cantidad_copias AS copias, avg_categoria
FROM libros l
JOIN categorias c ON c.categoria_id = l.categoria_id
JOIN ( 
	SELECT c.categoria_id, ROUND(AVG(l.cantidad_copias), 2) AS avg_categoria
	FROM libros l
	JOIN categorias c ON c.categoria_id = l.categoria_id
	GROUP BY l.categoria_id
) AS t_promedios ON t_promedios.categoria_id = c.categoria_id
WHERE l.cantidad_copias > t_promedios.avg_categoria
ORDER BY c.nombre, l.cantidad_copias DESC, l.titulo;


-- 4) Quin és el nom del llibre i del seu autor, 
-- del llibre que té un import més gran en multes 
-- (comptant la suma de totes les multes de cada llibre)?

/*
-- Subquery auxiliar para averiguar el libro más multado
SELECT p.libro_id AS id_multado, SUM(m.importe) AS total_multas
FROM prestamos p JOIN multas m ON m.prestamo_id = p.prestamo_id
GROUP BY p.libro_id
ORDER BY total_multas DESC
LIMIT 1;
*/

/*
-- Solución usando solamente JOINs:
SELECT p.libro_id AS id_multado, l.titulo, a.nombre, SUM(m.importe) AS total_multas
FROM prestamos p 
JOIN multas m ON m.prestamo_id = p.prestamo_id
JOIN libros l ON l.libro_id = p.libro_id
JOIN autores a ON a.autor_id = l.autor_id
GROUP BY p.libro_id
ORDER BY total_multas DESC
LIMIT 1;
*/

-- Con Subquery en JOIN (tabla derivada con los libros y suma de multas):
SELECT l.titulo, a.nombre, l.libro_id, total_multas
FROM libros l 
JOIN autores a ON a.autor_id = l.autor_id
JOIN (
	SELECT p.libro_id, SUM(m.importe) AS total_multas
	FROM prestamos p JOIN multas m ON m.prestamo_id = p.prestamo_id
	GROUP BY p.libro_id
) AS tabla_multas ON tabla_multas.libro_id = l.libro_id
ORDER BY total_multas DESC
LIMIT 1;


-- B1. Mostra el nom del hospital amb més pressupost
-- de cada comunitat autònoma.

/*
SELECT comunidad_autonoma, nombre, presupuesto_anual_millones
FROM hospitales
WHERE presupuesto_anual_millones in (	
	SELECT MAX(presupuesto_anual_millones)
	FROM hospitales
	GROUP BY comunidad_autonoma);
*/

SELECT h.nombre, h.comunidad_autonoma, h.presupuesto_anual_millones
FROM hospitales.hospitales h
JOIN (
	SELECT h.comunidad_autonoma, MAX(h.presupuesto_anual_millones) AS max_presupuesto
	FROM hospitales.hospitales h
	GROUP BY h.comunidad_autonoma
) AS t_presupuestos ON t_presupuestos.comunidad_autonoma = h.comunidad_autonoma
WHERE h.presupuesto_anual_millones = max_presupuesto;


-- B2. Mostra el nom de l'hospital i el nom del pacient
-- que te menys edat de cada hospital.

/*
SELECT h.hospital_id, h.nombre, p.nombre , p.edad
FROM hospitales h 
JOIN pacientes p ON h.hospital_id = p.hospital_id
WHERE (p.hospital_id, p.edad) IN (
	SELECT hospital_id, MIN(edad)
	FROM pacientes
	GROUP BY hospital_id)
ORDER BY h.hospital_id;
*/

SELECT h.hospital_id, h.nombre, p.nombre, p.edad
FROM hospitales h
JOIN pacientes p ON p.hospital_id = h.hospital_id
JOIN (
	SELECT h.hospital_id, MIN(p.edad) AS edad_minima
	FROM hospitales h
	JOIN pacientes p ON p.hospital_id = h.hospital_id
	GROUP BY h.hospital_id
) AS t_edades ON t_edades.hospital_id = h.hospital_id
WHERE p.edad = edad_minima
ORDER BY h.hospital_id;


-- B3. Mostra els hospitals que estàn per sobre de la mitja de "indice_satisfaccion"
-- de cada comunidad autònoma.

SELECT	h.nombre, h.comunidad_autonoma, 
		h.indice_satisfaccion, 
		ROUND(avg_satisfaccion, 2) AS media_comunidad
FROM hospitales h
JOIN (
	SELECT h.comunidad_autonoma, AVG(h.indice_satisfaccion) AS avg_satisfaccion
	FROM hospitales h
	GROUP BY h.comunidad_autonoma
) AS t_avgs ON t_avgs.comunidad_autonoma = h.comunidad_autonoma
WHERE h.indice_satisfaccion > avg_satisfaccion
ORDER BY h.comunidad_autonoma, h.indice_satisfaccion DESC, h.nombre;


/*
Exercicis UNION
*/

-- 1)
CREATE DATABASE M4_T2;
USE M4_T2;

-- Importo les taules amb Table Wizard

-- 2)
SELECT * FROM M4_T2.nenes
UNION
SELECT * FROM M4_T2.nens;
-- surten 21 registres

-- 3)
SELECT * FROM nenes
UNION ALL
SELECT * FROM nens;
-- surten 22 registres

-- Si fem UNION simplement, no s'inclouen els registres duplicats
-- Quan fem UNION ALL, sí que es repeteixen els registres duplicats
-- En aquest cas, hi ha un alumne de nom "kai" que apareix a les dues taules
-- i en fer UNION ALL apareix dues vegades en la consulta.

-- THE END


