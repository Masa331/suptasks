require 'sequel'

require_relative 'configuration'
require_relative 'database'

DB = Sequel.sqlite('db/empty_database.db', servers: {})
DB.extension :server_block
Sequel.extension :migration

module DatabaseManager
  def self.all_databases
    Dir.glob("#{Configuration.db_dir}*").map do |path|
      Database.new(path)
    end
  end

  def self.create_database_for_email(email)
    path_to_database = Configuration.db_dir + database_name_from_email(email) + '.db'

    db = Sequel.sqlite(path_to_database)

    Sequel::Migrator.run(db, 'db/migrations')
  end

  def self.database_name_from_email(email)
    email.delete('@.')
  end

  def self.servers_hash
    all_databases.each_with_object({}) do |db, hash|
      hash[db.name.to_sym] = { database: db.path.to_s }
    end
  end
end

DB.add_servers(DatabaseManager.servers_hash)
