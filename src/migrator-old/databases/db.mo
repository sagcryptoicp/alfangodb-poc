import Payload          "../alfangodb_backend/payload/table";
import Text             "mo:base/Text";
import Array            "mo:base/Array";


module {
  public let databases : [Payload.CreateDatabasePayload] = [
    {
      name: Text = "UserRegistration";
    },
  ];
}