class Task < Sequel::Model(TASK_DB[:tasks])
  one_to_many :tags

  def <=>(other)
    [-1 * importance, time_cost.to_i] <=> [-1 * other.importance, other.time_cost.to_i]
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
