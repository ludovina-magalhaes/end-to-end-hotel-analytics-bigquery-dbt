# 🏨 Hotel Booking Analytics Platform

##  Descripción del proyecto

Este proyecto implementa un pipeline end-to-end de datos para el análisis de reservas hoteleras, con foco en revenue, cancelaciones y comportamiento del cliente.

El objetivo es transformar datos brutos en métricas de negocio listas para la toma de decisiones, siguiendo buenas prácticas de Analytics Engineering.

---

##  Objetivos

* Construir un pipeline completo desde ingestión hasta visualización
* Aplicar modelado en capas (raw → staging → intermediate → marts)
* Generar métricas clave del sector hotelero (RevPAR, ADR, cancelaciones)
* Preparar datos optimizados para dashboards en Power BI
* Simular una arquitectura real de Data Warehouse

---

##  Arquitectura

<img width="1359" height="579" alt="image" src="https://github.com/user-attachments/assets/a58d1d70-bad3-4e0a-9b1b-3f9fc8785141" />


---

##  Tecnologías utilizadas

* Python (pandas, kagglehub, google-cloud-bigquery)
* Google BigQuery (Data Warehouse)
* dbt (transformaciones y modelado)
* Power BI (visualización)
* Git + VSCode (desarrollo)

---

##  Ingestión de datos

### Fuente de datos

Dataset público de Kaggle:

```
Hotel Booking Demand
```

### Proceso

El script:

```text
ingestion/load_kaggle_to_bigquery.py
```

realiza:

1. Descarga del dataset desde Kaggle
2. Lectura del CSV con pandas
3. Limpieza básica (nulos, tipos)
4. Adición de campo `ingestion_ts`
5. Carga en BigQuery

### Resultado

Tabla creada:

```text
analytics-enginner.raw.hotel_bookings
```

---

##  Autenticación

Se utilizó una **cuenta de servicio de Google Cloud**:

* Rol: BigQuery Admin
* Autenticación vía JSON

Variable de entorno:

```bash
GOOGLE_APPLICATION_CREDENTIALS="ruta/al/json"
```

---

##  Modelado con dbt

El proyecto sigue una arquitectura en capas:

### 🔹 1. RAW

```text
raw.hotel_bookings
```

Datos sin transformación.

---

###  2. STAGING

```text
analytics.stg_bookings
```

Transformaciones:

* Tipos de datos (cast)
* Creación de fechas (`arrival_date`)
* Métricas base:

  * total_nights
  * total_guests
* Flags:

  * is_canceled_flag

---

###  3. INTERMEDIATE

```text
analytics.int_bookings_transformed
```

Enriquecimiento con lógica de negocio:

* Revenue:

  * gross_booking_amount
  * net_booking_amount
  * canceled_booking_amount
* Segmentaciones:

  * lead_time_segment
  * guest_segment
  * stay_segment
* Historial:

  * historical_cancellation_rate
* Operacional:

  * room_change_type

---

###  4. FACT TABLE

```text
analytics.fct_bookings
```

Tabla central a nivel de reserva.

Incluye:

* Métricas financieras
* Comportamiento del cliente
* Información operacional
* Segmentaciones analíticas

---

###  5. MARTS

Tablas agregadas para análisis:

####  mart_revenue

* Revenue total, neto y perdido
* ADR medio
* RevPAR ajustado
* Ocupación aproximada

####  mart_cancellations

* Cancelaciones por canal
* Impacto económico
* Lead time

####  mart_behavior

* Lead time medio
* ADR por segmento
* Clientes recurrentes

####  mart_operational

* Diferencia entre habitación reservada y asignada
* Impacto en cancelación y revenue

 Este mart representa el principal diferencial del proyecto.

---

##  Métricas clave

### Revenue

* Net Revenue
* Gross Revenue
* Lost Revenue

### Performance hotelera

* ADR (Average Daily Rate)
* RevPAR (Revenue per Available Room)

### Cancelaciones

* Cancellation Rate
* Impacto financiero de cancelaciones

### Comportamiento

* Lead Time
* Repeated Guest Rate

---

##  Visualización

Conexión realizada con:

```
Power BI → Google BigQuery
```

Dashboard estructurado en:

* Overview
* Revenue
* Cancelaciones
* Comportamiento
* Operacional

---

##  Estado actual

✔ Ingestión de datos
✔ Data Warehouse en BigQuery
✔ Modelado completo en dbt
✔ Tests de calidad de datos
✔ Marts analíticos
✔ Conexión a Power BI

---

##  Próximos pasos

* Construcción completa del dashboard
* Implementación de Airflow + Cosmos (orquestación)
* Modelos incrementales en dbt
* Particionamiento y clustering en BigQuery
* Documentación técnica adicional

---

##  Valor del proyecto

Este proyecto simula un entorno real de trabajo como Analytics Engineer:

* Pipeline completo
* Modelado escalable
* Métricas de negocio reales
* Preparación para consumo analítico

---

##  Autor

Ludovina Magalhães
Analytics Engineer

---
