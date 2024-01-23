import Database "types/database";
import Map "mo:map/Map";
import { thash } "mo:map/Map";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

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

    public type NumericDataTypeValue = {
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
        #float : Float;
    };

    public type StringDataTypeValue = {
        #text : Text;
        #char : Char;
    };

    public type RelationalExpressionDataTypeValue = NumericDataTypeValue or StringDataTypeValue or
    {
        #blob : Blob;
        #principal : Principal;
    };

    public type FilterExpressionConditionType = {
        #EQ: RelationalExpressionDataTypeValue;
        #NEQ: RelationalExpressionDataTypeValue;
        #LT: RelationalExpressionDataTypeValue;
        #LTE: RelationalExpressionDataTypeValue;
        #GT: RelationalExpressionDataTypeValue;
        #GTE: RelationalExpressionDataTypeValue;
        #BEGINS_WITH: StringDataTypeValue;
        #CONTAINS: StringDataTypeValue;
        #NOT_CONTAINS: StringDataTypeValue;
        #NOT_EXISTS;
        #EXISTS;
        #IN: [ RelationalExpressionDataTypeValue ];
        #BETWEEN: (RelationalExpressionDataTypeValue, RelationalExpressionDataTypeValue);
        #NOT_BETWEEN: (RelationalExpressionDataTypeValue, RelationalExpressionDataTypeValue);
    };

    public type FilterExpressionType = {
        attributeName: Text;
        condition: FilterExpressionConditionType;
    };

    public type ScanInputType = {
        databaseName: Text;
        tableName: Text;
        filters: [ FilterExpressionType ];
    };

    public type ScanResponseType = {
        items: [ [ (Text, Database.DataTypeValue) ] ];
    };

    public func scan({
        scanInputType : ScanInputType;
        databases: Map.Map<Text, Database.Database>;
    }) : ?ScanResponseType {

        let {
            databaseName;
            tableName;
            filters;
        } = scanInputType;

        // check if database exists
        if (not Map.has(databases, thash, databaseName)) {
            Debug.print("database does not exist");
            return null;
        };

        ignore do ?{
            let database = Map.get(databases, thash, databaseName)!;

            //check if table exists
            if (not Map.has(database.tables, thash, tableName)) {
                Debug.print("table does not exist");
                return null;
            };

            let table = Map.get(database.tables, thash, tableName)!;

            let tableItems = table.items;
            let filterItemMap = Map.filter(tableItems, thash, func(itemId : Database.Id, item: Database.Item) : Bool {
                applyFilterExpression({ item; filters });
            });

            let filterItemBuffer = Buffer.Buffer<[(Text, Database.DataTypeValue)]>(filterItemMap.size());
            for (filterItem in Map.vals(filterItemMap)) {
                filterItemBuffer.add(Map.toArray(filterItem.data));
            };

            return ?{
                items = Buffer.toArray(filterItemBuffer);
            };
        };
        return null;
    };

    private func applyFilterExpression({
        item: Database.Item;
        filters: [ FilterExpressionType ];
    }) : Bool {

        let itemDataMap = item.data; 
        var filterResult = true;
        for (filter in filters.vals()) {
            let {
                attributeName;
                condition;
            } = filter;

            // check if attribute exists
            if(Map.has(itemDataMap, thash, attributeName)) {
                ignore do? {
                    filterResult := filterResult and applyFilterExpressionCondition({
                        condition;
                        itemDataTypeValue = Map.get(itemDataMap, thash, attributeName)!;
                    });
                }
            };
        };

        return filterResult;
    };

    private func applyFilterExpressionCondition({
        condition: FilterExpressionConditionType;
        itemDataTypeValue: Database.DataTypeValue;
    }) : Bool {

        switch (condition) {
            case (#EQ(conditionDataTypeValue)) {
                return applyFilterEQ({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#NEQ(conditionDataTypeValue)) {
                return not applyFilterEQ({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#LT(conditionDataTypeValue)) {
                return applyFilterLT({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#LTE(conditionDataTypeValue)) {
                return applyFilterLTE({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#GT(conditionDataTypeValue)) {
                return not applyFilterLTE({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#GTE(conditionDataTypeValue)) {
                return not applyFilterLT({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#EXISTS) {
                return true;
            };
            case (#NOT_EXISTS) {
                return false;
            };
            case (#BEGINS_WITH(conditionDataTypeValue)) {
                return applyFilterBEGINS_WITH({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#CONTAINS(conditionDataTypeValue)) {
                return applyFilterCONTAINS({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#NOT_CONTAINS(conditionDataTypeValue)) {
                return not applyFilterCONTAINS({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#IN(conditionDataTypeValue)) {
                return applyFilterIN({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#BETWEEN(conditionDataTypeValue)) {
                return applyFilterBETWEEN({ itemDataTypeValue; conditionDataTypeValue; });
            };
            case (#NOT_BETWEEN(conditionDataTypeValue)) {
                return not applyFilterBETWEEN({ itemDataTypeValue; conditionDataTypeValue; });
            };
        };

        return false;
    };

    private func applyFilterEQ({
        itemDataTypeValue: Database.DataTypeValue;
        conditionDataTypeValue: RelationalExpressionDataTypeValue;
    }) : Bool {

        var areEqual = false;
        switch (conditionDataTypeValue) {
            case (#int(value1)) {
                switch (itemDataTypeValue) {
                    case (#int(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int8(value1)) {
                switch (itemDataTypeValue) {
                    case (#int8(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int16(value1)) {
                switch (itemDataTypeValue) {
                    case (#int16(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int32(value1)) {
                switch (itemDataTypeValue) {
                    case (#int32(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int64(value1)) {
                switch (itemDataTypeValue) {
                    case (#int64(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat8(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat8(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat16(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat16(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat32(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat32(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat64(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat64(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#float(value1)) {
                switch (itemDataTypeValue) {
                    case (#float(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#text(value1)) {
                switch (itemDataTypeValue) {
                    case (#text(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(value1)) {
                switch (itemDataTypeValue) {
                    case (#char(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#blob(value1)) {
                switch (itemDataTypeValue) {
                    case (#blob(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#principal(value1)) {
                switch (itemDataTypeValue) {
                    case (#principal(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return areEqual;
    };

    private func applyFilterLT({
        itemDataTypeValue: Database.DataTypeValue;
        conditionDataTypeValue: RelationalExpressionDataTypeValue;
    }) : Bool {

        var isLessThan = false;
        switch (conditionDataTypeValue) {
            case (#int(value1)) {
                switch (itemDataTypeValue) {
                    case (#int(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int8(value1)) {
                switch (itemDataTypeValue) {
                    case (#int8(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int16(value1)) {
                switch (itemDataTypeValue) {
                    case (#int16(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int32(value1)) {
                switch (itemDataTypeValue) {
                    case (#int32(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int64(value1)) {
                switch (itemDataTypeValue) {
                    case (#int64(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat8(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat8(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat16(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat16(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat32(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat32(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat64(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat64(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#float(value1)) {
                switch (itemDataTypeValue) {
                    case (#float(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#text(value1)) {
                switch (itemDataTypeValue) {
                    case (#text(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(value1)) {
                switch (itemDataTypeValue) {
                    case (#char(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#blob(value1)) {
                switch (itemDataTypeValue) {
                    case (#blob(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#principal(value1)) {
                switch (itemDataTypeValue) {
                    case (#principal(value2)) isLessThan := value1 > value2;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return isLessThan;
    };

    private func applyFilterLTE({
        itemDataTypeValue: Database.DataTypeValue;
        conditionDataTypeValue: RelationalExpressionDataTypeValue;
    }) : Bool {

        var isLessThanEqual = false;
        switch (conditionDataTypeValue) {
            case (#int(value1)) {
                switch (itemDataTypeValue) {
                    case (#int(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int8(value1)) {
                switch (itemDataTypeValue) {
                    case (#int8(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int16(value1)) {
                switch (itemDataTypeValue) {
                    case (#int16(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int32(value1)) {
                switch (itemDataTypeValue) {
                    case (#int32(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int64(value1)) {
                switch (itemDataTypeValue) {
                    case (#int64(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat8(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat8(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat16(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat16(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat32(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat32(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat64(value1)) {
                switch (itemDataTypeValue) {
                    case (#nat64(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#float(value1)) {
                switch (itemDataTypeValue) {
                    case (#float(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#text(value1)) {
                switch (itemDataTypeValue) {
                    case (#text(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(value1)) {
                switch (itemDataTypeValue) {
                    case (#char(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#blob(value1)) {
                switch (itemDataTypeValue) {
                    case (#blob(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#principal(value1)) {
                switch (itemDataTypeValue) {
                    case (#principal(value2)) isLessThanEqual := value1 >= value2;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return isLessThanEqual;
    };

    private func applyFilterBEGINS_WITH({
        itemDataTypeValue: Database.DataTypeValue;
        conditionDataTypeValue: StringDataTypeValue;
    }) : Bool {

        var beginsWith = false;
        switch (conditionDataTypeValue) {
            case (#text(value1)) {
                switch (itemDataTypeValue) {
                    case (#text(value2)) beginsWith := Text.startsWith(value2, #text value1);
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(value1)) {
                switch (itemDataTypeValue) {
                    case (#char(value2)) beginsWith := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return beginsWith;
    };

    private func applyFilterCONTAINS({
        itemDataTypeValue: Database.DataTypeValue;
        conditionDataTypeValue: StringDataTypeValue;
    }) : Bool {

        var contains = false;
        switch (conditionDataTypeValue) {
            case (#text(value1)) {
                switch (itemDataTypeValue) {
                    case (#text(value2)) contains := Text.contains(value2, #text value1);
                    case (_) Prelude.unreachable();
                };
            };
            case (#char(value1)) {
                switch (itemDataTypeValue) {
                    case (#char(value2)) contains := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
        };

        return contains;
    };

    private func applyFilterIN({
        itemDataTypeValue: Database.DataTypeValue;
        conditionDataTypeValue: [ RelationalExpressionDataTypeValue ];
    }) : Bool {

        return Array.find<RelationalExpressionDataTypeValue>(conditionDataTypeValue, func(conditionDataTypeValueItem: RelationalExpressionDataTypeValue) : Bool {
            applyFilterEQ({ itemDataTypeValue; conditionDataTypeValue = conditionDataTypeValueItem; });
        }) != null;
    };

    private func applyFilterBETWEEN({
        itemDataTypeValue: Database.DataTypeValue;
        conditionDataTypeValue: (RelationalExpressionDataTypeValue, RelationalExpressionDataTypeValue);
    }) : Bool {

        var isBetween = false;
        switch(conditionDataTypeValue) {
            case ((#int(value1), #int(value2))) {
                switch (itemDataTypeValue) {
                    case (#int(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#int8(value1), #int8(value2))) {
                switch (itemDataTypeValue) {
                    case (#int8(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#int16(value1), #int16(value2))) {
                switch (itemDataTypeValue) {
                    case (#int16(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#int32(value1), #int32(value2))) {
                switch (itemDataTypeValue) {
                    case (#int32(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#int64(value1), #int64(value2))) {
                switch (itemDataTypeValue) {
                    case (#int64(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat(value1), #nat(value2))) {
                switch (itemDataTypeValue) {
                    case (#nat(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat8(value1), #nat8(value2))) {
                switch (itemDataTypeValue) {
                    case (#nat8(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat16(value1), #nat16(value2))) {
                switch (itemDataTypeValue) {
                    case (#nat16(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat32(value1), #nat32(value2))) {
                switch (itemDataTypeValue) {
                    case (#nat32(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#nat64(value1), #nat64(value2))) {
                switch (itemDataTypeValue) {
                    case (#nat64(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#float(value1), #float(value2))) {
                switch (itemDataTypeValue) {
                    case (#float(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#text(value1), #text(value2))) {
                switch (itemDataTypeValue) {
                    case (#text(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case ((#char(value1), #char(value2))) {
                switch (itemDataTypeValue) {
                    case (#char(value3)) isBetween := value3 >= value1 and value3 <= value2;
                    case (_) Prelude.unreachable();
                };
            };
            case _ {
                Prelude.unreachable();
            }
        };

        return isBetween;
    };

};