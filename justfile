# Default recipe to run when just is called without arguments
default:
    @just --list

# Create docker network if it doesn't exist
create-network:
    #!/usr/bin/env sh
    if ! docker network inspect ferretdb-net >/dev/null 2>&1; then
        docker network create ferretdb-net
    fi

# Remove docker network if it exists
remove-network:
    #!/usr/bin/env sh
    if docker network inspect ferretdb-net >/dev/null 2>&1; then
        docker network rm ferretdb-net
    fi

# Setup FerretDB evaluation environment
setup: create-network
    docker run -d --rm \
        --name ferretdb \
        --network ferretdb-net \
        -p 27017:27017 \
        --platform linux/amd64 \
        ghcr.io/ferretdb/ferretdb-eval:2

# Check if FerretDB container is running
is-running:
    #!/usr/bin/env sh
    if ! docker ps --filter name=ferretdb --quiet | grep -q .; then
        echo "FerretDB container not running. Running setup..."
        just setup
    fi

# Private recipe to wait for FerretDB to be ready
wait-for-ferretdb:
    #!/usr/bin/env sh
    for i in $(seq 1 30); do
        if docker exec ferretdb mongosh --eval 'db.version()' --quiet >/dev/null 2>&1; then
            exit 0
        fi
        echo "Waiting for FerretDB to be ready... (${i}/30)"
        sleep 1
    done
    echo "FerretDB failed to become ready"
    exit 1

# Test connectivity
test-connect: is-running wait-for-ferretdb
    #!/usr/bin/env sh
    echo "Running FerretDB connectivity tests..."
    docker exec ferretdb mongosh \
        mongodb://username:password@localhost:27017/admin \
        --eval 'db.version(); print("Server version OK");'
    docker exec ferretdb mongosh \
        mongodb://username:password@localhost:27017/admin \
        --eval 'db.runCommand({ping: 1}); print("Server ping OK");'

# Insert a test document
test-insert: is-running wait-for-ferretdb
    #!/usr/bin/env sh
    echo "Inserting test document..."
    docker exec ferretdb mongosh \
        mongodb://username:password@localhost:27017/testdb \
        --eval 'db.mycollection.insertOne({
            name: "John Doe",
            age: 30,
            email: "john@example.com"
        }); print("Document inserted successfully");'

# Query the test document
test-query: is-running wait-for-ferretdb
    #!/usr/bin/env sh
    echo "Querying test document..."
    docker exec ferretdb mongosh \
        mongodb://username:password@localhost:27017/testdb \
        --eval 'const result = db.mycollection.find().toArray();
        print(JSON.stringify(result, null, 2));'

# Comprehensive CRUD operation test
test-crud: is-running wait-for-ferretdb
    #!/usr/bin/env sh
    echo "Running FerretDB CRUD tests..."
    docker exec ferretdb mongosh \
        mongodb://username:password@localhost:27017/testdb \
        --eval '
        // Clear test collection
        db.test.drop();
        // Insert a test document
        const testDoc = {
            name: "test_item",
            value: 42,
            tags: ["test", "ferret"],
            timestamp: new Date()
        };
        db.test.insertOne(testDoc);
        print("Document inserted");
        // Query and verify
        const result = db.test.findOne({name: "test_item"});
        // Assertions
        function assert(condition, message) {
            if (!condition) {
                throw new Error(`Assertion failed: ${message}`);
            }
        }
        assert(result !== null, "Document should be found");
        assert(result.name === "test_item", "Name should match");
        assert(result.value === 42, "Value should match");
        assert(Array.isArray(result.tags), "Tags should be an array");
        assert(result.tags.length === 2, "Tags should have 2 items");
        assert(result.timestamp instanceof Date, "Timestamp should be a Date");
        print("All assertions passed - document verified");
        // Cleanup
        db.test.drop();
        print("Test collection cleaned up");
    '

# Run comprehensive tests (connectivity, insert, query, crud)
test: test-connect test-insert test-query test-crud

# Run interactive mongosh shell
shell: is-running wait-for-ferretdb
    docker exec -it ferretdb mongosh mongodb://username:password@localhost:27017/testdb

# Run interactive PostgreSQL shell
psql: is-running wait-for-ferretdb
    docker exec -it ferretdb psql -U username postgres

# Teardown FerretDB evaluation environment
teardown:
    docker stop ferretdb || true
    just remove-network
