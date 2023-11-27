import Map              "mo:map/Map";
import Prelude          "mo:base/Prelude";
import Result "mo:base/Result";
import Metadata         "data/types/metadata";
import Payload          "payload/table";
import Ulid             "utility/ulid";
import Database         "data/types/database";
import DataService      "data/service";
import { thash }        "mo:map/Map";

shared ({ caller = initializer }) actor class AlfangoDb() = this {

    stable let databases = Map.new<Text, Database.Database>();

    public shared (msg) func createDatabase(
        createDatabasePayload: Payload.CreateDatabasePayload
    ) : async () {
        DataService.createDatabase({
            createDatabasePayload;
            databases;
        });
    };

    public shared (msg) func createDatabaseTable(
        createTablePayload: Payload.CreateTablePayload
    ) : async () {
        DataService.createDatabaseTable({
            createTablePayload;
            databases;
        });
    };

    public shared (msg) func createTableItem(
        createItemPayload: Payload.CreateItemPayload
    ) : async Result.Result<Text, [ Text ]> {
        await DataService.createTableItem({
            createItemPayload;
            databases;
        });
    };

    public query (msg) func getTableItem({
        getItemPayload: Payload.GetItemPayload;
    }) : async ?[ (Text, Database.DataTypeValue) ] {
        DataService.getTableItem({
            getItemPayload;
            databases;
        });
    };

};
