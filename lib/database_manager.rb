require 'sequel'
require_relative 'database'

module DatabaseManager
  def self.migrate_all_databases
    all_databases.each do |database|
      migrate_database(database.path.to_s)
    end
  end

  def self.migrate_database(path_to_database)
    db = Sequel.sqlite(path_to_database)
    Sequel::Migrator.run(db, 'db/migrations')
  end

  private

  def self.all_databases
    Dir.glob("#{ENV['TASK_DATABASES_DIR']}*").select { |f| File.file? f }.map do |path|
      Database.new(path)
    end
  end
end
