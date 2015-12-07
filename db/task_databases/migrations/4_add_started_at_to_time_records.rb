Sequel.migration do
  up do
    sql =
      <<-SQL
        CREATE TABLE time_records_x (id INTEGER NOT NULL PRIMARY KEY,
                            task_id INTEGER,
                            description VARCHAR,
                            duration INTEGER NOT NULL,
                            started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);

        INSERT INTO time_records_x SELECT id, task_id, description, duration, created_at, created_at FROM time_records;

        DROP TABLE time_records;
        ALTER TABLE time_records_x RENAME TO time_records;
      SQL

    run sql
  end

  down do
  end
end
