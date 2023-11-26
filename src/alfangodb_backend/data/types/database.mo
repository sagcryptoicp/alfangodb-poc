import Map "mo:map/Map";
import Time "mo:base/Time";
import Metadata "metadata";

module {

    public type DataTypeValue = {
        #text : Text;
        #int : Int;
        #int8 : Int8;
        #int16 : Int16;
        #int32 : Int32;
        #int64 : Int64;
        #nat : Nat;
        #nat8 : Nat8;
        #nat16 : Nat16;
        #nat32 : Nat32;
        #nat64 : Nat64;
        #blob : Blob;
        #float : Float;
        #bool : Bool;
        #char : Char;
        #textarray : [ Text ];
        #nat8array : [ Nat8 ];
        #principal : Principal;
        #tuple : [(Text, Text)];
    };

    public type Item = {
        id: Text;
        data: Map.Map<Text, DataTypeValue>;
        previousData: Map.Map<Text, DataTypeValue>;
        createdAt : Time.Time;
        var updatedAt : Time.Time;
    };

    public type Table = {
        name : Text;
        metadata: Metadata.TableMetadata;
        items : Map.Map<Text, Item>;
    };

    public type Database = {
        name : Text;
        tables: Map.Map<Text, Table>;
    }; 
};