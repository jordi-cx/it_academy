"""
Sprint 9 - Visualizations amb Python
IT Academy - Data Analytics
Jordi Calmet Xartó

https://github.com/jordi-cx/it_academy/tree/main/data_analytics/sprint_09_jcx
"""

# Connexió a BigQuery

from google.colab import auth
from google.cloud import bigquery

# Autenticació del teu usuari de Google
auth.authenticate_user()

# Inicialització del client de BigQuery, indicant el nom del projecte
project_id = 'sprint9-visuals-jordi-calmet'
client = bigquery.Client(project=project_id)

# 3. Definició de la consulta SQL
sql_query = """
SELECT * FROM `sprint9-visuals-jordi-calmet.sprint9_analytics.transactions_clean`
"""

# 4. Execució de la consulta i conversió directa a DataFrame de Pandas
df_transactions = client.query(sql_query).result().to_dataframe()

# 5. Vista prèvia de les teves dades netes
df_transactions.head()

# Dataframes:
# df_transactions (`sprint9-visuals-jordi-calmet.sprint9_analytics.transactions_clean`)
# df_products (`sprint9-visuals-jordi-calmet.sprint9_analytics.products_clean`)
# df_companies (`sprint9-visuals-jordi-calmet.sprint9_analytics.companies_clean`)
# df_users (`sprint9-visuals-jordi-calmet.sprint9_analytics.users_all_clean`)
# df_ccards (`sprint9-visuals-jordi-calmet.sprint9_analytics.credit_cards_clean`)


# Preparación de los df's



# EJERCICIO 1.1: Preguntas analíticas directas

# 1.1.1: Cronología de Transacciones

"""
Com evoluciona el nombre de transaccions al llarg del temps? 
Exemple de passos guiats amb pandas.
Selecciona la columna temporal adequada.
Defineix el nivell temporal d'anàlisi.
Compta el nombre de registres per període temporal.
Ordena els resultats cronològicament.
Visualitza l'evolució amb un gràfic de línies amb pandas

- Dataframe: df_transactions
- Columna: transaction_time
- Nivel temporal: Día (D), Semana (W), Mes (M) o Año (Y)
- Gráfico: Línias (tiempo, número de registres)

- Dataframe:
- Columna:
- Gráfico:
"""

df_transactions.set_index('transaction_time').resample('D').size().plot(
    kind='line',
    figsize=(12, 5),
    title='Cronología de Transacciones',
    xlabel='Tiempo (Días)',
    ylabel='Núm. Transacciones'
)

plt.grid(True)
plt.tight_layout()
plt.show()


"""
ALTERNATIVA IA:

Given the dataframe df_transactions, 
what visualizations would you suggest using the Pandas library 
in order to study the chronology of the number of transactions over time?

You've already created a great monthly view of transactions. 
To further analyze the chronology, you could visualize the daily number of transactions. 
This might reveal shorter-term trends or patterns. Here's how you can do it:
"""


# 1.1.2: Usuarios con mayor Facturación

"""
Quins usuaris generen més volum de facturació? 
Exemple de passos guiats amb seaborn.
Identifica la columna que representa el usuari.
Agrupa les transaccions per usuari i calcula el volum total de facturació sumant la columna amount.
Ordena els usuaris de major a menor volum de facturació.
Selecciona els N usuaris principals (per exemple, els 15 primers).
Representa el resultat mitjançant un gràfic de barres utilitzant Seaborn

- Dataframe: df_transactions
- Columnas: user_id, amount, declined
- Gráfico de Barras (con Seaborn), usuarios / sum(amount)
- Interpretación
"""

# DataFrame intermedio: filtramos, agrupamos, sumamos, ordenamos y limitamos
df_top_users = (
    df_transactions[df_transactions['declined'] == 0]
    .groupby('user_id')['amount']
    .sum()
    .sort_values(ascending=False)
    .head(15)
    .reset_index()
)

# Configuración del gràfico
plt.figure(figsize=(12, 6))

# Gráfico con Seaborn
sns.barplot(
    data=df_top_users, 
    x='user_id', 
    y='amount',
    palette='viridis', # Paleta de colors
    hue='user_id',     # Vinculem el color a l'ID de l'usuari
    legend=False,       # Amaguem la llegenda per no embrutar el gràfic
    order=df_top_users['user_id']
)

# Detalles estéticos (Matplotlib)
plt.title('Top 15 Usuaris per Volum Total de Compra')
plt.xlabel('ID de l\'Usuari')
plt.ylabel('Suma Total d\'Amount')
plt.xticks(rotation=45) # Girem les etiquetes per si els IDs són textos llargs
plt.grid(axis='y', linestyle='--', alpha=0.5) # Afegim quadrícula només horitzontal
plt.tight_layout()
plt.show()

"""
ALTERNATIVA IA:
"""

# Configuración estética de Seaborn
sns.set_theme(style="whitegrid")
plt.figure(figsize=(10, 8))

# Creación del gráfico horizontal
plot = sns.barplot(
    data=df_top_users,
    y=df_top_users['user_id'].astype(str),  # Convertimos a string para que Seaborn lo trate como categoría
    x='amount',
    palette='magma',
    hue='user_id',
    legend=False
)

# Añadir etiquetas de valor al final de cada barra para mayor claridad
for container in plot.containers:
    plot.bar_label(container, fmt='%.0f $', padding=3)

plt.title('Top 15 Usuarios: Volumen Total de Facturación (Vista Horizontal)', fontsize=14)
plt.xlabel('Facturación Total ($)')
plt.ylabel('ID del Usuario')

plt.tight_layout()
plt.show()


# 1.1.3: Distribución horaria de Transacciones (Aceptadas / Rechazadas)

"""
Hi ha diferències en la distribució de l'import de les transaccions 
segons l'hora del dia i si han estat acceptades o rebutjades? 
Exemple de passos guiats amb seaborn.
Crea una nova columna amb l'hora del dia a partir del timestamp.
Utilitza un violinplot de seaborn per analitzar la distribució dels imports.
Assigna: 
x per l'hora del dia, y per l'import de la transacció i hue per l'estat de la transacció.
Activa:
split per comparar acceptades i rebutjades i inner amb quartile per mostrar mediana i quartils.

- Dataframe: df_transactions
- Columnas: transaction_time, transaction_hour, amount, declined
- Gráfico Violinplot (de Seaborn)
- Interpretación
"""

df_transactions['transaction_hour'] = df_transactions['transaction_time'].dt.hour

