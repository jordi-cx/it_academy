# Canciones en la Pantalla: Grandes Films, ¿Grandes Hits? 🎬🎵

## 📌 Descripción del Proyecto
Este proyecto de análisis de datos investiga la relación histórica y el impacto entre el éxito comercial de las películas en taquilla y el rendimiento de sus canciones originales en las plataformas de streaming y otros ámbitos. El estudio abarca una muestra representativa de **500 canciones** en un periodo comprendido entre **1937 y 2025**.

## 🎯 Criterios de Selección
Se ha utilizado el estándar de elegibilidad oficial de la **Academy of Motion Picture Arts and Sciences (AMPAS)**:
* Solo se incluyen **canciones originales** (letra y música) lanzadas al mercado en conjunto con la película.
* Se excluyen estrictamente las piezas musicales preexistentes al momento del estreno del film.

## 🛠️ Arquitectura de Datos y Herramientas
* **Procesamiento y Análisis:** Python (Pandas) en entorno Visual Studio Code.
* **Visualización:** Python (Seaborn).
* **Modelado:** Arquitectura de datos basada en un **Esquema en Estrella**, separando dimensiones (`films`, `songs`) conectadas a través de la tabla de hechos (`songs_films`).

## 🔬 Metodología Analítica

### 1. Análisis Unidimensional (Taquilla vs. Streaming)
La exploración inicial evaluó la relación directa entre la recaudación del filme y las reproducciones de las canciones (streams).
* **Resultado:** Correlación de Spearman moderada ($r = 0,472$).
* **Interpretación:** La recaudación en taquilla explica apenas un **20%** ($R^2 \approx 0,20$) del éxito real de la canción en las plataformas de *streaming*.

### 2. Índice Compuesto Multidimensional
Para superar las limitaciones del análisis de una sola variable, se desarrolló un modelo heurístico propio que evalúa las canciones mediante tres macro-bloques ponderados:
* 💰 **Factor Comercial** (Volumen y alcance masivo)
* 🎧 **Factor Audiencia** (Engagement y lealtad del oyente)
* 🏆 **Factor Prestigio** (Reconocimiento crítico e institucional)

Se aplicó una **Normalización Min-Max** a las variables para garantizar su comparabilidad y evitar la distorsión por valores atípicos (*outliers*). El modelo se diseñó manteniendo la lógica de distribución original en los rankings para evitar penalizar a las entradas situadas en la parte inferior de la escala, asumiendo estadísticamente que nuestro *dataset* representa solo una fracción de todas las obras cinematográficas existentes.

### 3. Análisis de Sensibilidad y "Consensus Blockbusters"
Se sometió el modelo a una prueba de robustez bajo tres escenarios de estrés:
1. Escenario Equilibrado
2. Escenario con Sesgo Comercial
3. Escenario con Sesgo de Prestigio

Mediante **teoría de conjuntos**, se aislaron los resultados transversales para descubrir a los **"Consensus Blockbusters"**: un selecto grupo de obras que se mantienen en la élite bajo cualquiera de estas métricas analíticas. Esto permitió identificar de forma empírica el subconjunto de composiciones más trascendentales de la historia de la música y el cine.

## 💡 Conclusiones
* El éxito masivo de una canción de película **no está fuertemente correlacionado con la recaudación en taquilla** del film que la acompaña.
* La trascendencia de un hit responde a una compleja red de factores comerciales, sociológicos y culturales que van mucho más allá de la pantalla.
* Las mejores canciones de la historia (los *Consensus Blockbusters*) son aquellas obras resilientes que perviven y dominan estadísticamente, sea cual sea la ponderación de los factores evaluados.