{{ config(materialized='table') }}

with bookings as (

    select *
    from {{ ref('fct_bookings') }}

),

final as (

    select
        -- dimensiones de segmentación
        market_segment,
        distribution_channel,
        customer_type,

        -- volumen
        count(*)                                        as total_bookings,
        sum(case when is_canceled = 0 then 1 else 0 end) as confirmed_bookings,
        sum(case when is_canceled = 1 then 1 else 0 end) as canceled_bookings,

        -- lead time
        round(avg(lead_time), 2)                        as avg_lead_time,

        -- revenue
        round(avg(adr), 2)                              as avg_adr,
        round(sum(net_booking_amount), 2)               as total_net_revenue,
        round(sum(gross_booking_amount), 2)             as total_gross_revenue,
        round(avg(revenue_per_guest), 2)                as avg_revenue_per_guest,

        -- estancia
        round(avg(total_nights), 2)                     as avg_nights,
        round(sum(confirmed_nights), 0)                 as total_confirmed_nights,

        -- comportamiento
        round(avg(is_repeated_guest), 4)                as repeated_guest_rate,
        round(avg(is_canceled), 4)                      as cancellation_rate,
        round(avg(total_of_special_requests), 2)        as avg_special_requests

    from bookings

    group by
        market_segment,
        distribution_channel,
        customer_type

)

select *
from final