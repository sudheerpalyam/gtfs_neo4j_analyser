// 1.	Find Melbourne Stations (e.g., Southern Cross)

MATCH (s:Stop)
WHERE upper(s.name) STARTS WITH "SOUTHERN CROSS"
RETURN s;

// 2.	Find Melbourne Stations (e.g., Flinders Street)
MATCH (s:Stop)
WHERE s.name STARTS WITH "Flinders"
RETURN s;

// 	3.	Find Melbourne Stations (e.g., Flinders Street) - Case Insensitive
MATCH (s:Stop)
WHERE upper(s.name) STARTS WITH "FLINDERS"
RETURN s;

// 4.	Find Southern Cross and Flinders Street Stations
MATCH (southern:Stop), (flinders:Stop)
WHERE southern.name STARTS WITH "Southern Cross"
  AND flinders.name STARTS WITH "Flinders"
RETURN DISTINCT southern, flinders;

// 	5.	Union of Southern Cross and Flinders Street Station Names
MATCH (southern:Stop)
WHERE southern.name STARTS WITH "Southern Cross"
RETURN southern.name AS name
UNION
MATCH (flinders:Stop)
WHERE flinders.name STARTS WITH "Flinders"
RETURN flinders.name AS name;


// 	6.	Find Links Between Top-Level Stops
MATCH
    (t:Stop)<-[:PART_OF_TRIP]-(:Stoptime),
    (a:Stop)<-[:PART_OF_TRIP]-(:Stoptime)
WHERE
    t.name STARTS WITH "Flinders"
  AND a.name = "Southern Cross"
WITH t, a
MATCH p = allshortestpaths((t)-[*]-(a))
RETURN p LIMIT 10;

MATCH
    (t:Stop), (a:Stop)
WHERE
    t.name STARTS WITH "Flinders"
  AND a.name = "Southern Cross"
WITH t, a
MATCH p = allshortestpaths((t)-[*]-(a))
RETURN p LIMIT 10;

// 7.	Range Queries with and without Indexes
MATCH (st:Stoptime)
WHERE st.departure_time < "07:45:00"
RETURN st.departure_time;

MATCH
  (orig:Stop {name: "Southern Cross"})--(orig_st:Stoptime)-[r1:PART_OF_TRIP]->(trp:Trip)
WHERE
  orig_st.departure_time > "07:00:00"
  AND orig_st.departure_time < "09:00:00"
  AND trp.service_id = "4"
RETURN orig, orig_st;

// 	8.	Find a Direct Route with Range Conditions
MATCH
  (orig:Stop {name: "Southern Cross"})--(orig_st:Stoptime)-[r1:PART_OF_TRIP]->(trp:Trip)
WHERE
  orig_st.departure_time > "06:30:00"
  AND orig_st.departure_time < "07:30:00"
  AND trp.service_id = "4"
WITH orig, orig_st
MATCH
    (dest:Stop {name:"Flinders"})--(dest_st:Stoptime)-[r2:PART_OF_TRIP]->(trp2:Trip)
WHERE
    dest_st.arrival_time < "09:00:00"
    AND dest_st.arrival_time > "07:00:00"
    AND dest_st.arrival_time > orig_st.departure_time
    AND trp2.service_id = "4"
WITH dest, dest_st, orig, orig_st, trp2
MATCH p = allshortestpaths((orig_st)-[*]->(dest_st))
RETURN p;
