$:.unshift File.dirname(__FILE__)

require 'roda'
require 'omniauth'
require 'omniauth/google_oauth2'
require 'logger'
require 'dotenv'
Dotenv.load

require_relative 'lib/configuration'
require_relative 'lib/database_manager'

DB = Sequel.sqlite('databases/empty_database.db', servers: DatabaseManager.servers_hash)
DB.extension :server_block

require_relative 'lib/task'
require_relative 'lib/time_record'
require_relative 'lib/task_params_sanitizer'
require_relative 'lib/tag'
require_relative 'lib/user'
require_relative 'lib/time_records'
require_relative 'lib/time_records_pager'
require_relative 'lib/time_duration'

class Suptasks < Roda
  use Rack::Session::Cookie, { secret: Configuration.cookie_secret }

  use OmniAuth::Builder do
    provider :google_oauth2, Configuration.google_client_id, Configuration.google_client_secret
  end

  plugin :static, ['/images', '/css', '/js']
  plugin :render, layout: 'layout.html'
  plugin :head

  plugin :error_handler do |e|
    logger ||=
      begin
        logger = Logger.new(Configuration.log_file)
        logger.level = Logger::ERROR
        logger
      end

    logger.error(e.inspect)

    raise
  end

  route do |r|
    r.root do
      if current_user
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

      session[:user_email] = auth['info']['email']
      session[:user_name] = auth['info']['name']

      unless DatabaseManager.all_databases.find_by_name(current_database.to_s)
        DatabaseManager.create_database_for_email(current_user.email)

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
    unless current_user
      r.redirect '/'
    end
    #
    #
    #

    DB.with_server(current_database) do
      r.on 'tasks' do
        r.is ':id' do |id|
          @task = Task[id]

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
            @uncompleted_tasks = Task.uncompleted.order(:time_cost).all
            @time_records      = TimeRecords.new(TimeRecord.today.all)

            view('tasks.html')
          end

          r.post do
            Task.create(TaskParamsSanitizer.new(r.params).call)

            r.redirect('/')
          end
        end
      end

      r.on 'time_records' do
        r.get do
          pager = TimeRecordsPager.new(TimeRecord.select_all).by_number_of_days(23)

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
          TimeRecord.create(r.params)
          r.redirect('/')
        end
      end
    end
  end

  private

  def current_database
    DatabaseManager.database_name_from_email(current_user.email).to_sym
  end

  def current_user
    if session[:user_email] && session[:user_name]
      User.new(email: session[:user_email], name: session[:user_name])
    else
      nil
    end
  end
end
