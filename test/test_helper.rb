require 'dotenv'
Dotenv.load('.test')
require 'sequel'
Sequel.extension :migration

class TestDatabaseHelper
  def self.prepare_databases
    user_db = Sequel.sqlite(ENV['USER_DATABASE_PATH'])
    Sequel::Migrator.run(user_db, 'db/user_database/migrations')

    task_db = Sequel.sqlite(ENV['TASK_DATABASES_DIR'] + 'my-tasks')
    Sequel::Migrator.run(task_db, 'db/task_databases/migrations')
  end

  def self.wipe_databases
    Tag.select_all.delete
    User.select_all.delete
    Task.select_all.delete
  end
end
TestDatabaseHelper.prepare_databases

module DatabaseSetupAndTeardown
  def setup
    TestDatabaseHelper.prepare_databases
  end

  def teardown
    TestDatabaseHelper.wipe_databases
  end
end

require_relative '../suptasks'

require 'minitest'
require 'minitest/autorun'
