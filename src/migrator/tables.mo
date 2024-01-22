import Payload          "../alfangodb_backend/payload/table";

module {
  public let tables : Payload.CreateTablePayload = {
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
  };
}