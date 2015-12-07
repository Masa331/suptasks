Sequel.migration do
  up do
    sql =
      <<-SQL
        CREATE TABLE users
          (id INTEGER NOT NULL PRIMARY KEY,
           email VARCHAR,
           password VARCHAR,
           database VARCHAR NOT NULL);
      SQL

    run sql
  end

  down do
  end
end
