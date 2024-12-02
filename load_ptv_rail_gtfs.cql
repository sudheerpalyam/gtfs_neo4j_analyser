//LOAD CSV script for GFTS data

create constraint on (a:Agency) assert a.id is unique;
create constraint on (r:Route) assert r.id is unique;
create constraint on (t:Trip) assert t.id is unique;
create index on :Trip(service_id);
create index on :CalendarDate(service_id);
create index on :CalendarDate(date);
create constraint on (s:Stop) assert s.id is unique;
create index on :Stoptime(stop_sequence);
create index on :Stop(name);

MATCH (n)
DETACH DELETE n;

//schema await;

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/sudheerpalyam/gtfs_neo4j_analyser/main/data/gtfsdata/1/agency.txt' AS csv
CREATE (a:Agency {
  id: csv.agency_id,
  name: csv.agency_name,
  url: csv.agency_url,
  timezone: csv.agency_timezone,
  lang: csv.agency_lang,
  phone: csv.agency_phone,
  fare_url: csv.agency_fare_url
});

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/sudheerpalyam/gtfs_neo4j_analyser/main/data/gtfsdata/1/calendar.txt' AS csv
CREATE (c:Calendar {
  service_id: csv.service_id,
  monday: toBoolean(csv.monday),
  tuesday: toBoolean(csv.tuesday),
  wednesday: toBoolean(csv.wednesday),
  thursday: toBoolean(csv.thursday),
  friday: toBoolean(csv.friday),
  saturday: toBoolean(csv.saturday),
  sunday: toBoolean(csv.sunday),
  start_date: csv.start_date,
  end_date: csv.end_date
});

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/sudheerpalyam/gtfs_neo4j_analyser/main/data/gtfsdata/1/calendar_dates.txt' AS csv
MATCH (t:Trip {service_id: csv.service_id})
CREATE (t)-[:RUNS_DURING]->(cd:CalendarDate {
  service_id: csv.service_id,
  date: csv.date,
  exception_type: toInteger(csv.exception_type)
});

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/sudheerpalyam/gtfs_neo4j_analyser/main/data/gtfsdata/1/routes.txt' AS csv
MATCH (a:Agency {id: csv.agency_id})
CREATE (a)-[:OPERATES]->(r:Route {
  id: csv.route_id,
  short_name: csv.route_short_name,
  long_name: csv.route_long_name,
  type: toInteger(csv.route_type),
  color: csv.route_color,
  text_color: csv.route_text_color
});

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/sudheerpalyam/gtfs_neo4j_analyser/main/data/gtfsdata/1/trips.txt' AS csv
MATCH (r:Route {id: csv.route_id})
MERGE (r)<-[:USES]-(t:Trip {
  id: csv.trip_id,
  service_id: csv.service_id,
  shape_id: csv.shape_id,
  headsign: csv.trip_headsign,
  direction_id: toInteger(csv.direction_id),
  block_id: csv.block_id
});

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/sudheerpalyam/gtfs_neo4j_analyser/main/data/gtfsdata/1/stops.txt' AS csv
CREATE (s:Stop {
  id: csv.stop_id,
  name: csv.stop_name,
  lat: toFloat(csv.stop_lat),
  lon: toFloat(csv.stop_lon)
});


LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/sudheerpalyam/gtfs_neo4j_analyser/main/data/gtfsdata/1/stop_times.txt' AS csv
MATCH (t:Trip {id: csv.trip_id}), (s:Stop {id: csv.stop_id})
CREATE (t)<-[:PART_OF_TRIP]-(st:Stoptime {
  arrival_time: csv.arrival_time,
  departure_time: csv.departure_time,
  stop_sequence: toInteger(csv.stop_sequence),
  headsign: csv.stop_headsign,
  pickup_type: toInteger(csv.pickup_type),
  drop_off_type: toInteger(csv.drop_off_type),
  shape_dist_traveled: toFloat(csv.shape_dist_traveled)
 })-[:LOCATED_AT]->(s);

// Convert times for calculations/ordering
MATCH (s:Stoptime)
SET s.arrival_time_int = toInteger(replace(s.arrival_time, ":", "")) / 100,
    s.departure_time_int = toInteger(replace(s.departure_time, ":", "")) / 100;

// Connect stop time sequences
MATCH (s1:Stoptime)-[:PART_OF_TRIP]->(t), (s2:Stoptime)-[:PART_OF_TRIP]->(t)
WHERE s2.stop_sequence = s1.stop_sequence + 1
CREATE (s1)-[:PRECEDES]->(s2);



LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/sudheerpalyam/gtfs_neo4j_analyser/main/data/gtfsdata/1/shapes.txt' AS csv
CREATE (shp:Shape {
  id: csv.shape_id,
  pt_latitude : toFloat(csv.shape_pt_lat),
  pt_longitude : toFloat(csv.shape_pt_lon),
  pt_sequence : toInteger(csv.shape_pt_sequence),
  dist_traveled : toFloat(csv.shape_dist_traveled)
});
