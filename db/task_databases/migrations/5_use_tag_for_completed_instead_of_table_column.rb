Sequel.migration do
  up do
    sql =
      <<-SQL
        INSERT INTO tags (name, task_id) SELECT 'completed', id FROM tasks where completed = '1';

        CREATE TABLE tasks_x (id INTEGER NOT NULL PRIMARY KEY,
                              description VARCHAR NOT NULL,
                              time_cost INTEGER,
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);

        INSERT INTO tasks_x SELECT id, description, time_cost, created_at FROM tasks;

        DROP TABLE tasks;
        ALTER TABLE tasks_x RENAME TO tasks;
      SQL

    run sql
  end

  down do
  end
end
