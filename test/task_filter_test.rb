require_relative 'test_helper'

class TaskFilterTest < Minitest::Test
  def setup
    TestDatabaseHelper.wipe_database
  end

  def test_filtering_by_description
    task = Task.create(description: 'Do this')
    Task.create(description: 'Do that')

    filtered = TaskFilter.new(Task.select_all, 'description' => 'Do this').call.all

    assert_equal 1, filtered.size
    assert_includes filtered, task
  end

  def test_filtering_by_status
    completed_task = Task.create(description: 'Do this')
    Tag.create(name: 'completed', task_id: completed_task.id)
    uncomplete_task = Task.create(description: 'Do that')

    completed_tasks = TaskFilter.new(Task.select_all, 'status' => '1').call.all
    assert_equal 1, completed_tasks.size
    assert_includes completed_tasks, completed_task

    uncomplete_tasks = TaskFilter.new(Task.select_all, 'status' => '0').call.all
    assert_equal 1, uncomplete_tasks.size
    assert_includes uncomplete_tasks, uncomplete_task

    all_tasks = TaskFilter.new(Task.select_all, 'status' => nil).call.all
    assert_equal 2, all_tasks.size
    assert_includes all_tasks, uncomplete_task
    assert_includes all_tasks, completed_task
  end

  def test_filtering_by_tags
    task = Task.create(description: 'Do this')
    Tag.create(name: 'important', task_id: task.id)
    Task.create(description: 'Do that')

    filtered = TaskFilter.new(Task.select_all, 'tags' => 'important').call.all
    assert_equal 1, filtered.size
    assert_includes filtered, task
  end

  def test_filtering_by_tags_with_tag_we_want_to_exclude
    task = Task.create(description: 'Do this')
    Tag.create(name: 'important', task_id: task.id)
    task2 = Task.create(description: 'Do that')

    filtered = TaskFilter.new(Task.select_all, 'tags' => '-important').call.all
    assert_equal 1, filtered.size
    assert_includes filtered, task2
  end
end
