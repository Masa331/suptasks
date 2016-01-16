require 'capybara'
require_relative 'test_helper'

Capybara.app = Suptasks

class FeatureTest < Minitest::Test
  include DatabaseSetupAndTeardown
  include Capybara::DSL

  def setup
    Capybara.default_host = 'http://my-tasks.suptasks.com'

    super
  end

  def teardown
    Capybara.reset_session!
    super
  end


  def test_login
    log_in

    assert has_content? 'Log out'
  end

  def test_logout
    log_in

    click_on 'Log out'

    refute has_content? 'Log out'
  end

  def test_creating_new_task
    log_in

    click_on 'Add Task'
    fill_in 'Description', with: 'Change car tires'
    fill_in 'Tags', with: 'car'
    fill_in 'Time Cost', with: '60'
    click_on 'Create new task'

    assert has_content? 'Change car tires'
    assert has_content? 'car'
  end

  def test_task_update
    Task.create(description: 'Change car tires')
    log_in

    click_on 'Change car tires'
    click_on 'Edit'
    fill_in 'Description', with: 'Change car tires. Because winter is coming.'
    click_on 'Update task'

    assert has_content? 'Change car tires. Because winter is coming.'
  end

  def test_task_completion
    Task.create(description: 'Change car tires')
    log_in

    assert has_content? 'Change car tires'

    click_on 'Close'

    assert has_content? "Seems like you don't have any tasks to do. That's cool!"
  end

  def test_task_filtering_by_description
    Task.create(description: 'Change car tires')
    Task.create(description: 'Buy food')
    log_in

    fill_in 'Description', with: 'food'
    click_on 'Filter'

    assert has_content? 'Buy food'
    refute has_content? 'Change car tires'
  end

  def test_task_filtering_by_tags
    car_task = Task.create(description: 'Change car tires')
    Tag.create(task: car_task, name: 'car')

    hidden_car_task = Task.create(description: 'Buy new car')
    Tag.create(task: hidden_car_task, name: 'car')
    Tag.create(task: hidden_car_task, name: 'hide')

    food_task = Task.create(description: 'Buy food')
    Tag.create(task: food_task, name: 'food')
    log_in

    fill_in 'Tags', with: '-hide, car'
    click_on 'Filter'

    assert has_content? 'Change car tires'
    refute has_content? 'Buy food'
    refute has_content? 'Buy new car'
  end

  private

  def log_in
    hashed_password = '$2a$10$nxUfHs7RffbaIUzx9uv0GeqoOFPR7rUHztcnGyCImnMuPilxGIIyG'
    User.create(email: 'user@email.com', password: hashed_password, database: 'my-tasks')

    visit '/'

    fill_in 'E-mail', with: 'user@email.com'
    fill_in 'Password', with: 'password'
    click_on 'Sign in'
  end
end