plt.figure(figsize=(16, 7))

sns.violinplot(
    data=df_transactions,
    x='transaction_hour',
    y='amount',
    hue='declined',
    split=True,          # Divide el violín en dos mitades
    inner='quartile',    # Muestra las línias de la mediana y los cuartiles en cada violín
    palette='Set2'
)

# Detalles visuales i etiquetas
plt.title('Distribución de Transacciones por Hora del Día y Estado', fontsize=14)
plt.xlabel('Hora del Día (0 - 23)', fontsize=12)
plt.ylabel('Importe de la Transacción (Amount)', fontsize=12)
plt.grid(axis='y', linestyle='--', alpha=0.5)
plt.tight_layout()
plt.show()


# Investigo transacciones rechazadas
filtro_rechazadas = df_transactions['declined'] == 1
filtro_hora = df_transactions['transaction_hour'].isin([23, 0, 1])
df_rechazadas = df_transactions[filtro_rechazadas & filtro_hora]
display(df_rechazadas['decline_reason'].value_counts())


"""
ALTERNATIVA IA

Prompt:
Necesito analizar la distribución del amount de las transacciones 
a lo largo de las horas del día. 
También debemos comparar su comportamiento 
según si las transacciones son aceptadas o rechazadas.
Construye un gráfico alternativo adecuado usando Seaborn 
para poder visualizar todo esto.
"""

# Configuración de estilo
sns.set_theme(style="whitegrid")
plt.figure(figsize=(16, 8))

# Creación del Boxplot
sns.boxplot(
    data=df_transactions,
    x='transaction_hour',
    y='amount',
    hue='declined',
    palette='husl',
    fliersize=2  # Tamaño de los puntos atípicos
)

# Personalización
plt.title('Distribución de Importes por Hora y Estado (Aceptada vs Rechazada)', fontsize=15)
plt.xlabel('Hora del Día', fontsize=12)
plt.ylabel('Importe (Amount)', fontsize=12)
plt.legend(title='Rechazada (1)', loc='upper right')

plt.tight_layout()
plt.show()


# 1.1.4: Días de la semana con mayor actividad

"""
- Dataframe: df_transactions
- Columna: transaction_time, transaction_day
- Gráfico: Barras verticales (días de la semana)
"""

display(df_transactions['transaction_time'].dt.day_name().value_counts())

# Nueva columna transaction_day
dias_semana = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

df_transactions['transaction_day'] = pd.Categorical(
    df_transactions['transaction_time'].dt.day_name(),
    categories=dias_semana,
    ordered=True
)

display(df_transactions['transaction_day'].value_counts().sort_index())

# Visualización con Gráfico de Barras

# Dataframe auxiliar
df_transacciones_dias = df_transactions['transaction_day'].value_counts().sort_index().reset_index()

# Renombramos las columnas para el gráfico
df_transacciones_dias.columns = ['dia_semana', 'total_transacciones']

# Configuración del gráfico
plt.figure(figsize=(10, 6))

# Gráfico de barras verticales con Seaborn
grafico = sns.barplot(
    data=df_transacciones_dias,
    x='dia_semana',
    y='total_transacciones',
    palette='mako',
    hue='dia_semana',
    legend=False
)

# Añadimos los valores en cada barra
for container in grafico.containers:
    grafico.bar_label(container, fmt='%d', padding=3, fontsize=11)

# Detalles visuales con Matplotlib
plt.title('Volumen de Transacciones por Día de la Semana', fontsize=14, pad=15)
plt.xlabel('Día de la Semana', fontsize=12)
plt.ylabel('Número de Transacciones', fontsize=12)
plt.grid(axis='y', linestyle='--', alpha=0.5)
plt.tight_layout()
plt.show()


"""
ALTERNATIVA IA

Prompt:
Usando la tabla df_transactions, construye el mejor gráfico posible para ver 
cómo se distribuyen las transacciones por días de la semana.
"""

# EJERCICIO 1.2: Preguntas analíticas complejas

# 1.2.1:
"""
Depenem excessivament d'un nombre reduït de països de companyies venedores?

Passos orientatius:
1. Combinar la informació de transaccions amb la de companyies.
2. Agrupar la facturació per país.
3. Calcular la facturació total generada per cada país.
4. Ordenar els països de major a menor facturació.
5. Calcular el percentatge acumulat sobre el total.
6. Visualitzar.

- Pasos
- Visualización
- Interpretación
"""

# 1. Combinar la información de transacciones con la de compañías
df_transactions_companies = pd.merge(
    df_transactions,
    df_companies,
    left_on='business_id',
    right_on='company_id',
    how='left'
)

# 2. Agrupar la facturación por país
# 3. Calcular la facturación total generada por cada país
# 4. Ordenar los países de mayor a menor facturación
df_transactions_countries = (df_transactions_companies
                             .groupby('country')['amount']
                             .sum()
                             .sort_values(ascending=False)
                             .reset_index())

# 5. Calcular el porcentaje acumulado sobre el total
df_transactions_countries['percent'] = ((df_transactions_countries['amount'] / df_transactions_countries['amount'].sum()) * 100).round(2)

# 6. Visualizar con Gráfico de Barras horizontales
plt.figure(figsize=(10, 8))

grafico_paises = sns.barplot(
    data=df_transactions_countries,
    x='percent',
    y='country',
    palette='crest',
    hue='country',
    legend=False
)

for container in grafico_paises.containers:
    grafico_paises.bar_label(container, fmt='%.2f%%', padding=4, fontsize=10)

plt.title('Distribución de la Facturación per País', fontsize=14, pad=15)
plt.xlabel('Porcentaje sobre el Total (%)', fontsize=12)
plt.ylabel('País', fontsize=12)
plt.grid(axis='x', linestyle='--', alpha=0.5) 

plt.tight_layout()
plt.show()


# 1.2.2:
"""
» Existeix estacionalitat en les vendes?

Passos orientatius:
1. Treballar amb dates de transacció.
2. Extreure la informació temporal rellevant (any i mes).
3. Calcular el volum total de vendes (suma de amount) per any i mes.
4. Comparar patrons temporals amb la comparació entre anys. Crea una taula tipus pivot.
5. Visualitzar l'evolució.

- Pasos
- Visualización
- Interpretación
"""

