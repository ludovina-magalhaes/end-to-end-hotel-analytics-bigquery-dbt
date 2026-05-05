{{ config(materialized='table') }}

with bookings as (

    select *
    from {{ ref('fct_bookings') }}

),

final as (

    select
        -- dimensiones de habitación
        reserved_room_type,
        assigned_room_type,
        room_change_type,

        -- volumen
        count(*)                                                as total_bookings,
        sum(case when room_changed_flag then 1 else 0 end)      as room_changed_bookings,
        sum(case when is_canceled = 1 then 1 else 0 end)        as canceled_bookings,
        sum(case when is_canceled = 0 then 1 else 0 end)        as confirmed_bookings,

        -- tasas
        round(
            safe_divide(
                sum(case when room_changed_flag then 1 else 0 end),
                count(*)
            ), 4
        )                                                       as room_change_rate,

        round(
            safe_divide(
                sum(case when is_canceled = 1 then 1 else 0 end),
                count(*)
            ), 4
        )                                                       as cancellation_rate,

        -- revenue
        round(avg(adr), 2)                                      as avg_adr,
        round(avg(net_booking_amount), 2)                       as avg_net_revenue,
        round(sum(net_booking_amount), 2)                       as total_net_revenue,
        round(sum(canceled_booking_amount), 2)                  as revenue_lost,

        -- estancia
        round(avg(total_nights), 2)                             as avg_nights,
        round(avg(total_guests), 2)                             as avg_guests

    from bookings

    group by
        reserved_room_type,
        assigned_room_type,
        room_change_type

)

select *
from final