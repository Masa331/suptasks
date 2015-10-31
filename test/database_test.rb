require_relative "test_helper"
require_relative "../lib/database_manager"

class DatabaseTest < Minitest::Test
  def test_inspect
    database = Database.new('donatuolcz.db')

    assert_equal "#<Database file_name=\"donatuolcz.db\">", database.inspect
  end

  def test_name
    database = Database.new('donatuolcz.db')

    assert_equal 'donatuolcz', database.name
  end

  def test_connect!
    skip('not yet implemented')
  end

  def test_connection
    skip('not yet implemented')
  end
end
