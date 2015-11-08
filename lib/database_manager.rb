require 'sequel'

require_relative 'configuration'
require_relative 'database'
require_relative 'databases'

DB = Sequel.sqlite('db/empty_database.db', servers: {})
DB.extension :server_block
Sequel.extension :migration

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

  def self.create_database_for_email(email)
    db_name = database_name_from_email(email)
    path_to_database = Configuration.db_dir + db_name + ".db"

    db = Sequel.sqlite(path_to_database)

    Sequel::Migrator.run(db, 'db/migrations')
  end

  def self.database_name_from_email(email)
    email.delete('@').delete('.')
  end
end

DB.add_servers(DatabaseManager.servers_hash)
