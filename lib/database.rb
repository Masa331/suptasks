require 'sequel'
require 'base64'
require 'pathname'

class Database
  attr_accessor :path

  def initialize(path)
    @path = Pathname.new(path)
  end

  def name
    path.basename.to_s.gsub('.db', '')
  end

  def connect!
    self.tap do |db|
      connection
    end
  end

  def connection
    @connection ||= Sequel.sqlite(path.to_s)
  end

  def inspect
    "#<Database file_name=\"#{path}\">"
  end
end
