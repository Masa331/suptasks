require 'sequel'
require 'pathname'

class Database
  attr_reader :path

  def initialize(path)
    @path = Pathname.new(path)
  end

  def name
    path.basename.to_s.gsub('.db', '')
  end

  def inspect
    "#<Database file_name=\"#{path}\">"
  end
end
