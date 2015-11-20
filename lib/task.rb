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
    tag_names.include? 'completed'
  end

  def time_cost
    raw_duration = super || 0
    TimeDuration.new(raw_duration)
  end

  def tag_names
    tags.map(&:name)
  end

  def time_records
    TimeRecords.new(super)
  end

  def update(params)
    tags = params.delete 'tags'
    super(params).tap do |tag|
      update_tags(tags) if tags
    end
  end

  def update_tags(new_tag_names)
    new_tag_names = new_tag_names.split(',').map(&:strip)

    remove_tags_not_in_list(new_tag_names)
    add_extra_tags_in_list(new_tag_names)
  end

  private

  def remove_tags_not_in_list(new_tag_names)
    tags.select do |tag|
      !new_tag_names.include? tag.name
    end.each do |tag|
      tags.delete(tag).destroy
    end
  end

  def add_extra_tags_in_list(new_tag_names)
    new_tag_names.select do |name|
      !tags.map(&:name).include? name
    end.each do |name|
      add_tag(Tag.new(name: name))
    end
  end
end
