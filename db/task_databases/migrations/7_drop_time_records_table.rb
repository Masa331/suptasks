Sequel.migration do
  up do
    sql =
      <<-SQL
        DROP TABLE time_records;
      SQL

    run sql
  end

  down do
  end
end
