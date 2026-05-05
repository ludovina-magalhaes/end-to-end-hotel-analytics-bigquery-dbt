{{ config(materialized='table') }}

with bookings as (

    select *
    from {{ ref('fct_bookings') }}

),

final as (

    select
        -- dimensiones de segmentación
        distribution_channel,
        market_segment,
        lead_time_segment,

        -- volumen
        count(*)                                                as total_bookings,
        sum(case when is_canceled = 1 then 1 else 0 end)       as canceled_bookings,
        sum(case when is_canceled = 0 then 1 else 0 end)       as confirmed_bookings,

        -- tasa de cancelación
        round(
            safe_divide(
                sum(case when is_canceled = 1 then 1 else 0 end),
                count(*)
            ), 4
        )                                                       as cancellation_rate,

        -- impacto financiero
        round(sum(canceled_booking_amount), 2)                  as revenue_lost,
        round(sum(net_booking_amount), 2)                       as total_net_revenue,

        -- comportamiento
        round(avg(lead_time), 2)                                as avg_lead_time,
        round(avg(adr), 2)                                      as avg_adr,
        round(avg(total_nights), 2)                             as avg_nights

    from bookings

    group by
        distribution_channel,
        market_segment,
        lead_time_segment

)

select *
from final