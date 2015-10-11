require_relative "test_helper"

require_relative "../database/database_manager"

class DatabaseTest < Minitest::Test
  def test_user_email
    database = DatabaseManager::Database.new('ZG9uYXRAdW9sLmN6.db')

    assert_equal 'donat@uol.cz', database.user_email
  end

  def test_inspect
    database = DatabaseManager::Database.new('ZG9uYXRAdW9sLmN6.db')

    assert_equal "#<DatabaseManager::Database path=\"ZG9uYXRAdW9sLmN6.db\" user_email=\"donat@uol.cz\">", database.inspect
  end

  def test_connect!
    skip('not yet implemented')
  end

  def test_connection
    skip('not yet implemented')
  end
end