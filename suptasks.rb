$:.unshift File.dirname(__FILE__)

require 'roda'
require 'omniauth'
require 'omniauth/google_oauth2'
require 'logger'
require 'dotenv'
Dotenv.load

require_relative 'lib/configuration'
# DatabaseManager must come first because it opens up a default
#   Sequel connection and that is required for subclassing Sequel::Model
require_relative 'lib/database_manager'

require_relative 'lib/task'
require_relative 'lib/time_record'
require_relative 'lib/task_params_sanitizer'
require_relative 'lib/time_record_params_sanitizer'
require_relative 'lib/tag'
require_relative 'lib/time_records'
require_relative 'lib/time_records_pager'
require_relative 'lib/time_duration'
require_relative 'lib/one_who_talks_too_much'
require_relative 'lib/task_filter'

class Suptasks < Roda
  use Rack::Session::Cookie, { secret: Configuration.cookie_secret }

  use OmniAuth::Builder do
    provider :google_oauth2, Configuration.google_client_id, Configuration.google_client_secret
  end

  plugin :static, ['/images', '/css', '/js']
  plugin :render, layout: 'layout.html'
  plugin :head
  plugin :flash

  plugin :error_handler do |e|
    logger ||= Logger.new(Configuration.log_file)
    logger.error(e.inspect)

    raise
  end

  route do |r|
    @current_email = session[:user_email]

    r.root do
      if @current_email
        r.redirect '/tasks'
      else
        @databases_count = DatabaseManager.all_databases.count
        view('homepage.html')
      end
    end

    r.get 'about' do
      view('about.html')
    end

    r.get 'changelog' do
      view('changelog.html')
    end

    r.get 'auth/google_oauth2/callback' do
      auth = request.env['omniauth.auth']

      email = session[:user_email] = auth['info']['email']
      session[:user_name] = auth['info']['name']

      unless DatabaseManager.all_databases.find_by_name(DatabaseManager.database_name_from_email(email))
        DatabaseManager.create_database_for_email(email)

        DB.add_servers(DatabaseManager.servers_hash)
      end

      r.redirect '/'
    end

    r.post 'logout' do
      session.clear
      r.redirect '/'
    end

    #
    # Authentication
    #
    unless @current_email
      r.redirect '/'
    end
    #
    #
    #

    DB.with_server(DatabaseManager.database_name_from_email(@current_email).to_sym) do
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
            @time_records = TimeRecords.new(@task.time_records)

            view('task.html')
          end

          r.post do
            @task.update(TaskParamsSanitizer.new(r.params).call)

            r.redirect("/tasks/#{@task.id}")
          end
        end

        r.is do
          r.get do
            @filter = TaskFilter.new(r.params, Task.select_all)
            @tasks = @filter.call.order(:time_cost).all
            @time_records = TimeRecords.new(TimeRecord.today.where(task_id: @tasks.map(&:id)).all)

            view('tasks.html')
          end

          r.post do
            task = Task.create(TaskParamsSanitizer.new(r.params).call)
            msg = OneWhoTalksTooMuch.comment_task_creation_html(task)

            flash['success'] = msg

            r.redirect('/')
          end
        end
      end

      r.on 'time_records' do
        r.get do
          @filter = TaskFilter.new(r.params, Task.select_all)
          tasks = @filter.call.order(:time_cost).all

          pager = TimeRecordsPager.new(TimeRecord.where(task_id: tasks.map(&:id))).by_number_of_days(23)

          @number_of_pages = pager.size
          @current_page    = (r.params['page'] || 1).to_i
          # -1 is for array index from zero :)
          @time_records    = TimeRecords.new(pager[(@current_page - 1)].order(:started_at).all)

          view('time_records.html')
        end

        r.is ':id' do |id|
          r.post param: '_delete_button' do
            time_record = TimeRecord[id]
            time_record.destroy

            r.redirect('/')
          end
        end

        r.post do
          time_record = TimeRecord.create(TimeRecordParamsSanitizer.new(r.params).call)
          msg = OneWhoTalksTooMuch.comment_time_record_creation_html(time_record)

          flash['success'] = msg

          r.redirect('/')
        end
      end
    end
  end
end
