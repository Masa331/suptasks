require 'sequel'

DB = Sequel.sqlite
Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrations')

require_relative '../lib/task'
require_relative '../lib/tag'
require_relative '../lib/time_record'

class TestDatabaseHelper
  def self.wipe_database
    Task.select_all.delete
    Tag.select_all.delete
    TimeRecord.select_all.delete
  end
end
