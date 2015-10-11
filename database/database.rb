require 'sequel'
require 'base64'

module Database
  def self.connect_test_database
    db = Sequel.sqlite

    db.run tasks_migration
    db.run time_records_migration
    db.run tags_migration
  end

  def self.connect_user_database(user)
    db_name = database_name_from_email(user.email)
    path_to_database = Configuration.db_dir + db_name

    connect_or_create(path_to_database)
  end

  def self.connect_or_create(path_to_database)
    if File.exist?(path_to_database)
      connect(path_to_database)
    else
      db = connect(path_to_database)

      db.run tasks_migration
      db.run time_records_migration
      db.run tags_migration
    end
  end

  def self.database_count
    Dir.glob("#{Configuration.db_dir}/*").count
  end

  private

  def self.database_name_from_email(email)
    name = "#{email}_default"

    name = Base64.urlsafe_encode64(email)
    name + ".db"
  end

  def self.connect(database_path)
    Sequel.sqlite(database_path)
  end

  def self.tasks_migration
    <<-SQL
      CREATE TABLE tasks (id INTEGER NOT NULL PRIMARY KEY,
                          description VARCHAR NOT NULL,
                          time_cost INTEGER,
                          completed BOOLEAN NOT NULL DEFAULT 0 CHECK (completed IN (0,1)),
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
    SQL
  end

  def self.time_records_migration
    <<-SQL
      CREATE TABLE time_records (id INTEGER NOT NULL PRIMARY KEY,
                          task_id INTEGER,
                          description VARCHAR,
                          duration INTEGER NOT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
    SQL
  end

  def self.tags_migration
    <<-SQL
      CREATE TABLE tags (id INTEGER NOT NULL PRIMARY KEY,
                          name VARCHAR,
                          task_id INTEGER NOT NULL,
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL);
    SQL
  end
end
