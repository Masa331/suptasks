require_relative "test_helper"

require_relative "../database/database_manager"

class DatabasesTest < Minitest::Test
  def test_databases_delegate
    database1 = DatabaseManager::Database.new('cGRvbmF0QHNlem5hbS5jel9kZWZhdWx0.db')
    database2 = DatabaseManager::Database.new('ZG9uYXRAdW9sLmN6.db')

    databases = DatabaseManager::Databases.new([database1, database2])

    assert_equal 2, databases.count
  end

  def test_find_by_user_email_find_right_database
    database1 = DatabaseManager::Database.new('cGRvbmF0QHNlem5hbS5jel9kZWZhdWx0.db')
    database2 = DatabaseManager::Database.new('ZG9uYXRAdW9sLmN6.db')

    databases = DatabaseManager::Databases.new([database1, database2])

    assert_equal database2, databases.find_by_user_email('donat@uol.cz')
  end

  def test_find_by_user_email_returns_nil_if_not_found
    database1 = DatabaseManager::Database.new('cGRvbmF0QHNlem5hbS5jel9kZWZhdWx0.db')
    database2 = DatabaseManager::Database.new('bm92YWtAY2VudHJ1bS5jel9kZWZhdWx0.db')

    databases = DatabaseManager::Databases.new([database1, database2])

    assert_equal nil, databases.find_by_user_email('donat@uol.cz')
  end
end