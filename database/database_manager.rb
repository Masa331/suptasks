require 'sequel'
require 'base64'
require_relative '../config/configuration'

module DatabaseManager
  class Database
    attr_accessor :path

    def initialize(path)
      @path = path
    end

    def user_email
      db_name = path.split('/').last
      db_name = db_name.gsub('.db', '')

      name = Base64.urlsafe_decode64(db_name)
      name.gsub('_default', '')
    end

    def connect!
      self.tap do |db|
        connection
      end
    end

    def connection
      @connection ||= Sequel.sqlite(path)
    end

    def inspect
      "#<DatabaseManager::Database path=\"#{path}\" user_email=\"#{user_email}\">"
    end
  end

  class Databases < SimpleDelegator
    def initialize(databases)
      super
    end

    def find_by_user_email(email)
      find { |database| database.user_email == email }
    end
  end

  def self.all_databases
    databases = Dir.glob("#{Configuration.db_dir}/*").map do |path|
      Database.new(path)
    end

    Databases.new(databases)
  end

  def self.connect_test_database
    db = Sequel.sqlite

    db.run tasks_migration
    db.run time_records_migration
    db.run tags_migration
    db.run add_started_at_to_time_records
  end

  def self.connect_user_database(user)
    if (database = all_databases.find_by_user_email(user.email))
      database.connect!
    else
      database = create_database_for_email(user.email)
      database.connect!
    end
  end

  def self.create_database_for_email(email)
    db_name = database_name_from_email(email)
    path_to_database = Configuration.db_dir + db_name
    db = Database.new(path_to_database)
    db.connect!
    db.connection.run tasks_migration
    db.connection.run time_records_migration
    db.connection.run tags_migration
    db.connection.run add_started_at_to_time_records

    db
  end

  def self.database_count
    all_databases.count
  end

  private

  def self.database_name_from_email(email)
    name = "#{email}_default"

    name = Base64.urlsafe_encode64(email)
    name + ".db"
  end

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
