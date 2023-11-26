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

    public type GetItemPayload = {
        databaseName: Text;
        tableName: Text;
        itemId: Text;
    };

}