# Volumen total de ventas por año y mes
df_transacciones_meses = (
    df_transactions[df_transactions['declined'] == 0]
    # Variable temporal con formato "YYYY-MM"
    .assign(year_month=lambda x: x['transaction_time'].dt.strftime('%Y-%m'))
    # Agrupamos por esta columna year-month
    .groupby('year_month')['amount']
    .sum()
)

# Patrones temporales (con pivot table)
df_pivot_meses = (
    df_transactions
    .query("declined == 0")
    .assign(
        year=lambda x: x['transaction_time'].dt.year,
        month=lambda x: x['transaction_time'].dt.month
    )
    .pivot_table(
        values='amount',      # métrica
        index='year',         # filas
        columns='month',      # columnas
        aggfunc='sum',        # Operación (suma)
        fill_value=0,         # valor por defecto
    )
)

totales_por_mes = df_pivot_meses.sum().sort_values(ascending=False)


# Visualización gráfica (mapa de calor)
plt.figure(figsize=(12, 6))

sns.heatmap(
    data=df_pivot_meses, 
    cmap='YlGnBu',
    annot=False,
    linewidths=0.5,
    cbar_kws={'label': 'Volumen de Facturación'}
)

plt.title('Estacionalidad de Transacciones (Año / Mes)', fontsize=14, pad=15)
plt.xlabel('Mes', fontsize=12)
plt.ylabel('Año', fontsize=12)
plt.tight_layout()
plt.show()


# 1.2.3:
"""
» Anàlisi de concentració i variabilitat

Opció A –  
Quins productes generen més ingressos i amb quina variabilitat?

1. Combinar transaccions, la taula pont i productes.
2. Calcular ingressos per producte amb un groupby, sum y sort.
3. Selecciona els top N productes: 15 per exemple.
4. Escollir una visualització adequada per analitzar dispersió

- Visualización
- Interpretación
"""

# 1. Tabla auxiliar de transacciones por productos
sql_query = """
SELECT 
    t.transaction_id, 
    t.transaction_time, 
    TRIM(product_id) AS product_id,
    t.amount
FROM 
    `sprint9-visuals-jordi-calmet.sprint9_analytics.transactions_clean` AS t,
    UNNEST(SPLIT(t.product_ids, ',')) AS product_id
WHERE 
    t.declined = 0
"""

df_transacciones_productos = client.query(sql_query).result().to_dataframe()


# 2. Calcular ingresos por productos
df_ventas_productos = (
    df_transacciones_productos
    .groupby('product_id')['amount']
    .sum()
    .sort_values(ascending=False)
    .reset_index()
    .rename(columns={'amount': 'total_revenue'})
)

# 3. Seleccionar los 15 primeros
top_15_productos = (
    df_ventas_productos
    .head(15)
    .assign(product_id=lambda x: x['product_id'].astype(str))
)

display(top_15_productos)


# Visualización por productos (Gráfico de Barras)
plt.figure(figsize=(10, 8))

grafico_productos = sns.barplot(
    data=top_15_productos,
    x='total_revenue',
    y='product_id',
    palette='magma',
    hue='product_id',
    legend=False
)

for container in grafico_productos.containers:
    grafico_productos.bar_label(container, fmt='%d', padding=3)

plt.title('Top 15 Productos por Ingresos Totales', fontsize=14, pad=15)
plt.xlabel('Ingresos Totales (Total Revenue)', fontsize=12)
plt.ylabel('ID del Producto', fontsize=12)
plt.grid(axis='x', linestyle='--', alpha=0.5)
plt.tight_layout()
plt.show()


# Visualización de Variabilidad (Boxplot)
lista_top_15 = top_15_productos['product_id'].tolist()

df_variabilidad = (
    df_transacciones_productos
    .assign(product_id_str=lambda x: x['product_id'].astype(str))
    .query("product_id_str in @lista_top_15")
)

plt.figure(figsize=(12, 8))

sns.boxplot(
    data=df_variabilitat,
    x='amount',
    y='product_id_str',
    palette='magma',
    hue='product_id_str',
    legend=False,
    order=llista_top_15
)

plt.title('Variabilidad en las Ventas (Top 15 Productos)', fontsize=14, pad=15)
plt.xlabel('Importe por Transacción Individual (Amount)', fontsize=12)
plt.ylabel('ID del Producto', fontsize=12)
plt.grid(axis='x', linestyle='--', alpha=0.5)
plt.tight_layout()
plt.show()


# Métrica exacta de variabilidad
df_metrica_variabilidad = (
    df_variabilidad
    .groupby('product_id_str')['amount']
    .agg(
        mediana='mean',
        desviacion_standard='std'
    )
    .assign(
        coeficiente_variacion_pct=lambda x: (x['desviacion_standard'] / x['mediana']) * 100
    )
    .sort_values('coeficiente_variacion_pct', ascending=False)
    .reset_index()
    .assign(
        mediana=lambda x: x['mediana'].round(2),
        desviacion_standard=lambda x: x['desviacion_standard'].round(2),
        coeficiente_variacion_pct=lambda x: x['coeficiente_variacion_pct'].round(2)
    )
)

display(df_metrica_variabilidad)


# 1.2.4: Patrones horarios
"""
Cómo varía la actividad de ventas por franjas horarias a lo largo de los años?

Pasos:
1. Crear franjas horarias aplicando una función (apply)
2. Construir una tabla agregada utilitzando crosstab
3. Visualitzar con un heatmap
4. Interpretación
"""

# Crear franjas horarias aplicando una función
def obtener_franja_horaria(hora):
    if 6 <= hora < 12:
        return 'Mañana'
    elif 12 <= hora < 18:
        return 'Tarde'
    elif 18 <= hora < 24:
        return 'Noche'
    else:
        return 'Madrugada'

df_transacciones_franjas = (
    df_transactions
    .assign(
        franja_horaria=lambda x: x['transaction_time'].dt.hour.apply(obtener_franja_horaria)
    )
)

display(df_transacciones_franjas[['transaction_time', 'franja_horaria']].head())


# Construir una tabla agregada mediante crosstab
df_transacciones_franjas = df_transacciones_franjas.assign(
    year=lambda x: x['transaction_time'].dt.year
)

df_crosstab_franjas = pd.crosstab(
    index=df_transacciones_franjas['year'],
    columns=df_transacciones_franjas['franja_horaria'],
    margins=True,
    margins_name='Total'
)

df_crosstab_franjas = (
    df_transacciones_franjas
    .assign(year=lambda x: x['transaction_time'].dt.year)
    # 2. Utilitzem .pipe() per passar el DataFrame resultant directament al crosstab
    .pipe(lambda df: pd.crosstab(
        index=df['year'],
        columns=df['franja_horaria'],
        margins=True,
        margins_name='Total'
    ))
)

