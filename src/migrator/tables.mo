import Payload          "../alfangodb_backend/payload/table";
import Text             "mo:base/Text";
import Array            "mo:base/Array";


module {
  public let databases : [Payload.CreateDatabasePayload] = [
    {
      name: Text = "db3";
    },
    {
      name: Text = "db4";
    }
  ];
  

  public let tables : [Payload.CreateTablePayload] = [
  {
    databaseName : Text = "db3";
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

  public let tableitems : [Payload.CreateItemPayload] = [
    {
        databaseName: Text = "db1";
        tableName: Text = "table1";
        data = [ 
          ( "jay", #text("text") ),
          ( "rag", #text("text") )
        ];
    }
  ];
}