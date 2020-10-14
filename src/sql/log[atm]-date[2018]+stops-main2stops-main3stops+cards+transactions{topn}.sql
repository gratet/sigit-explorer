
-- Retrieve top-n stops per card
-- https://www.periscopedata.com/blog/selecting-only-one-row-per-group
-- https://stackoverflow.com/a/43444458

with card_stop_stats as (
  select card, stop_id, count(id) as stop_transactions
  from transactions_atm
  group by 1, 2
  order by stop_transactions DESC
), card_stops_ranking as (
  select distinct  card, group_concat(stop_id) as stop_id_array, group_concat(stop_transactions) as stop_transactions_array
  from card_stop_stats
  group by 1
), card_stops_podium as (
select *, 
  case when length(stop_transactions_array) - length(replace(stop_transactions_array, ',', '')) = 0 
         then stop_transactions_array
       when length(stop_transactions_array) - length(replace(stop_transactions_array, ',', '')) >= 1 
         then substr(stop_transactions_array, 0, instr(stop_transactions_array, ','))+
              substr(stop_transactions_array, instr(stop_transactions_array, ',')+1)
       else stop_transactions_array 
  end as main_two_stops,
  case when length(stop_transactions_array) - length(replace(stop_transactions_array, ',', '')) = 0 
         then stop_transactions_array
       when length(stop_transactions_array) - length(replace(stop_transactions_array, ',', '')) >= 1 
         then substr(stop_transactions_array, 0, instr(stop_transactions_array, ','))+
              substr(stop_transactions_array, instr(stop_transactions_array, ',')+1, instr(substr(stop_transactions_array, instr(stop_transactions_array, ',')+1), ',')-1) +
              substr(stop_transactions_array, instr(substr(stop_transactions_array, instr(stop_transactions_array, ',')+1), ',')+ instr(stop_transactions_array, ',')+1)
       else stop_transactions_array 
  end as main_three_stops
from card_stops_ranking
)
select * from card_stops_podium;


