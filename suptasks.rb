require 'roda'
require_relative 'database/database'

require_relative 'models/user'
require_relative 'models/task'
require_relative 'models/time_record'

require 'rack/protection'

class Suptasks < Roda

  # TODO: Handle security later :D
  #
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
        @uncompleted_tasks = Task.uncompleted

        @time_records = TimeRecord.all

        view('dashboard.html')
      else
        view('homepage.html')
      end
    end

    r.post 'login' do
      if true
        session[:user_email] = 'pdonat@seznam.cz'
        session[:user_name] = 'Premysl Donat'
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

    r.on 'tasks' do
      r.is ':id' do |id|
        r.get do
          @task = Task[id]
          view('task.html')
        end

        r.post param: '_delete' do
          task = Task[id]
          task.destroy

          r.redirect('/')
        end

        r.post param: '_completed' do
          task = Task[id]
          task.update(completed: true)

          r.redirect('/')
        end
      end

      r.is do
        r.get do
          @tasks = Task.all
          @time_records = TimeRecord.all
          view('tasks.html')
        end

        r.post do
          Task.create(r.params)
          r.redirect('/')
        end
      end
    end

    r.on 'time_records' do
      r.is ':id' do |id|
        r.post param: '_delete' do
          task = TimeRecord[id]
          task.destroy

          r.redirect('/')
        end
      end

      r.post do
        TimeRecord.create(r.params)
        r.redirect('/')
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
end
