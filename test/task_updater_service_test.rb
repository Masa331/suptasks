require_relative 'test_helper'

class TaskTest < Minitest::Test
  include DatabaseSetupAndTeardown

  def test_task_update_with_tags
    task = Task.create(description: 'Some task')
    Tag.create(name: 'tag1', task_id: task.id)
    Tag.create(name: 'tag2', task_id: task.id)

    service = TaskUpdaterService.new(task, { 'tags' => 'tag1, tag3' })
    service.call

    task.reload
    assert_equal ['tag1', 'tag3'], task.tag_names
  end

  def test_task_create_with_tags
    service = TaskUpdaterService.new(Task.new, { 'description' => 'Change car tires', 'tags' => 'tag1, tag3' })
    service.call

    assert_equal ['tag1', 'tag3'], Task.first.tag_names
  end
end
