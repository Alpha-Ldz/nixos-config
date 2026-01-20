{ pkgs, ... }:
{
  # MongoDB database tools
  home.packages = with pkgs; [
    mongodb-tools  # mongodump, mongorestore, mongoexport, mongoimport, etc.
    mongosh        # MongoDB Shell
  ];
}
