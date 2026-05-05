{{ config(
    materialized='view'
) }}

with bookings as (

    select *
    from {{ ref('stg_bookings') }}

),

enriched as (

    select
        -- identidad
        booking_sk,
        hotel,

        -- cancelación
        is_canceled,
        is_canceled_flag,

        -- lead time
        lead_time,

        -- fecha de llegada
        arrival_date_year,
        arrival_date_month,
        arrival_date_week_number,
        arrival_date_day_of_month,
        arrival_date,

        -- dimensiones temporales derivadas
        extract(year from arrival_date) as arrival_year,
        extract(month from arrival_date) as arrival_month_number,
        extract(quarter from arrival_date) as arrival_quarter,
        format_date('%A', arrival_date) as arrival_weekday_name,

        -- estancia
        stays_in_weekend_nights,
        stays_in_week_nights,
        total_nights,

        -- huéspedes
        adults,
        children,
        babies,
        total_guests,

        -- atributos de reserva
        meal,
        country,
        market_segment,
        distribution_channel,

        -- historial del cliente
        is_repeated_guest,
        previous_cancellations,
        previous_bookings_not_canceled,

        -- habitación
        reserved_room_type,
        assigned_room_type,
        room_changed_flag,

        case
            when room_changed_flag then 'changed'
            else 'no_change'
        end as room_change_type,

        -- operacional
        booking_changes,
        deposit_type,
        agent_id,
        company_id,
        days_in_waiting_list,
        customer_type,

        -- revenue
        adr,

        -- servicios
        required_car_parking_spaces,
        total_of_special_requests,

        -- estado de reserva
        reservation_status,
        reservation_status_date,

        -- auditoría
        ingestion_ts,

        -- métricas de revenue
        round(adr * total_nights, 2) as gross_booking_amount,

        case
            when is_canceled = 1 then 0
            else round(adr * total_nights, 2)
        end as net_booking_amount,

        case
            when is_canceled = 1 then round(adr * total_nights, 2)
            else 0
        end as canceled_booking_amount,

        case
            when total_guests = 0 then null
            else round((adr * total_nights) / total_guests, 2)
        end as revenue_per_guest,

        -- contadores
        case
            when is_canceled = 1 then 1
            else 0
        end as canceled_bookings,

        case
            when is_canceled = 0 then 1
            else 0
        end as confirmed_bookings,

        case
            when is_canceled = 0 then total_nights
            else 0
        end as confirmed_nights,

        case
            when room_changed_flag then 1
            else 0
        end as room_changed_bookings,

        -- historial
        previous_cancellations
            + previous_bookings_not_canceled as total_previous_bookings,

        case
            when (previous_cancellations + previous_bookings_not_canceled) = 0 then null
            else round(
                previous_cancellations
                / (previous_cancellations + previous_bookings_not_canceled),
                4
            )
        end as historical_cancellation_rate,

        -- segmentaciones analíticas
        case
            when lead_time <= 7 then 'last_minute'
            when lead_time between 8 and 30 then 'short_term'
            when lead_time between 31 and 90 then 'mid_term'
            else 'long_term'
        end as lead_time_segment,

        case
            when total_guests = 1 then 'solo'
            when total_guests = 2 then 'couple'
            when total_guests between 3 and 4 then 'small_group'
            else 'large_group'
        end as guest_segment,

        case
            when total_nights <= 2 then 'short_stay'
            when total_nights between 3 and 7 then 'medium_stay'
            else 'long_stay'
        end as stay_segment,

        case
            when total_of_special_requests = 0 then 'no_requests'
            when total_of_special_requests between 1 and 2 then 'few_requests'
            else 'many_requests'
        end as special_request_segment,

        -- flags de historial
        previous_cancellations > 0 as has_previous_cancellations_flag,
        previous_bookings_not_canceled > 0 as has_previous_successful_bookings_flag

    from bookings

)

select *
from enriched