display(df_crosstab_franjas[['Madrugada', 'Mañana', 'Tarde', 'Noche']])


# Visualitzar con un Heatmap
df_heatmap_horarios = (
    df_crosstab_franjas
    .drop('Total', axis=0)
    .drop('Total', axis=1)
    [['Madrugada', 'Mañana', 'Tarde', 'Noche']]
)

plt.figure(figsize=(10, 6))

sns.heatmap(
    data=df_heatmap_horarios,
    cmap='magma',
    annot=True,
    fmt='d',
    linewidths=0.5,
    cbar_kws={'label': 'Volumem de Transacciones'}
)

plt.title('Evolución de les Transacciones por Franja Horaria', fontsize=14, pad=15)
plt.xlabel('Franja Horaria', fontsize=12)
plt.ylabel('Año', fontsize=12)
plt.tight_layout()
plt.show()


# EJERCICIO 2.1:
"""
Els productes que generen més ingressos també impulsen el creixement del negoci 
mitjançant la captació de nous usuaris, 
o bé el negoci depèn principalment d'usuaris recurrents comprant els mateixos productes? 

Passos orientatius:
1. Combina les taules necessàries

2. Defineix un criteri de nou usuari 
si la transacció analitzada és la primera cronològicament que realitza al sistema 
es_nou_usuari = True / False.

3. Agrega la informació per producte i calcula les mètriques següents:
- Ingressos totals
- Variabilitat dels ingressos
- Nombre de nous usuaris
- Percentatge de nous usuaris sobre el total de compradors del producte

4. Creació d'una tipologia analítica de productes a partir de les mètriques calculades, 
per exemple:
Captador: alta captació de nous usuaris.
Recurrent: ingressos elevats però baixa captació.
Emergent: baixa facturació però bona captació.
Estancat: baixos ingressos i baixa captació.

5. Construeix una visualització que permeti analitzar la relació 
entre les dimensions principals. 
Per exemple, un scatter plot amb:
Eix X → ingressos totals per producte.
Eix Y → nombre de nous usuaris.
Mida del punt → variabilitat dels ingressos.
Color del punt → tipologia analítica del producte.

INTERPRETACIÓN:
Qué implica para el negocio captar nuevos usuarios?
"""

# Tabla con transacciones y tipo de usuarios
sql_query = """
WITH TransaccionesOrdenadas AS (
    SELECT 
        t.transaction_id, 
        t.user_id,
        t.transaction_time, 
        t.amount,
        t.product_ids,
        ROW_NUMBER() OVER(PARTITION BY t.user_id ORDER BY t.transaction_time ASC) as numero_compra
    FROM 
        `sprint9-visuals-jordi-calmet.sprint9_analytics.transactions_clean` AS t
    WHERE 
        t.declined = 0
)

SELECT 
    to_ord.transaction_id, 
    to_ord.user_id,
    to_ord.transaction_time, 
    TRIM(product_id) AS product_id,
    to_ord.amount,
    (to_ord.numero_compra = 1) AS nuevo_usuario
FROM 
    TransaccionesOrdenadas AS to_ord,
    UNNEST(SPLIT(to_ord.product_ids, ',')) AS product_id
"""

df_ventas_info = client.query(sql_query).result().to_dataframe()
display(df_ventas_info.head())


# Merge con información de los productos
df_products = df_products.assign(product_id=lambda x: x['product_id'].astype(str))

df_ventas_info = (
    df_ventas_info
    .assign(product_id=lambda x: x['product_id'].astype(str))
    .merge(
        df_products[['product_id', 'name', 'price', 'category', 'brand']],
        on='product_id',
        how='left'
    )
)


# Análisis de productos

df_productos_info = (
    df_ventas_info
    .groupby(['product_id', 'name'])
    .agg(
        ingresos_totales=('amount', 'sum'),
        media_amount=('amount', 'mean'),
        desviacion_amount=('amount', 'std'),
        num_nuevos_usuarios=('nuevo_usuario', 'sum'),  # Suma los True (1)
        total_compradores=('nuevo_usuario', 'count')
    )
    # Cálculo de las Métricas
    .assign(
        variabilidad_ingresos=lambda x: (x['desviacion_amount'] / x['media_amount']) * 100,
        pct_nuevos_usuarios=lambda x: (x['num_nuevos_usuarios'] / x['total_compradores']) * 100
    )
    # Filtramos las columnas
    [['ingresos_totales', 'variabilidad_ingresos', 'num_nuevos_usuarios', 'pct_nuevos_usuarios']]
    # Ordenamos por ventas
    .sort_values(by='ingresos_totales', ascending=False)
    .reset_index()
    .assign(
        variabilidad_ingresos=lambda x: x['variabilidad_ingresos'].round(2),
        pct_nuevos_usuarios=lambda x: x['pct_nuevos_usuarios'].round(2)
    )
)

display(df_productos_info.head(10))


# Tipologia analítica de productos

ref_ingresos = df_productos_info['ingresos_totales'].median()
ref_captacion = df_productos_info['pct_nuevos_usuarios'].median()

df_productos_info = (
    df_productos_info
    .assign(
        tipologia=lambda x: np.select(
            condlist=[
                # Captador: Ingresos altos y Captación alta
                (x['ingresos_totales'] >= ref_ingresos) & (x['pct_nuevos_usuarios'] >= ref_captacion),
                # Recurrente: Ingresos altos y Captació baja
                (x['ingresos_totales'] >= ref_ingresos) & (x['pct_nuevos_usuarios'] < ref_captacion),
                # Emergente: Ingresos bajos y Captació alta
                (x['ingresos_totales'] < ref_ingresos) & (x['pct_nuevos_usuarios'] >= ref_captacion),
                # Estancado: Ingresos bajos y Captación baja
                (x['ingresos_totales'] < ref_ingresos) & (x['pct_nuevos_usuarios'] < ref_captacion)
            ],
            choicelist=[
                'Captador',
                'Recurrente',
                'Emergente',
                'Estancado'
            ],
            default='Indefinido' # En caso que algun valor sea nulo
        )
    )
)

display(df_productos_info['tipologia'].value_counts())


# Visualización mediante Scatterplot

plt.figure(figsize=(12, 8))

