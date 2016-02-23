````sql
select
  concat(last_name, ', ', first_name) as agent_name,
  count(l.id) as listing_count
from
  agents a
  join listings l on (a.id = l.sales_agent_id or a.id = l.listing_agent_id)
group by
  a.id
order by
  listing_count desc,
  agent_name;
````
