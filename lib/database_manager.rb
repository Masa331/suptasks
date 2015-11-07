require 'sequel'

require_relative 'configuration'
require_relative 'database'
require_relative 'databases'

DB = Sequel.sqlite('databases/empty_database.db', servers: {})
DB.extension :server_block

module DatabaseManager
  def self.all_databases
    databases = Dir.glob("#{Configuration.db_dir}*").map do |path|
      Database.new(path)
    end

    Databases.new(databases)
  end

  def self.servers_hash
    servers = {}
    all_databases.each do |db|
      servers[db.name.to_sym] = { database: db.path.to_s }
    end
    servers
  end

  def self.connect_test_database
    db = Sequel.sqlite

    db.run tasks_migration
    db.run time_records_migration
    db.run tags_migration
    db.run add_started_at_to_time_records
  end

  def self.create_database_for_email(email)
    db_name = database_name_from_email(email)
    path_to_database = Configuration.db_dir + db_name + ".db"

    db = Database.new(path_to_database)
    db.connection.run tasks_migration
    db.connection.run time_records_migration
    db.connection.run tags_migration
    db.connection.run add_started_at_to_time_records
  end

  def self.database_name_from_email(email)
    email.delete('@').delete('.')
  end

  private

  def self.add_started_at_to_time_records
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

DB.add_servers(DatabaseManager.servers_hash)
