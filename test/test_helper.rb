require "minitest/autorun"
require 'minitest/reporters'
require_relative "../lib/database_manager"

DatabaseManager.connect_test_database
Minitest::Reporters.use!
