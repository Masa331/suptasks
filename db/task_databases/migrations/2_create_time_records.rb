Sequel.migration do
  up do
    sql =
      <<-SQL
        CREATE TABLE time_records (id INTEGER NOT NULL PRIMARY KEY,
                            task_id INTEGER,
                            description VARCHAR,
                            duration INTEGER NOT NULL,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
      SQL

    run sql
  end

  down do
  end
end
