import AlfangoDB        "mo:alfangodb/AlfangoDB";

module {
    public let name = "2024020200001-create-konecta-database";
    public let migrationInput : AlfangoDB.UpdateOpsInputType = #CreateDatabaseInput({ name = "rag" });  
};