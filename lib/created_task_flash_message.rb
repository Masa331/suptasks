class CreatedTaskFlashMessage
  def initialize(task)
    @task = task
  end

  def to_s
    [base_comment, tags_comment, 'created!', time_est_comment, links].compact.join(' ')
  end

  private

  def base_comment
    "<b><a href='/tasks/#{@task.id}'>#{@task.description}</a></b>"
  end

  def tags_comment
    if @task.tags.any?
      label_template = "<span class='label label-primary'>%s</span>"
      tags = @task.tags.map(&:name).map { |tag| label_template % tag }

      ['with tags', *tags].join(' ')
    end
  end

  def time_est_comment
    unless @task.time_cost.zero?
      " Your time estimation is <b>#{@task.time_cost}</b>."
    end
  end

  def links
    "<a class='pull-right' href='/tasks/#{@task.id}/edit'>Edit task</a>"
  end
end
