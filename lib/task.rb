class Task < Sequel::Model
  one_to_many :time_records
  one_to_many :tags

  def self.create(params, &block)
    tags = params.delete 'tags'
    super(params).tap do |task|
      task.update_tags(tags) if tags
    end
  end

  def completed?
    completed
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

  def time_spent
    time_records.inject(TimeDuration.new(0)) { |sum, record| sum + record.to_duration }
  end

  def update(params)
    tags = params.delete 'tags'
    super(params).tap do |tag|
      update_tags(tags) if tags
    end
  end

  def update_tags(tag_names)
    remove_tags_not_in_list(tag_names)
    add_extra_tags_in_list(tag_names)
  end

  def remove_tags_not_in_list(tag_names)
    new_tags = tag_names.split(',').map(&:strip)

    tags.select do |tag|
      !new_tags.include? tag.name
    end.each do |tag|
      tags.delete(tag).destroy
    end
  end

  def add_extra_tags_in_list(tag_names)
    new_tags = tag_names.split(',').map(&:strip)

    new_tags.select do |name|
      !tags.map(&:name).include? name
    end.each do |name|
      add_tag(Tag.new(name: name))
    end
  end
end
