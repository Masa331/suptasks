require_relative "test_helper"

require_relative "../lib/databases"

class DatabasesTest < Minitest::Test
  def test_databases_delegate
    database1 = Database.new('cGRvbmF0QHNlem5hbS5jel9kZWZhdWx0.db')
    database2 = Database.new('ZG9uYXRAdW9sLmN6.db')

    databases = Databases.new([database1, database2])

    assert_equal 2, databases.count
  end

  def test_find_by_name_find_right_database
    database1 = Database.new('pdonatseznamcz.db')
    database2 = Database.new('karelnovakcz.db')

    databases = Databases.new([database1, database2])

    assert_equal database1, databases.find_by_name('pdonatseznamcz')
  end

  def test_find_by_name_returns_nil_if_not_found
    database1 = Database.new('pdonatseznamcz.db')
    database2 = Database.new('karelnovakcz.db')

    databases = Databases.new([database1, database2])

    assert_equal nil, databases.find_by_name('nesmyslcz')
  end
end
