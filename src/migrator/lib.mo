import create_konecta_database "create_konecta_database_2024020200001";

module {

    let migration_files = [ create_konecta_database ];

    public func fun() {
        let b  = migration_files[0];
    };

};