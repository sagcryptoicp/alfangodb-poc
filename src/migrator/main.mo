import Map              "mo:map/Map";
import Payload          "../alfangodb_backend/payload/table";

shared ({ caller = initializer }) actor class DBMigrator() = this {
    stable let db = actor ("bkyz2-fmaaa-aaaaa-qaaaq-cai") : actor {
        createDatabase: shared (createDatabasePayload : Payload.CreateDatabasePayload) -> async ();
    };
    public shared (msg) func createDatabase(
        createDatabasePayload: Payload.CreateDatabasePayload
        ) : async () {
        await db.createDatabase(createDatabasePayload);
        };
}