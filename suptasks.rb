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

Sequel::Model.plugin :timestamps

require_relative 'lib/database_manager'
require_relative 'lib/task'
require_relative 'lib/params_sanitizers'
require_relative 'lib/tag'
require_relative 'lib/time_duration'
require_relative 'lib/created_task_flash_message'
require_relative 'lib/task_filter'
require_relative 'lib/user'
require_relative 'lib/etag_generator'
require_relative 'lib/task_updater_service'

class Suptasks < Roda
  use Rack::Session::Cookie, { secret: ENV['COOKIE_SECRET'] }

  plugin :static, ['/images', '/css', '/js']
  plugin :render, layout: 'layout.html'
  plugin :head
  plugin :flash
  plugin :param_matchers
  plugin :caching

  plugin :error_handler do |e|
    logger ||= Logger.new(ENV['LOG_FILE_PATH'])
    logger.error(e.inspect)

    raise
  end

  route do |r|
    @current_user = User.where(id: session[:current_user_id]).first

    r.get 'about' do
      view('about.html')
    end

    r.post 'logout' do
      session.clear
      r.redirect '/'
    end

    r.post 'login' do
      user = User.find_authenticated(r.params['email'], r.params['password'])
      if user
        session[:current_user_id] = user.id
      end

      r.redirect '/'
    end

    r.root do
      if @current_user
        r.redirect('/tasks')
      else
        view('homepage.html')
      end
    end

    unless @current_user
      r.redirect '/'
    end

    database =
      if File.exists?(ENV['TASK_DATABASES_DIR'] + @current_user.database)
        ENV['TASK_DATABASES_DIR'] + @current_user.database
      end

    TASK_DB.with_server(database: database) do
      TASK_DB.synchronize do
        r.on 'tasks' do
          r.get 'new' do
            @tags = Tag.distinct.select(:name)
            view('new_task.html')
          end

          r.on ':id' do |id|
            @task = Task[id]

            r.get 'edit' do
              @tags = Tag.distinct.select(:name)
              view('edit_task.html')
            end

            r.get do
              response.cache_control(private: true)
              r.etag(ETagGenerator.call(@task), weak: true)
              view('task.html')
            end

            r.post do
              @task = TaskUpdaterService.new(@task, TaskParamsSanitizer.call(r.params)).call

              r.redirect('/')
            end
          end

          r.is do
            r.get do
              @filter = TaskFilter.new(Task.select_all, r.params)
              @tasks = @filter.call.all.sort
              @tags = Tag.distinct.select(:name)

              view('tasks.html')
            end

            r.post do
              task = TaskUpdaterService.new(Task.new, TaskParamsSanitizer.call(r.params)).call
              flash['success'] = CreatedTaskFlashMessage.new(task).to_s

              r.redirect('/')
            end
          end
        end
      end
    end
  end
end
