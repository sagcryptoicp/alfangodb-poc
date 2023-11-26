import Metadata "types/metadata";
import Database "types/database";
import Prelude "mo:base/Prelude";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Payload "../payload/table";
import Map "mo:map/Map";
import { thash } "mo:map/Map";
import ULID "../utility/ulid";

module {

    public func createDatabase({
        createDatabasePayload: Payload.CreateDatabasePayload;
        databases: Map.Map<Text, Database.Database>;
    }) {

        // check if database exists
        if (Map.has(databases, thash, createDatabasePayload.name)) {
            Debug.print("database already exists");
            return;
        };

        // create database
        let database : Database.Database = {
            name = createDatabasePayload.name;
            tables = Map.new<Text, Database.Table>();
        };

        // add database to databases
        Map.set(databases, thash, database.name, database);
    };

    public func createDatabaseTable({
        createTablePayload: Payload.CreateTablePayload;
        databases: Map.Map<Text, Database.Database>;
    }) {

        // check if database exists
        if (not Map.has(databases, thash, createTablePayload.databaseName)) {
            Debug.print("database does not exist");
            return;
        };
 
        ignore do ?{
            let database = Map.get(databases, thash, createTablePayload.databaseName)!;

            // check if table exists
            if (Map.has(database.tables, thash, createTablePayload.name)) {
                Debug.print("table already exists");
                return;
            };

            // create table
            let table : Database.Table = {
                name = createTablePayload.name;
                metadata = {
                    attributes = createTablePayload.attributes;
                    indexes = createTablePayload.indexes;
                };
                items = Map.new<Text, Database.Item>();
            };

            // add table to database
            Map.set(database.tables, thash, table.name, table);
        };
    };

    public func createTableItem({
        createItemPayload: Payload.CreateItemPayload;
        databases: Map.Map<Text, Database.Database>;
    }) : async ?Text {

        // check if database exists
        if (not Map.has(databases, thash, createItemPayload.databaseName)) {
            Debug.print("database does not exist");
            return null;
        };

        do ?{
            let database = Map.get(databases, thash, createItemPayload.databaseName)!;

            //check if table exists
            if (not Map.has(database.tables, thash, createItemPayload.tableName)) {
                Debug.print("table does not exist");
                return null;
            };

            // create item
            let item : Database.Item = {
                id = await ULID.generateULIDAsync();
                data = Map.fromIter<Text, Database.DataTypeValue>(Iter.fromArray(createItemPayload.data), thash);
                previousData = Map.new<Text, Database.DataTypeValue>();
                createdAt = Time.now();
                var updatedAt = Time.now();
            };

            // add item to table
            let table = Map.get(database.tables, thash, createItemPayload.tableName)!;
            Map.set(table.items, thash, item.id, item);
            return ?item.id;
        };

    };

    public func getTableItem({
        getItemPayload: Payload.GetItemPayload;
        databases: Map.Map<Text, Database.Database>;
    }) : ?[ (Text, Database.DataTypeValue) ] {

        // check if database exists
        if (not Map.has(databases, thash, getItemPayload.databaseName)) {
            Debug.print("database does not exist");
            return null;
        };

        do ?{
            let database = Map.get(databases, thash, getItemPayload.databaseName)!;

            //check if table exists
            if (not Map.has(database.tables, thash, getItemPayload.tableName)) {
                Debug.print("table does not exist");
                return null;
            };

            let table = Map.get(database.tables, thash, getItemPayload.tableName)!;
            // check if item exists
            if (not Map.has(table.items, thash, getItemPayload.itemId)) {
                Debug.print("item does not exist");
                return null;
            };

            // get item
            let item = Map.get(table.items, thash, getItemPayload.itemId)!;
            return ?Map.toArray(item.data);
        };

    };
};