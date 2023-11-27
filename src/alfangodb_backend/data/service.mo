import Metadata "types/metadata";
import Database "types/database";
import Prelude "mo:base/Prelude";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
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
    }) : async Result.Result<Text, [ Text ]> {

        // check if database exists
        if (not Map.has(databases, thash, createItemPayload.databaseName)) {
            Debug.print("database does not exist");
            return #err([ "database does not exist" ]);
        };

        let errorBuffer = Buffer.Buffer<Text>(0);
        ignore do ?{
            let database = Map.get(databases, thash, createItemPayload.databaseName)!;

            //check if table exists
            if (not Map.has(database.tables, thash, createItemPayload.tableName)) {
                errorBuffer.add("table "# debug_show(createItemPayload.tableName) # " does not exist");
                Debug.print("error(s) creating item: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            let table = Map.get(database.tables, thash, createItemPayload.tableName)!;

            // validate item data-type
            let {
                invalidDataTypeAttributeNameToExpectedDataType;
                isValidItemDataType;
            } = validateItemDataType({
                data = createItemPayload.data;
                tableMetadata = table.metadata;
            });
            if (not isValidItemDataType) {
                errorBuffer.add("At least one attribute has wrong data-type");
            };

            // validate required attributes
            let {
                requiredAttributesPresent;
                areRequiredAttributesPresent;
            } = validateRequiredAttributes({
                data = createItemPayload.data;
                tableMetadata = table.metadata;
            });
            if (not areRequiredAttributesPresent) {
                errorBuffer.add("At least one required attribute is missing");
            };

            if (errorBuffer.size() > 0) {
                Debug.print("error(s) creating item: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
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
            Map.set(table.items, thash, item.id, item);
            Debug.print("item created with id: " # debug_show(item.id));
            return #ok(item.id);
        };

        Prelude.unreachable();
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

    private func validateItemDataType({
        data : [ (Text, Database.DataTypeValue) ];
        tableMetadata: Metadata.TableMetadata;
    }) : {
        invalidDataTypeAttributeNameToExpectedDataType : HashMap.HashMap<Text, Metadata.DataTypeAttribute>;
        isValidItemDataType : Bool;
    } {

        let invalidDataTypeAttributeNameToExpectedDataType = HashMap.HashMap<Text, Metadata.DataTypeAttribute>(0, Text.equal, Text.hash);
        let missingRequiredAttributes = Buffer.Buffer<Text>(0);

        let attributeNameToMetadataMap = HashMap.fromIter<Text, Metadata.AttributeMetadata>(
            Array.map<Metadata.AttributeMetadata, (Text, Metadata.AttributeMetadata)>(tableMetadata.attributes, func attributeMetadata = (attributeMetadata.name, attributeMetadata)).vals(),
            tableMetadata.attributes.size(), Text.equal, Text.hash
        );
        for ((attributeName, attributeValue) in data.vals()) {
            var actualDataType : Metadata.DataTypeAttribute = #default;
            switch (attributeValue) {
                case (#text(textValue)) {
                    actualDataType := #text;
                };
                case (#int(intValue)) {
                    actualDataType := #int;
                };
                case (#int8(int8Value)) {
                    actualDataType := #int8;
                };
                case (#int16(int16Value)) {
                    actualDataType := #int16;
                };
                case (#int32(int32Value)) {
                    actualDataType := #int32;
                };
                case (#int64(int64Value)) {
                    actualDataType := #int64;
                };
                case (#nat(natValue)) {
                    actualDataType := #nat;
                };
                case (#nat8(nat8Value)) {
                    actualDataType := #nat8;
                };
                case (#nat16(nat16Value)) {
                    actualDataType := #nat16;
                };
                case (#nat32(nat32Value)) {
                    actualDataType := #nat32;
                };
                case (#nat64(nat64Value)) {
                    actualDataType := #nat64;
                };
                case (#blob(blobValue)) {
                    actualDataType := #blob;
                };
                case (#float(floatValue)) {
                    actualDataType := #float;
                };
                case (#char(charValue)) {
                    actualDataType := #char;
                };
                case (#textarray(textarrayValue)) {
                    actualDataType := #textarray;
                };
                case (#nat8array(nat8arrayValue)) {
                    actualDataType := #nat8array;
                };
                case (#principal(principalValue)) {
                    actualDataType := #principal;
                };
                case (#bool(boolValue)) {
                    actualDataType := #bool;
                };
                case (#tuple(tupleValue)) {
                    actualDataType := #tuple;
                };
            };

            let isValidDataType = validateDataType({
                attributeName;
                actualDataType;
                attributeNameToMetadataMap;
            });
            if (not isValidDataType) {
                invalidDataTypeAttributeNameToExpectedDataType.put(attributeName, actualDataType);
            }
        };

        return {
            invalidDataTypeAttributeNameToExpectedDataType;
            isValidItemDataType = invalidDataTypeAttributeNameToExpectedDataType.size() == 0;
        };
    };

    private func validateRequiredAttributes({
        data : [ (Text, Database.DataTypeValue) ];
        tableMetadata: Metadata.TableMetadata;
    }) : {
        requiredAttributesPresent : [ Text ];
        areRequiredAttributesPresent : Bool;
    } {
        let requiredAttributes = Array.filter<Metadata.AttributeMetadata>(tableMetadata.attributes, func attributeMetadata = attributeMetadata.required);
        let requiredAttributesPresent = Buffer.Buffer<Text>(0);

        for ((attributeName, _) in data.vals()) {
            if (Option.isSome(Array.find<Metadata.AttributeMetadata>(requiredAttributes, func attributeMetadata = attributeMetadata.name == attributeName))) {
                requiredAttributesPresent.add(attributeName);
            };
        };

        return {
            requiredAttributesPresent = Buffer.toArray(requiredAttributesPresent);
            areRequiredAttributesPresent = requiredAttributesPresent.size() == requiredAttributes.size();
        };
    };

    private func validateDataType({
        attributeName: Text;
        actualDataType: Metadata.DataTypeAttribute;
        attributeNameToMetadataMap: HashMap.HashMap<Text, Metadata.AttributeMetadata>;
    }) : Bool {

        var expectedDataType : Metadata.DataTypeAttribute = #default;
        ignore do ?{ expectedDataType := attributeNameToMetadataMap.get(attributeName)!.dataType };

        if (expectedDataType != actualDataType) {
            Debug.print("expected data type: " # debug_show(expectedDataType) # " does not match actual data type: " # debug_show(actualDataType));
        };

        return expectedDataType == #default or expectedDataType == actualDataType;
    };

};