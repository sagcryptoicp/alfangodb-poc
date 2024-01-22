import Map              "mo:map/Map";
import Payload          "../alfangodb_backend/payload/table";
import Tables           "./tables";

shared ({ caller = initializer }) actor class DBMigrator() = this {
    stable let db = actor ("bkyz2-fmaaa-aaaaa-qaaaq-cai") : actor {
        createDatabase: shared (createDatabasePayload : Payload.CreateDatabasePayload) -> async ();
        createDatabaseTable: shared (createTablePayload: Payload.CreateTablePayload)-> async ();
    };
    
    public shared (msg) func createDatabase(
    createDatabasePayload: Payload.CreateDatabasePayload
    ) : async () {
    await db.createDatabase(createDatabasePayload);
    };

    public shared (msg) func createDatabaseTable(
        createTablePayload: Payload.CreateTablePayload
    ) : async () {
    await db.createDatabaseTable(Tables.tables);
    };
}