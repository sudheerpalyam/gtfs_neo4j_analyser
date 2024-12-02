from neo4j import GraphDatabase

# Replace with your actual Neo4j Aura connection details
AURA_CONNECTION_URI = "neo4j+ssc://53b68c2948ebf245f8a2cbaa4548b123.bolt.neo4jsandbox.com:443"
AURA_USERNAME = ""
AURA_PASSWORD = ""

# Initialize the driver
driver = GraphDatabase.driver(
    AURA_CONNECTION_URI,
    auth=(AURA_USERNAME, AURA_PASSWORD)
)


def fetch_persons(tx):
    # Cypher query to match persons in the database
    query = "MATCH (p:Person) RETURN p.name AS name"
    result = tx.run(query)
    return [record["name"] for record in result]

# Use the driver to create a session and execute the query
with driver.session() as session:
    persons = session.read_transaction(fetch_persons)
    print("Persons in the database:", persons)

# Close the driver when done
driver.close()