# 2. Definim una paleta de colors personalitzada i amb sentit de negoci
colores = {
    'Captador': '#2ecc71',   # Verde (muchas ventas y muchos usuarios)
    'Recurrente': '#3498db',  # Azul (Fidelidad, ventas aseguradas)
    'Emergente': '#f1c40f',   # Amarillo (Potencial a explotar)
    'Estancado': '#e74c3c',   # Rojo (Atención requerida)
    'Indefinido': '#95a5a6'   # Gris (Default)
}

# 3. Creem el Scatter Plot màgic
sns.scatterplot(
    data=df_productos_info,
    x='ingresos_totales',
    y='num_nuevos_usuarios',
    hue='tipologia',              # Color según la categoría
    size='variabilidad_ingresos', # Tamaño de la burbuja según el riesgo/variabilidad
    sizes=(50, 800),              # Rango de tamaños: de 50 (min)a 800 (max)
    alpha=0.7,                    # Transparencia de las burbujas
    palette=colores
)

plt.title('Matriz Estratégica de Productos', fontsize=16, pad=15)
plt.xlabel('Ingresos Totales', fontsize=12)
plt.ylabel('Número de Nuevos Usuarios', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.5)
plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left', title='Color y Tamaño)')
plt.tight_layout()
plt.show()

"""
Com llegir aquest gràfic com un expert:

Els "Reis" (Dalt a la dreta): Són els productes Captadors (verds). 
Et porten molts ingressos i molts clients nous.

La "Caixa Forta" (Baix a la dreta): Són els Recurrents (blaus). 
Clients de tota la vida gastant molts diners.

Les "Promeses" (Dalt a l'esquerra): Els Emergents (grocs). 
Porten gent nova però potser són molt barats. 
Aquí l'equip de màrqueting hauria d'intentar pujar-ne el preu o fer cross-selling.

El focus de la Variabilitat: Si veus un punt verd molt gran (bombolla grossa), 
significa que factura molt, però depèn de vendes molt erràtiques 
(potser compres majoristes puntuals). 
Si és petit, és un ingrés estable, previsible i de confiança.
"""

# EJERCICIO 2.2: Análisis geográfica y oportunidades de expansión

"""
El negoci està basat en mercats locals (mateix país usuari–companyia) 
o hi ha una oportunitat real d'expansió internacional obrint més companyies en certs països?

Passos orientatius:
1. Combina les taules necessàries.
2. Crea una variable clau d'anàlisi: compra_local = True/False.

3. Analitza el comportament global:
Percentatge de transaccions locals vs internacionals.
Percentatge de facturació local vs internacional.

4. Anàlisi per país de l'usuari, per cada país d'usuari:
Percentatge de compres a companyies del mateix país.
Percentatge de compres a companyies estrangeres.
Import total comprat.

5. Anàlisi per país de companyia, per cada país de companyia 
calcula quina part de la seva facturació ve de:
Usuaris locals.
Usuaris estrangers.

6. Escull una visualització que expliqui clarament el fenomen.

7. Interpretació estratègica:
En quins països valdria la pena obrir més companyies locals?
Hi ha països amb demanda però poca oferta local?
El negoci depèn massa de companyies d'un sol país?
Obrir companyies locals reduiria fricció o milloraria conversió?
"""

# Tabla de datos
df_flujo_paises = (
    df_transactions
    .assign(
        business_id=lambda x: x['business_id'].astype(str),
        user_id=lambda x: x['user_id'].astype(str)
    )
    
    # Añadimos info de empresas
    .merge(
        df_companies
        .assign(company_id=lambda x: x['company_id'].astype(str))
        [['company_id', 'country']],
        
        left_on='business_id',
        right_on='company_id',
        how='left'
    )
    .rename(columns={'country': 'company_country'})
    
    # Añadimos info de usuarios
    .merge(
        df_users
        .assign(user_id=lambda x: x['user_id'].astype(str))
        [['user_id', 'country']],
        
        on='user_id',
        how='left'
    )
    .rename(columns={'country': 'user_country'})
)

display(df_flujo_paises[['transaction_id', 'amount', 'company_country', 'user_country']].head())

# Añadir variable para el análisis: compra_local = True/False
df_flujo_paises = (
    df_flujo_paises
    .assign(
        compra_local=lambda x: np.where(
            x['company_country'] == x['user_country'], True, False
        ))
)

# Análisi del comportamiento global:
# Porcentaje de transacciones locales vs internacionales
# Porcentaje de facturación local vs internacional

df_analisis_flujo_global = (
    df_flujo_paises
    .groupby('compra_local')
    .agg(
        total_transacciones=('transaction_id', 'count'),
        facturacion_total=('amount', 'sum')
    )
    .assign(
        pct_transacciones=lambda x: (x['total_transacciones'] / x['total_transacciones'].sum()) * 100,
        pct_facturacion=lambda x: (x['facturacion_total'] / x['facturacion_total'].sum()) * 100
    )
    .reset_index()
    .assign(
        tipo_mercado=lambda x: np.where(x['compra_local'], 'Local', 'Internacional')
    )
    [['tipo_mercado', 'total_transacciones', 'pct_transacciones', 'facturacion_total', 'pct_facturacion']]
    .assign(
        pct_transacciones=lambda x: x['pct_transacciones'].round(2),
        pct_facturacion=lambda x: x['pct_facturacion'].round(2),
        facturacion_total=lambda x: x['facturacion_total'].round(2)
    )
)

display(df_analisis_flujo_global)

"""
Aquesta matriu de dues files et donarà una visió macro instantània 
del model de negoci de l'empresa:

Disparitat de tiquet mitjà: 
Si veus que el pct_transacciones internacional és del 20%, 
però el seu pct_facturacion és del 40%, 
voldrà dir que les compres internacionals són molt menys freqüents 
però mouen molts més diners per cistella 
(potser l'enviament internacional només surt a compte per a comandes grans).

Dependència del mercat: 
Et dirà d'una ullada si la plataforma és principalment una eina de comerç de proximitat 
o un veritable hub global de vendes.
"""


# Análisis por país de compra
# Para cada país del usuario:
# Porcentaje de compras a empresas del mismo país
# Porcentaje de compras a empresas extranjeras
# Importe total comprado

