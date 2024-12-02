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

def get_schemas(tx):
    # Cypher query to return all available schemas
    query = "call db.schema.visualization"
    result = tx.run(query)
    return [record for record in result]

def fetch_persons(tx):
    # Cypher query to match persons in the database
    query = "call db.schema.visualization"

    # query = "MATCH (p:Person) RETURN p.name AS name"
    result = tx.run(query)
    return [record for record in result]

    # return [record["name"] for record in result]

# Use the driver to create a session and execute the query
with driver.session() as session:
    persons = session.read_transaction(fetch_persons)
    print("Persons in the database:", persons)

# Close the driver when done
driver.close()

