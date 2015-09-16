$:.unshift File.dirname(__FILE__)

require 'roda'
require_relative 'database/database'

autoload :User,       'models/user'
autoload :Task,       'models/task'
autoload :TimeRecord, 'models/time_record'
autoload :Tag,        'models/tag'
autoload :Configuration, 'models/configuration'

require 'rack/protection'

class Suptasks < Roda
  use Rack::Session::Cookie, secret: 'secret', key: 'key'
  # use Rack::Protection
  # plugin :csrf

  plugin :static, ['/images', '/css', '/js']
  plugin :render, layout: 'layout.html'
  plugin :head
  plugin :all_verbs
  plugin :param_matchers

  route do |r|
    r.root do
      if current_user
        r.redirect '/dashboard'
      else
        view('homepage.html')
      end
    end

    r.get 'tos' do
      view('tos.html')
    end

    r.post 'login' do
      if true
        session[:user_email] = 'pdonat@seznam.cz'
        session[:user_name]  = 'Premysl Donat'
        r.redirect '/'
      else
        r.redirect '/login'
      end
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

    begin
      connect_or_create_database(current_user.database_name)
    end

    r.is 'dashboard' do
      @uncompleted_tasks = Task.uncompleted

      @time_records = TimeRecord.all

      view('dashboard.html')
    end

    r.on 'tasks' do
      r.is ':id' do |id|
        @task = Task[id]

        r.get do
          view('task.html')
        end

        r.post param: '_delete_button' do
          @task.destroy

          r.redirect('/')
        end

        r.post param: '_complete_button' do
          @task.update(completed: true)

          r.redirect('/')
        end

        r.post do
          @task.update(description: r.params['description'], time_cost: r.params['time_cost'])
          @task.update_tags(r.params['tags'])

          r.redirect("/tasks/#{@task.id}")
        end
      end

      r.is do
        r.get do
          @tasks = Task.order(:completed).all
          view('tasks.html')
        end

        r.post do
          task = Task.create(description: r.params['description'], time_cost: r.params['time_cost'])
          task.update_tags(r.params['tags'])

          r.redirect('/')
        end
      end
    end

    r.on 'time_records' do
      r.get do
        @time_records = TimeRecord.all
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

    r.on 'profile' do
      r.is do
        r.get do
          view('profile.html')
        end
      end
    end
  end

  private

  def current_user
    if session[:user_email] && session[:user_name]
      User.new(email: session[:user_email], name: session[:user_name])
    else
      nil
    end
  end

  def connect_or_create_database(database_name)
    Database.connect_or_create(database_name)
  end
end
