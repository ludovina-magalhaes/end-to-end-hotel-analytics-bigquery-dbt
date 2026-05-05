{{ config(
    materialized='view'
) }}

with source as (

    select *
    from {{ source('raw', 'hotel_bookings') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key([
            'hotel',
            'arrival_date_year',
            'arrival_date_month',
            'arrival_date_day_of_month',
            'lead_time',
            'adr',
            'reservation_status_date'
        ]) }} as booking_sk,

        -- hotel
        cast(hotel as string) as hotel,

        -- cancelación
        cast(is_canceled as int64) as is_canceled,

        -- lead time
        cast(lead_time as int64) as lead_time,

        -- fecha de llegada
        cast(arrival_date_year as int64) as arrival_date_year,
        trim(cast(arrival_date_month as string)) as arrival_date_month,
        cast(arrival_date_week_number as int64) as arrival_date_week_number,
        cast(arrival_date_day_of_month as int64) as arrival_date_day_of_month,

        parse_date(
            '%Y-%B-%d',
            concat(
                cast(arrival_date_year as string),
                '-',
                trim(cast(arrival_date_month as string)),
                '-',
                lpad(cast(arrival_date_day_of_month as string), 2, '0')
            )
        ) as arrival_date,

        -- estancia
        cast(stays_in_weekend_nights as int64) as stays_in_weekend_nights,
        cast(stays_in_week_nights as int64) as stays_in_week_nights,

        -- huéspedes
        cast(adults as int64) as adults,
        cast(coalesce(children, 0) as int64) as children,
        cast(babies as int64) as babies,

        -- atributos de reserva
        cast(meal as string) as meal,
        cast(country as string) as country,
        cast(market_segment as string) as market_segment,
        cast(distribution_channel as string) as distribution_channel,

        -- historial del cliente
        cast(is_repeated_guest as int64) as is_repeated_guest,
        cast(previous_cancellations as int64) as previous_cancellations,
        cast(previous_bookings_not_canceled as int64) as previous_bookings_not_canceled,

        -- habitación
        cast(reserved_room_type as string) as reserved_room_type,
        cast(assigned_room_type as string) as assigned_room_type,

        -- operacional
        cast(booking_changes as int64) as booking_changes,
        cast(deposit_type as string) as deposit_type,
        cast(agent as int64) as agent_id,
        cast(company as int64) as company_id,
        cast(days_in_waiting_list as int64) as days_in_waiting_list,
        cast(customer_type as string) as customer_type,

        -- revenue
        cast(adr as numeric) as adr,

        -- servicios
        cast(required_car_parking_spaces as int64) as required_car_parking_spaces,
        cast(total_of_special_requests as int64) as total_of_special_requests,

        -- estado de reserva
        cast(reservation_status as string) as reservation_status,
        parse_date('%Y-%m-%d', cast(reservation_status_date as string)) as reservation_status_date,

        -- auditoría
        cast(ingestion_ts as timestamp) as ingestion_ts,

        -- campos derivados simples
        cast(stays_in_weekend_nights as int64)
            + cast(stays_in_week_nights as int64) as total_nights,

        cast(adults as int64)
            + cast(coalesce(children, 0) as int64)
            + cast(babies as int64) as total_guests,

        cast(is_canceled as int64) = 1 as is_canceled_flag,

        cast(assigned_room_type as string)
            != cast(reserved_room_type as string) as room_changed_flag

    from source

)

select *
from renamed