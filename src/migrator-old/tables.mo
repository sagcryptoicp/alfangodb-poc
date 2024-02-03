import Payload          "../alfangodb_backend/payload/table";
import Text             "mo:base/Text";
import Array            "mo:base/Array";


module {
  public let databases : [Payload.CreateDatabasePayload] = [
    {
      name: Text = "UserRegistration";
    },
  ];
  

  public let tables : [Payload.CreateTablePayload] = [
  {
    databaseName : Text = "UserRegistration";
    name : Text = "Users";
    attributes = [
        {
          name : Text = "FirstName";
          dataType = #text;
          unique = true;
          required = true;
          defaultValue = "";
        },
        {
          name : Text = "LastName";
          dataType = #text;
          unique = true;
          required = true;
          defaultValue = "";
        },
        {
          name : Text = "Email";
          dataType = #text;
          unique = true;
          required = true;
          defaultValue = "";
        },
        {
          name : Text = "Mobile";
          dataType = #text;
          unique = true;
          required = true;
          defaultValue = "";
        },
        {
          name : Text = "Subscribers";
          dataType = #int64;
          unique = false;
          required = false;
          defaultValue = "";  //defaultvalue should be of datatype i give??
        },
    ];
    indexes = [
         {
            name : Text = "FirstNameindex";
            attributeName : Text = "FirstName";
            nonUnique = false;
        }
    ];
  },
  ];

  public let createtableitems : [Payload.CreateItemPayload] = [
    {
        databaseName: Text = "UserRegistration";
        tableName: Text = "Users";
        data = [ 
          ( "FirstName", #text("Jay") ),
          ( "LastName", #text("Gurnani") ),
          ( "Email", #text("gurnanijay1999@gmail.com") ),
          ( "Mobile", #text("9256786789") ),
          ( "Subscribers", #int64(555555) )
        ];
    }
  ];

  public let gettableitems : [Payload.GetItemPayload] = [
    {
        databaseName: Text = "UserRegistration";
        tableName: Text = "Users";
        itemId: Text = "0FM9TY580K67D8TRW26ZBRCK0S";
    }
  ];
  
}