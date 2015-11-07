require 'delegate'

class Databases < SimpleDelegator
  def initialize(databases)
    super
  end

  def find_by_name(name)
    find { |database| database.name == name }
  end
end
