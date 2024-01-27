import Metadata "../data/types/metadata";
import Database "../data/types/database";
import Map "mo:map/Map";

module {

    public type CreateDatabasePayload = {
        name: Text;
    };

    public type CreateTablePayload = {
        databaseName: Text;
        name: Text;
        attributes: [ Metadata.AttributeMetadata ];
        indexes: [ Metadata.TableIndexMetadata ];
    };

    public type CreateItemPayload = {
        databaseName: Text;
        tableName: Text;
        data: [ (Text, Database.DataTypeValue) ];
    };

    public type UpdateItemPayload = {
        databaseName: Text;
        tableName: Text;
        itemId: Text; // ID of the item you want to update
        data: [ (Text, Database.DataTypeValue) ]; // Updated data
    };

    public type GetItemPayload = {
        databaseName: Text;
        tableName: Text;
        itemId: Text;
    };

}