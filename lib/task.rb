class Task < Sequel::Model(TASK_DB[:tasks])
  one_to_many :tags

  def self.create(params, &block)
    tags = params.delete 'tags'
    super(params).tap do |task|
      task.update_tags(tags) if tags
    end
  end

  def completed?
    tag_names.include? 'completed'
  end

  def time_cost
    raw_duration = super || 0
    TimeDuration.new(raw_duration)
  end

  def tag_names
    tags.map(&:name)
  end
end
