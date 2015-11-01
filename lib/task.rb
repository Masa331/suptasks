require_relative 'database_manager'

class Task < Sequel::Model
  one_to_many :time_records
  one_to_many :tags

  def self.create(params, &block)
    tags = params.delete 'tags'

    task = super(params)

    if tags && !tags.empty?
      task.update_tags(tags)
    end

    task
  end

  def time_cost
    raw_duration = super || 0
    TimeDuration.new(raw_duration)
  end

  def self.uncompleted
    where(completed: 0)
  end

  def tag_names
    tags.map(&:name).join(', ')
  end

  def short_description
    if description.size > 30
      description[0..30] + "..."
    else
      description
    end
  end

  def time_spent
    time_records.inject(TimeDuration.new(0)) { |sum, record| sum + record.to_duration }
  end

  def update(params)
    tags = params.delete 'tags'

    super

    if tags && !tags.empty?
      update_tags(tags)
    end
  end

  def update_tags(new_tags)
    current_tags = tags.map(&:name)

    new_tags = new_tags.split(',')
    new_tags = new_tags.map(&:strip)

    to_be_created = new_tags - current_tags
    to_be_deleted = current_tags - new_tags

    to_be_created.each do |tag|
      Tag.create(name: tag, task_id: id)
    end

    to_be_deleted.each do |tag|
      Tag.where(task_id: id, name: tag).destroy
    end
  end
end
