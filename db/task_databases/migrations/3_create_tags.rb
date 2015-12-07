Sequel.migration do
  up do
    sql =
      <<-SQL
        CREATE TABLE tags (id INTEGER NOT NULL PRIMARY KEY,
                            name VARCHAR,
                            task_id INTEGER NOT NULL,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
      SQL

    run sql
  end

  down do
  end
end
