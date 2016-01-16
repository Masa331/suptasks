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

  def test_comparison
    task1 = Task.new(time_cost: 20)
    task2 = Task.new(time_cost: 10)
    task3 = Task.new(time_cost: 25)

    task3.stub :tags, [Tag.new(name: 'important')] do
      task1.stub :tags, [Tag.new(name: 'neco')] do
        assert_equal [task3, task2, task1], [task1, task2, task3].sort
      end
    end
  end
end
