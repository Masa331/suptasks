# OneWhoTalksTooMuch is function-style module which knows how to comment certain events.
#   For exmpale there is a method for creating a comment about new task creation. I use returned
#   message in flash which i display to user after sucessfull creation.
module OneWhoTalksTooMuch
  # Creates a flash message including html tags for displaying to user
  def self.comment_task_creation_html(task)
    base_comment = "<b>#{task.description}</b>"

    tags_comment = time_est_comment = ''

    if task.tags.any?
      tag_template = "<span class='label label-primary'>%s</span>"
      tags = task.tags.map(&:name).map { |tag| tag_template % tag }.join(' ')

      tags_comment = ['with tags', *tags].join(' ')
    end

    unless task.time_cost.zero?
      time_est_comment = " Your time estimation is <b>#{task.time_cost}</b>."
    end

    [base_comment, tags_comment, 'created!', time_est_comment].compact.join(' ')
  end

  def self.comment_time_record_creation_html(time_record)
    "<b>#{time_record.duration}</b> added to <b>#{time_record.task.description}</b>."
  end
end
