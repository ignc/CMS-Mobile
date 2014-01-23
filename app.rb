require 'sinatra/base'
require 'mustache/sinatra'
require 'data_mapper'
require 'pony'


class CMS < Sinatra::Base
  register Mustache::Sinatra
  require_relative 'views/layout'
  require_relative 'views/home'
  require_relative 'views/email'
  require_relative 'views/register'
  require_relative 'views/login'

  require_relative 'models'
  enable :sessions

  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/database.db")
  DataMapper.finalize

  CMS::Models::User.auto_upgrade!

  set :mustache, {
    :views => 'views',
    :templates => 'templates'
  }

  get '/' do
    mustache :home
  end

  get '/register' do
    mustache :register
  end

  post '/register' do
    name = params["name"]
    password = params["password"]
    email = params["email"]
    CMS::Models::User.create(
      :name => name,
      :email => email,
      :password => password
    )
    # Send email
    Pony.mail :to => email,
              :from => 'cheesemousesystem@i2cat.net',
              :subject => 'Welcome to Cheese Mouse System',
              :body => mustache(:email)
    mustache :home
  end

  get '/login' do
    mustache :login
  end

  post '/login' do
    name = params["name"]
    password = params["password"]
    @user = CMS::Models::User.first(
      :name => name,
      :password => password
    )
    if user.nil?
      redirect to('/login')
    end
    session["user"] = user.name
    mustache :home
  end

  post '/logout' do
    # TODO update session hash?
    @user = nil
    session["user"] = nil
  end

  get '/user/:name' do
    name = params["name"]
    user = CMS::Models::User.first(:name => name)
    # TODO
  end

end