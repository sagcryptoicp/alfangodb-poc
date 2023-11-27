import Time "mo:base/Time";

module {

    public type DataTypeAttribute = {
        #text;
        #int;
        #int8;
        #int16;
        #int32;
        #int64;
        #nat;
        #nat8;
        #nat16;
        #nat32;
        #nat64;
        #blob;
        #float;
        #bool;
        #char;
        #textarray;
        #nat8array;
        #principal;
        #tuple;
        #default;
    };

    public type AttributeMetadata = {
        name:  Text;
        dataType: DataTypeAttribute;
        unique: Bool;
        required: Bool;
        defaultValue: Text;
    };

    public type TableIndexMetadata = {
        name: Text;
        nonUnique: Bool;
        atttributeName: Text;
    };

    public type TableMetadata = {
        attributes: [ AttributeMetadata ];
        indexes: [ TableIndexMetadata ];
    };

};