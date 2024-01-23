import Database "database";
import {
    thash;
    ihash;
    i8hash;
    i16hash;
    i32hash;
    i64hash;
    nhash;
    n8hash;
    n16hash;
    n32hash;
    n64hash;
    bhash;
    lhash;
    phash;
} "mo:map/Map";
import Map "mo:map/Map";
import Prelude "mo:base/Prelude";

module {

    private func getHash(dataTypeValue: Database.DataTypeValue) : Nat32 {

        var hash : Nat32 = 0;

        switch (dataTypeValue) {
            case (#text(value)) hash := thash.0(value);
            case (#int(value)) hash := ihash.0(value);
            case (#int8(value)) hash := i8hash.0(value);
            case (#int16(value)) hash := i16hash.0(value);
            case (#int32(value)) hash := i32hash.0(value);
            case (#int64(value)) hash := i64hash.0(value);
            case (#nat(value)) hash := nhash.0(value);
            case (#nat8(value)) hash := n8hash.0(value);
            case (#nat16(value)) hash := n16hash.0(value);
            case (#nat32(value)) hash := n32hash.0(value);
            case (#nat64(value)) hash := n64hash.0(value);
            case (#blob(value)) hash := bhash.0(value);
            case (#bool(value)) hash := lhash.0(value);
            case (#principal(value)) hash := phash.0(value);
            case (_) Prelude.nyi();
        };

        return hash;
    };

    private func areEqual(
        dataTypeValue1: Database.DataTypeValue,
        dataTypeValue2: Database.DataTypeValue
    ) : Bool {

        var areEqual : Bool = false;

        switch (dataTypeValue1) {
            case (#text(value1)) {
                switch (dataTypeValue2) {
                    case (#text(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int(value1)) {
                switch (dataTypeValue2) {
                    case (#int(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int8(value1)) {
                switch (dataTypeValue2) {
                    case (#int8(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int16(value1)) {
                switch (dataTypeValue2) {
                    case (#int16(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int32(value1)) {
                switch (dataTypeValue2) {
                    case (#int32(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int64(value1)) {
                switch (dataTypeValue2) {
                    case (#int64(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat(value1)) {
                switch (dataTypeValue2) {
                    case (#nat(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat8(value1)) {
                switch (dataTypeValue2) {
                    case (#nat8(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat16(value1)) {
                switch (dataTypeValue2) {
                    case (#nat16(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat32(value1)) {
                switch (dataTypeValue2) {
                    case (#nat32(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat64(value1)) {
                switch (dataTypeValue2) {
                    case (#nat64(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#blob(value1)) {
                switch (dataTypeValue2) {
                    case (#blob(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#bool(value1)) {
                switch (dataTypeValue2) {
                    case (#bool(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#principal(value1)) {
                switch (dataTypeValue2) {
                    case (#principal(value2)) areEqual := value1 == value2;
                    case (_) Prelude.unreachable();
                };
            };
            case (_) {
                Prelude.unreachable();
            };
        };

        return areEqual;
    };

    public let DataTypeValueHashUtils : Map.HashUtils<Database.DataTypeValue> = (getHash, areEqual);

};