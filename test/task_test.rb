require_relative 'test_helper'

class TaskTest < Minitest::Test
  include DatabaseSetupAndTeardown

  def test_completed_returns_true_or_false_based_on_specific_tag_presence
    completed_task = Task.create(description: 'Some desc')
    Tag.create(name: 'completed', task_id: completed_task.id)
    uncomplete_task = Task.create(description: 'Some desc')

    assert completed_task.completed?
    refute uncomplete_task.completed?
  end


  end
end
