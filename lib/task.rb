require 'it_sorts'

class Task < Sequel::Model(TASK_DB[:tasks])
  include ItSorts::SortSetup

  one_to_many :tags

  def sort_setup
    [ItSorts.desc(importance), ItSorts.asc(time_cost.to_i)]
  end

  def completed?
    tag_names.include? 'completed'
  end

  def importance
    tag_names.include?('important') ? 1 : -1
  end

  def tag_names
    tags.map(&:name)
  end

  def time_cost
    raw_duration = super || 0
    TimeDuration.new(raw_duration)
  end
end
