{{ config(materialized='table') }}

with bookings as (

    select *
    from {{ ref('int_bookings_transformed') }}

),

final as (

    select
        -- identidade
        booking_sk,
        hotel,

        -- tempo
        arrival_date,
        arrival_year,
        arrival_month_number,
        arrival_quarter,
        arrival_weekday_name,

        -- segmentação de mercado
        market_segment,
        distribution_channel,
        country,
        customer_type,

        -- lead time
        lead_time,
        lead_time_segment,

        -- estancia
        total_nights,

        case
            when is_canceled = 0 then total_nights
            else 0
        end                                         as confirmed_nights,

        total_guests,
        guest_segment,
        stay_segment,
        special_request_segment,

        -- cancelación
        is_canceled,
        is_canceled_flag,

        -- revenue
        adr,
        gross_booking_amount,
        net_booking_amount,
        canceled_booking_amount,
        revenue_per_guest,

        -- historial del cliente
        is_repeated_guest,
        previous_cancellations,
        previous_bookings_not_canceled,
        total_previous_bookings,
        historical_cancellation_rate,
        has_previous_cancellations_flag,
        has_previous_successful_bookings_flag,

        -- habitación
        reserved_room_type,
        assigned_room_type,
        room_changed_flag,
        room_change_type,

        -- operacional
        booking_changes,
        deposit_type,
        agent_id,
        company_id,
        days_in_waiting_list,
        required_car_parking_spaces,
        total_of_special_requests,

        -- estado de reserva
        reservation_status,
        reservation_status_date,

        -- auditoría
        ingestion_ts

    from bookings

)

select *
from final