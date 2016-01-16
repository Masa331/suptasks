class TaskUpdaterService
  def initialize(task, params)
    @task = task
    @params = params
  end

  def call
    tags = @params.delete 'tags'

    @task.update(@params)
    update_tags(tags) if tags
    @task
  end

  private

  def update_tags(new_tag_names)
    new_tag_names = new_tag_names.split(',').map(&:strip)

    remove_tags_not_in_list(new_tag_names)
    add_extra_tags_in_list(new_tag_names)
  end

  def remove_tags_not_in_list(new_tag_names)
    @task.tags.select do |tag|
      !new_tag_names.include? tag.name
    end.each do |tag|
      @task.tags.delete(tag).destroy
    end
  end

  def add_extra_tags_in_list(new_tag_names)
    new_tag_names.select do |name|
      !@task.tags.map(&:name).include? name
    end.each do |name|
      @task.add_tag(Tag.new(name: name))
    end
  end
end