df_analisis_paises_compras = (
    df_flujo_paises
    .groupby('user_country')
    .agg(
        importe_total_compras=('amount', 'sum'),
        proporcion_local=('compra_local', 'mean') 
    )
    .assign(
        pct_compra_local=lambda x: x['proporcion_local'] * 100,
        pct_compra_internacional=lambda x: 100 - (x['proporcion_local'] * 100)
    )
    .reset_index()
    [['user_country', 'pct_compra_local', 'pct_compra_internacional', 'importe_total_compras']]
    .sort_values('importe_total_compras', ascending=False)
    .assign(
        pct_compra_local=lambda x: x['pct_compra_local'].round(2),
        pct_compra_internacional=lambda x: x['pct_compra_internacional'].round(2),
        importe_total_compras=lambda x: x['importe_total_compras'].round(2)
    )
)

display(df_analisis_paises_compras.head(10))


# Análisis por país de venta
# Para cada país de las empresas, calcular qué parte de su facturación viene de: 
# Usuarios locales
# Usuarios internacionales

df_analisis_paises_ventas = (
    df_flujo_paises
    .groupby('company_country')
    .agg(
        importe_total_ventas=('amount', 'sum'),
        total_usuarios=('transaction_id', 'count'),
        usuarios_locales=('compra_local', 'sum'),
        proporcion_local=('compra_local', 'mean') 
    )
    .assign(
        usuarios_internacionales=lambda x: x['total_usuarios'] - x['usuarios_locales'],
        pct_venta_local=lambda x: x['proporcion_local'] * 100,
        pct_venta_internacional=lambda x: 100 - (x['proporcion_local'] * 100)
    )
    .reset_index()
    .sort_values('importe_total_ventas', ascending=False)
    [['company_country', 'importe_total_ventas', 
    'pct_venta_local', 'pct_venta_internacional', 
    'usuarios_locales', 'usuarios_internacionales']]
    .assign(
        importe_total_ventas=lambda x: x['importe_total_ventas'].round(2),
        pct_venta_local=lambda x: x['pct_venta_local'].round(2),
        pct_venta_internacional=lambda x: x['pct_venta_internacional'].round(2),
    )
)

display(df_analisis_paises_ventas.head(10))


# Visualización por Países Compras (Gráfico de Barras Apiladas)

df_top_compras = df_analisis_paises_compras.head(5)
df_top_compras = (
    df_top_compras
    .set_index('user_country')
    [['pct_compra_local', 'pct_compra_internacional']]
)

plt.style.use('dark_background')
plt.figure(figsize=(10, 6))

grafico = df_top_compras.plot(
    kind='bar',
    stacked=True,
    color=['#82E0AA', '#C39BD3'],
    width=0.6,
    ax=plt.gca()
)

for p in grafico.patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy()
    
    if height > 5:
        grafico.text(
            x + width / 2,         
            y + height / 2,        
            f'{height:.0f}%',      
            horizontalalignment='center',
            verticalalignment='center',
            color='white',
            fontweight='bold',
            fontsize=10
        )

plt.title('Top 5 Países Compras: Consumo Local vs Internacional', fontsize=16, pad=20, fontweight='bold')
plt.xlabel('País del Comprador)', fontsize=12)
plt.ylabel('Porcentaje del Consumo Total', fontsize=12)
plt.xticks(rotation=0)
plt.legend(
    ['Compra Local', 'Compra Internacional'],
    bbox_to_anchor=(1.05, 1),
    loc='upper left',
    frameon=False
)
plt.tight_layout()
plt.show()


# Visualización por Países Ventas (Gráfico de Barras Apiladas)

df_top_ventas = df_analisis_paises_ventas.head(5)
df_top_ventas = df_top_ventas.set_index('company_country')[['pct_venta_local', 'pct_venta_internacional']]

plt.style.use('dark_background') # plt.style.use('default')
plt.figure(figsize=(10, 6))

# Gráfico de barras apiladas des de Pandas
grafico = df_top_ventas.plot(
    kind='bar',
    stacked=True,
    color=['#00E5FF', '#FF007F'],
    width=0.6,
    ax=plt.gca()
)

for p in grafico.patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy()
    
    if height > 5:
        grafico.text(
            x + width / 2,
            y + height / 2,
            f'{height:.0f}%',
            horizontalalignment='center',
            verticalalignment='center',
            color='white',
            fontweight='bold',
            fontsize=10
        )

plt.title('Top 5 Países: Facturación Local vs Internacional', fontsize=16, pad=20, fontweight='bold')
plt.xlabel('País de la Empresa Vendedora', fontsize=12)
plt.ylabel('% de Facturación', fontsize=12)
plt.xticks(rotation=0)
plt.legend(
    ['Venta Local', 'Venta Internacional'],
    bbox_to_anchor=(1.05, 1),
    loc='upper left',
    frameon=False
)
plt.tight_layout()
plt.show()


"""
Interpretación Estratégica:
- En qué países valdría la pena abrir más empresas locales?
- Hay países con demanda pero poca oferta local?
- El negocio depende demasiado de empresas de un solo país?
- Abrir empresas locales reduciría la fricción o mejoraría la conversión?
"""


# EJERCICIO 3.1: Mini-dashboard departamental

"""
Figura única amb subplots (enfocament analític clàssic)
Construcció d'una única figura amb 4 subplots 
utilitzant matplotlib i/o seaborn.
Requisits:
1 figura
4 visualitzacions diferents

Orientat a un dels següents departaments:
» Marketing
» Vendes / Comercial
» Producció
» Sistemes / Ciberseguretat

Les visualitzacions han de ser:
» Rellevants per al departament escollit.
» Clares i llegibles.
» Coherents entre si.
"""

# Tabla sobre las transacciones rechazadas
df_resumen_declined = (
    df_flujo_paises
    .groupby('declined')
    .agg(
        importe_total=('amount', 'sum'),
        total_transacciones=('amount', 'count')
    )
    .assign(
        pct_transacciones=lambda x: (x['total_transacciones'] / x['total_transacciones'].sum()) * 100,
        pct_facturacion=lambda x: (x['importe_total'] / x['importe_total'].sum()) * 100
    )
    .reset_index()
    .assign(
        estado_transaccion=lambda x: np.where(x['declined'] == 1, 'Declined', 'Accepted'),
        importe_total=lambda x: x['importe_total'].round(2),
        pct_transacciones=lambda x: x['pct_transacciones'].round(2),
        pct_facturacion=lambda x: x['pct_facturacion'].round(2)
    )
    [['estado_transaccion', 'total_transacciones', 'pct_transacciones', 'pct_facturacion', 'importe_total']]
    .sort_values('total_transacciones', ascending=False)
)

display(df_resumen_declined)


