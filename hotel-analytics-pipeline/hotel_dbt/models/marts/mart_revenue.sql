{{ config(materialized='table') }}

with bookings as (

    select *
    from {{ ref('fct_bookings') }}

),

final as (

    select
        -- dimensiones temporales
        arrival_year,
        arrival_month_number,
        arrival_quarter,
        hotel,

        -- volumen
        count(*)                                                    as total_bookings,
        sum(case when is_canceled = 1 then 1 else 0 end)            as canceled_bookings,
        sum(case when is_canceled = 0 then 1 else 0 end)            as confirmed_bookings,

        -- tasa de cancelación
        round(
            safe_divide(
                sum(case when is_canceled = 1 then 1 else 0 end),
                count(*)
            ), 4
        )                                                           as cancellation_rate,

        -- revenue
        round(sum(gross_booking_amount), 2)                         as gross_revenue,
        round(sum(net_booking_amount), 2)                           as net_revenue,
        round(sum(canceled_booking_amount), 2)                      as lost_revenue,

        -- pricing
        round(avg(adr), 2)                                          as avg_adr,

        -- revpar ajustado por cancelaciones
        round(
            avg(adr) * (
                1 - safe_divide(
                    sum(case when is_canceled = 1 then 1 else 0 end),
                    count(*)
                )
            ), 2
        )                                                           as adjusted_revpar,

        -- estancia
        sum(confirmed_nights)                                       as confirmed_nights,
        round(avg(total_nights), 2)                                 as avg_stay_length,
        round(avg(total_guests), 2)                                 as avg_guests

    from bookings

    group by
        arrival_year,
        arrival_month_number,
        arrival_quarter,
        hotel

)

select *
from final