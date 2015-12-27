$:.unshift File.dirname(__FILE__)

require 'roda'
require 'sequel'
Sequel.extension :migration
require 'logger'

CUSTOMER_DB = Sequel.sqlite(ENV['USER_DATABASE_PATH'])

first_database = Dir.glob("#{ENV['TASK_DATABASES_DIR']}*").find { |f| File.file? f }
TASK_DB = Sequel.sqlite(first_database, servers: {})
TASK_DB.extension :arbitrary_servers
TASK_DB.extension :server_block

require_relative 'lib/database_manager'
require_relative 'lib/task'
require_relative 'lib/time_record'
require_relative 'lib/params_sanitizers'
require_relative 'lib/tag'
require_relative 'lib/time_records'
require_relative 'lib/time_duration'
require_relative 'lib/created_task_flash_message'
require_relative 'lib/task_filter'
require_relative 'lib/user'

class Suptasks < Roda
  use Rack::Session::Cookie, { secret: ENV['COOKIE_SECRET'] }

  plugin :static, ['/images', '/css', '/js']
  plugin :render, layout: 'layout.html'
  plugin :head
  plugin :flash
  plugin :param_matchers

  plugin :error_handler do |e|
    logger ||= Logger.new(ENV['LOG_FILE_PATH'])
    logger.error(e.inspect)

    raise
  end

  route do |r|
    subdomain = r.host.split('.')[-3]
    @current_user = User.where(id: session[:current_user_id], database: subdomain).first

    r.get 'homepage' do
      view('homepage.html')
    end

    r.get 'about' do
      view('about.html')
    end

    r.get 'changelog' do
      view('changelog.html')
    end

    r.post 'logout' do
      session.clear
      r.redirect '/'
    end

    if subdomain.nil?
      r.redirect('/homepage')
    end

    database =
      if File.exists?(ENV['TASK_DATABASES_DIR'] + subdomain)
        ENV['TASK_DATABASES_DIR'] + subdomain
      end

    r.get 'register' do
      view('register.html')
    end

    if database.nil?
      r.redirect('/register')
    end

    r.root do
      if @current_user
        r.redirect('/tasks')
      else
        r.redirect('/login')
      end
    end

    r.get 'login' do
      view('login.html')
    end

    r.post 'login' do
      user = User.find_authenticated(r.params['email'], r.params['password'], subdomain)
      if user
        session[:current_user_id] = user.id
      end

      r.redirect '/'
    end

    unless @current_user
      r.redirect '/'
    end

    TASK_DB.with_server(database: database) do
      TASK_DB.synchronize do
        r.on 'tasks' do
          r.get 'new' do
            view('new_task.html')
          end

          r.on ':id' do |id|
            @task = Task[id]

            r.get 'edit' do
              view('edit_task.html')
            end

            r.get do
              @time_records = @task.time_records

              view('task.html')
            end

            r.post do
              @task.update(TaskParamsSanitizer.call(r.params))

              r.redirect("/tasks/#{@task.id}")
            end
          end

          r.is do
            r.get do
              @filter = TaskFilter.new(Task.select_all, r.params)
              @tasks = @filter.call.order(:time_cost).all
              @time_records = TimeRecords.new(TimeRecord.today.where(task_id: @tasks.map(&:id)).all)

              view('tasks.html')
            end

            r.post do
              task = Task.create(TaskParamsSanitizer.call(r.params))
              flash['success'] = CreatedTaskFlashMessage.new(task).to_s

              r.redirect('/')
            end
          end
        end

        r.on 'time_records' do
          r.is ':id' do |id|
            r.post param: '_delete_button' do
              time_record = TimeRecord[id]
              time_record.destroy

              r.redirect('/')
            end
          end

          r.post do
            time_record = TimeRecord.create(TimeRecordParamsSanitizer.call(r.params))

            r.redirect('/')
          end
        end
      end
    end
  end
end