# Análisis Transacciones Rechazadas (Fraudes o Problemas Técnicos)
filtro_problematicas = ((df_flujo_paises['declined'] == 1) & 
 (df_flujo_paises['decline_reason'].isin(['suspected_fraud', 'technical_error'])))

df_analisis_problematicas = df_flujo_paises[filtro_problematicas]

filtro_problematicas = ((df_flujo_paises['declined'] == 1) & 
 (df_flujo_paises['decline_reason'].isin(['suspected_fraud', 'technical_error'])))

df_analisis_problematicas = df_flujo_paises[filtro_problematicas]

# Preparamos el dataset para el análisis
df_analisis_problematicas = (
    df_analisis_problematicas
    .assign(user_id=lambda x: x['user_id'].astype(str))
    .merge(
        df_users.assign(user_id=lambda x: x['user_id'].astype(str)), 
        on='user_id', 
        how='left'
    )
)

df_analisis_problematicas = (
    df_analisis_problematicas
    .assign(
        transaction_day=lambda x: pd.to_datetime(x['transaction_time']).dt.normalize(),
        signup_day=lambda x: pd.to_datetime(x['signup_date']).dt.normalize(),        
        antiguedad_dias_usuario=lambda x: (x['transaction_day'] - x['signup_day']).dt.days,        
        es_usuario_reciente=lambda x: x['antiguedad_dias_usuario'] <= 90
    )
)

df_analisis_problematicas = (
    df_analisis_problematicas
    .drop(columns=['transaction_hour','latitude', 'longitude', 
                   'discount_amount', 'tax_amount', 'shipping_amount', 
                   'campaign_id', 'is_international', 'distance_km', 
                   'country'])
    .rename(columns={'city': 'user_city', 'address': 'user_address', 
                     'region': 'user_region'})
)

df_analisis_problematicas = (
    df_analisis_problematicas
    .assign(
        user_name_surname=lambda x: x['name'] + ' ' + x['surname'],
        birth_date_dt=lambda x: pd.to_datetime(x['birth_date']),
        user_age=lambda x: np.floor((x['transaction_day'] - x['birth_date_dt']).dt.days / 365.25).astype(int)
    )
    .drop(columns=['name', 'surname', 'birth_date_dt'])
)

display(df_analisis_problematicas.info())

"""
df_analisis_problematicas:

#   Column                   Non-Null Count  Dtype         
---  ------                   --------------  -----         
 0   transaction_id           349 non-null    object        
 1   card_id                  349 non-null    object        
 2   business_id              349 non-null    object        
 3   transaction_time         349 non-null    datetime64[ns]
 4   amount                   349 non-null    float64       
 5   declined                 349 non-null    Int64         
 6   product_ids              349 non-null    object        
 7   user_id                  349 non-null    object        
 8   channel                  349 non-null    object        
 9   device_type              349 non-null    object        
 10  decline_reason           349 non-null    object        
 11  company_id               349 non-null    object        
 12  company_country          349 non-null    object        
 13  user_country             349 non-null    object        
 14  compra_local             349 non-null    bool          
 15  user_phone               349 non-null    object        
 16  user_email               349 non-null    object        
 17  birth_date               349 non-null    dbdate        
 18  user_city                349 non-null    object        
 19  postal_code              349 non-null    object        
 20  user_address             349 non-null    object        
 21  user_region              349 non-null    object        
 22  signup_date              349 non-null    dbdate        
 23  user_segment             349 non-null    object        
 24  income_band              349 non-null    object        
 25  transaction_day          349 non-null    datetime64[ns]
 26  signup_day               349 non-null    datetime64[ns]
 27  antiguedad_dias_usuario  349 non-null    int64         
 28  es_usuario_reciente      349 non-null    bool          
 29  user_name_surname        349 non-null    object        
 30  user_age                 349 non-null    int64
 31  rango_edad               349 non-null    category    
"""

# Visualización Tipo de Transacciones problemáticas (Pie Chart)
motivos_declined = df_pais_problematico['decline_reason'].value_counts()

plt.style.use('dark_background')
plt.figure(figsize=(8, 8))

motivos_declined.plot(
    kind='pie',
    autopct='%1.1f%%',
    startangle=90,
    colors=['#FF3366', '#FF9933', '#00E5FF', '#B026FF'],
    explode=[0.03] * len(motivos_declined),
    ylabel='',
    textprops={'fontsize': 12, 'fontweight': 'bold', 'color': 'white'}
)

plt.title('Distribución Transacciones Problemáticas', fontsize=16, pad=20, fontweight='bold')
plt.tight_layout()
plt.show()


# Visualización Total Amount de Transacciones Problemáticas
importes_declined = (
    df_pais_problematico
    .groupby('decline_reason')['amount']
    .sum()
    .sort_values(ascending=False)
)

def formato_etiquetas(pct, valores):
    valor_absoluto = (pct / 100.) * sum(valores)
    return f"{pct:.1f}%\n({valor_absoluto:,.0f} €)"

plt.style.use('dark_background')
plt.figure(figsize=(9, 9))

importes_declined.plot(
    kind='pie',
    autopct=lambda pct: formato_etiquetas(pct, importes_declined),
    startangle=90,
    colors=['#FF3366', '#FF9933', '#00E5FF', '#B026FF'],
    explode=[0.03] * len(importes_declined),
    ylabel='',
    textprops={'fontsize': 11, 'fontweight': 'bold', 'color': 'white'}
)

plt.title('Impacto Económico Transacciones Problemáticas', fontsize=16, pad=20, fontweight='bold')
plt.tight_layout()
plt.show()


# Visualización por Rangos de Edad y Motivos de Fallo
edad_motivo_declined = pd.crosstab(
    df_pais_problematico['rango_edad'], 
    df_pais_problematico['decline_reason']
)

plt.style.use('dark_background')
plt.figure(figsize=(10, 6))

ax = edad_motivo_declined.plot(
    kind='bar',
    stacked=True,
    color=['#FF3366', '#FF9933', '#00E5FF', '#B026FF'], # Mantenim la teva paleta
    width=0.6,
    ax=plt.gca()
)

for p in ax.patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy()
    
    if height > 0:
        ax.text(
            x + width / 2,         
            y + height / 2,        
            f'{int(height)}',
            horizontalalignment='center',
            verticalalignment='center',
            color='white',
            fontweight='bold',
            fontsize=10
        )

