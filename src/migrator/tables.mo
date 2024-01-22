import Payload          "../alfangodb_backend/payload/table";
import Text "mo:base/Text";
import Array "mo:base/Array";


module {
  public let databases : [Payload.CreateDatabasePayload] = [
    {
      name: Text = "db1";
    },
    {
      name: Text = "db2";
    }
  ];

  public let tables : [Payload.CreateTablePayload] = [
    {
    databaseName : Text = "db1";
    name : Text = "table2";
    attributes = [
        {
            name : Text = "name";
            dataType = #text;
            unique = true;
            required = true;
            defaultValue = "";
        }
    ];
    indexes = [
         {
            name : Text = "name";
            attributeName : Text = "name";
            nonUnique = true;
        }
    ];
  },
  ];
}