Sequel.migration do
  up do
    sql =
      <<-SQL
        CREATE TABLE tasks_x (id INTEGER NOT NULL PRIMARY KEY,
                              description VARCHAR NOT NULL,
                              time_cost INTEGER,
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
        INSERT INTO tasks_x SELECT id, description, time_cost, created_at, created_at FROM tasks;
        DROP TABLE tasks;
        ALTER TABLE tasks_x RENAME TO tasks;

        CREATE TABLE time_records_x (id INTEGER NOT NULL PRIMARY KEY,
                            task_id INTEGER,
                            description VARCHAR,
                            duration INTEGER NOT NULL,
                            started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
        INSERT INTO time_records_x SELECT id, task_id, description, duration, created_at, created_at, created_at FROM time_records;
        DROP TABLE time_records;
        ALTER TABLE time_records_x RENAME TO time_records;

        CREATE TABLE tags_x (id INTEGER NOT NULL PRIMARY KEY,
                            name VARCHAR,
                            task_id INTEGER NOT NULL,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
        INSERT INTO tags_x SELECT id, name, task_id, created_at, created_at FROM tags;
        DROP TABLE tags;
        ALTER TABLE tags_x RENAME TO tags;
      SQL

    run sql
  end

  down do
  end
end