plt.title('Incidencias por Rango de Edad y Motivo', fontsize=16, pad=20, fontweight='bold')
plt.xlabel('Franja de Edad', fontsize=12)
plt.ylabel('Motivos Fallo Transacciones', fontsize=12)
plt.xticks(rotation=0)
plt.legend(
    title='Problemática Tansacciones',
    bbox_to_anchor=(1.05, 1),
    loc='upper left',
    frameon=False
)
plt.tight_layout()
plt.show()


# Visualización por Nivel Económico y Motivos de Fallo
nivel_motivo_declined = (
    pd.crosstab(
        df_pais_problematico['income_band'], 
        df_pais_problematico['decline_reason']
    )
    .reindex(['low', 'medium', 'high'])
    # .loc[lambda x: x.sum(axis=1).sort_values(ascending=False).index]
)

plt.style.use('dark_background')
plt.figure(figsize=(10, 6))

ax = nivel_motivo_declined.plot(
    kind='bar',
    stacked=True,
    color=['#FF3366', '#FF9933', '#00E5FF', '#B026FF'],
    width=0.6,
    ax=plt.gca()
)

for p in ax.patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy()
    
    if height > 0:
        ax.text(
            x + width / 2,         
            y + height / 2,        
            f'{int(height)}',
            horizontalalignment='center',
            verticalalignment='center',
            color='white',
            fontweight='bold',
            fontsize=10
        )

plt.title('Incidencias por Nivel Económico y Motivo', fontsize=16, pad=20, fontweight='bold')
plt.xlabel('Nivel Económico Usuario', fontsize=12)
plt.ylabel('Transacciones Problemáticas', fontsize=12)
plt.xticks(rotation=0)
plt.legend(
    title='Problemática Tansacciones',
    bbox_to_anchor=(1.05, 1),
    loc='upper left',
    frameon=False
)
plt.tight_layout()
plt.show()


# Mini-dashboard Visualización de Transacciones problemáticas

plt.style.use('dark_background')
fig, axes = plt.subplots(2, 2, figsize=(18, 14))

# --- GRÁFICO 1 [0, 0] ---
motivos_declined.plot(
    kind='pie',
    ax=axes[0, 0],
    autopct=lambda p: f'{p:.1f}%\n({int(round(p * motivos_declined.sum() / 100))})',
    startangle=90,
    colors=['#FF3366', '#FF9933', '#00E5FF', '#B026FF'],
    explode=[0.03] * len(motivos_declined),
    ylabel='',
    textprops={'fontsize': 16, 'fontweight': 'bold', 'color': 'white'}
)
axes[0, 0].set_title('Distribución Transacciones', fontsize=14, fontweight='bold', pad=15)

# --- GRÁFICO 2 [0, 1] ---
importes_declined.plot(
    kind='pie',
    ax=axes[0, 1],
    autopct=lambda p: f'{p:.1f}%\n({(p * importes_declined.sum() / 100):,.0f} €)',
    startangle=90,
    colors=['#FF3366', '#FF9933', '#00E5FF', '#B026FF'],
    explode=[0.03] * len(importes_declined),
    ylabel='',
    textprops={'fontsize': 16, 'fontweight': 'bold', 'color': 'white'}
)
axes[0, 1].set_title('Impacto Económico', fontsize=14, fontweight='bold', pad=15)

# --- GRÁFICO 3 [1, 0] ---
edad_motivo_declined.plot(
    kind='bar',
    stacked=True,
    ax=axes[1, 0],
    color=['#FF3366', '#FF9933', '#00E5FF', '#B026FF'],
    width=0.8,
    legend=False
)

for p in axes[1, 0].patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy()
    
    if height > 0:
        axes[1, 0].text(
            x + width / 2,         
            y + height / 2,        
            f'{int(height)}',
            horizontalalignment='center',
            verticalalignment='center',
            color='white',
            fontweight='bold',
            fontsize=16
        )

axes[1, 0].set_title('Incidencias por Rango de Edad y Motivo', fontsize=14, fontweight='bold', pad=15)
axes[1, 0].set_xlabel('Franja de Edad Usuario', fontsize=14)
axes[1, 0].set_ylabel('Motivos Fallo Transacciones', fontsize=14)
axes[1, 0].tick_params(axis='x', rotation=0)

# --- GRÁFICO 4 [1, 1] ---
nivel_motivo_declined.plot(
    kind='bar',
    stacked=True,
    ax=axes[1, 1],
    color=['#FF3366', '#FF9933', '#00E5FF', '#B026FF'],
    width=0.8,
    legend=False
)

for p in axes[1, 1].patches:
    width, height = p.get_width(), p.get_height()
    x, y = p.get_xy()
    
    if height > 0:
        axes[1, 1].text(
            x + width / 2,         
            y + height / 2,        
            f'{int(height)}',
            horizontalalignment='center',
            verticalalignment='center',
            color='white',
            fontweight='bold',
            fontsize=16
        )

axes[1, 1].set_title('Incidencias por Nivel Económico y Motivo', fontsize=14, fontweight='bold', pad=15)
axes[1, 1].set_xlabel('Nivel Económico Usuario', fontsize=14)
axes[1, 1].set_ylabel('Motivos Fallo Transacciones', fontsize=14)
axes[1, 1].tick_params(axis='x', rotation=0)

handles, labels = axes[1, 0].get_legend_handles_labels()

fig.legend(
    handles, labels,
    loc='upper center',
    bbox_to_anchor=(0.5, 0.94),
    ncol=4,
    frameon=False,
    fontsize=15
)

plt.suptitle('Análisis Transacciones Problemáticas', fontsize=20, fontweight='bold', y=1.02)

plt.tight_layout(rect=[0, 0, 1, 0.90]) 
plt.show()


# EJERCICIO 3.2: INFORME EJECUTIVO

"""
1. Resum general (màx. 5 línies): Què s'ha analitzat i amb quin objectiu.
2. Troballes clau (3-5): Insights sòlids basats en dades reals.
3. Riscos detectats: Per exemple, dependència excessiva de productes o empreses, 
manca de captació de nous usuaris, franges horàries crítiques, 
possibles indicis de frau o anomalies...
4. Oportunitats: millores operatives, segments no explotats, 
productes o franges amb potencial, optimització de recursos...
5. Recomanacions: Accions concretes i no tècniques, orientades a negoci.

» Amb suport d'IA per:
Millorar la redacció.
Adaptar el llenguatge al departament escollit.
Incorporar vocabulari tècnic de negoci.
"""