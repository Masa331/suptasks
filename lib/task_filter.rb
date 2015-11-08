require 'sequel'

class TaskFilter
  attr_accessor :description

  def initialize(params = {})
    @description = params['description']
  end

  def to_s
    if description && !description.empty?
      "Showing tasks with '#{description}' in description."
    else
      "Showing uncomplete tasks."
    end
  end

  def to_sql
    if description
      Sequel.ilike(:description, "%#{description}%")
    end
  end
end
