import Map              "mo:map/Map";
import Debug "mo:base/Debug";
import Payload          "../alfangodb_backend/payload/table";
import Tables           "./tables";

shared ({ caller = initializer }) actor class DBMigrator() = this {
    stable let db = actor ("bkyz2-fmaaa-aaaaa-qaaaq-cai") : actor {
        createDatabase: shared (createDatabasePayload : Payload.CreateDatabasePayload) -> async ();
        createDatabaseTable: shared (createTablePayload: Payload.CreateTablePayload)-> async ();
        createTableItem: shared (createItemPayload: Payload.CreateItemPayload)-> async ();
        
    };
    
    public shared (msg) func createDatabase(
    createDatabasePayload: Payload.CreateDatabasePayload
    ) : async () {
        for(item in Tables.databases.vals()) {
            Debug.print(debug_show(item));
            await db.createDatabase(item);
        };
    };

    public shared (msg) func createDatabaseTable(
        createTablePayload: Payload.CreateTablePayload
    ) : async () {
        for(item in Tables.tables.vals()) {
            await db.createDatabaseTable(item); 
        };
    };

    public shared (msg) func createTableItem(
        createItemPayload: Payload.CreateItemPayload
    ) : async () {
        for(item in Tables.tableitems.vals()) {
            await db.createTableItem(item);
        };
    };
}