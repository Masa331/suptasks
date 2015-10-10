require "minitest/autorun"
require 'minitest/reporters'
require_relative "../database/database"

Database.connect_test_database
Minitest::Reporters.use!
