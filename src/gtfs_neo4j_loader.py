from neo4j import GraphDatabase

# URI examples: "neo4j://localhost", "neo4j+s://xxx.databases.neo4j.io"
AURA_USERNAME = "neo4j"
AURA_PASSWORD = ""

AURA_CONNECTION_URI = "neo4j+s://4aceb45e.databases.neo4j.io"
AUTH = (AURA_USERNAME, AURA_PASSWORD)

# Initialize the driver
driver = GraphDatabase.driver(
    AURA_CONNECTION_URI,
    auth=(AURA_USERNAME, AURA_PASSWORD)
)

def load_gtfs_data():
    with driver.session() as session:
        # Load agencies
        session.run("""LOAD CSV WITH HEADERS FROM 'file:///Users/sudheerpalyamdefence/workspace/neo4j/gtfs_neo4j_analyser/data/gtfs/1/google_transit/agency.csv' AS row
        MERGE (a:Agency {agency_id: row.agency_id})
        SET a.agency_name = row.agency_name,
            a.agency_url = row.agency_url,
            a.agency_timezone = row.agency_timezone,
            a.agency_lang = row.agency_lang,
            a.agency_phone = row.agency_phone,
            a.agency_fare_url = row.agency_fare_url
        """)

if __name__ == "__main__":
    load_gtfs_data()

