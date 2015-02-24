require 'sinatra'
require './setup'
require './models'

get '/' do
  erb :index, locals: { title: 'Home' }
end

post '/' do
  # check login credentials
  # send to user home page if valid
  # else send back to login with error
end

get '/users/new' do
  user = User.new
  erb :'/users/new', locals: { user: user, title: 'Create Account' }
end

post '/users/new' do
  user = User.create(params[:user])

  if user.saved?
    sign_in!(user)
    redirect('/')
  else
    erb :'/users/new', locals: { user: user }
  end
end

get '/home/:id' do
  # display dashboard for logged in user
end

get '/stall/:id' do
  # get a specific stall page
end

get '/stalls' do
  # display stall search page
end

get '/stalls/new' do
  # create a stall page
end

post '/stalls/new' do
  # create a stall
end

get '/stalls/:id/edit' do
  # edit stall page
end

put '/stalls/:id' do
  # edit stall page
end

get '/requests/new' do
  # request a stall page
end

post '/requests/new' do
  # create a rental request
end

post '/requests/:id/edit' do
  # approve or reject a request
end

delete '/stall/:id' do
  # delete a stall (cancel any pending or accepted requests)
end

delete '/request/:id' do
  # delete a rental request
end

set(:sessions, true)
set(:session_secret, ENV['SESSION_SECRET'])

helpers do
  def title(page_title)
    return 'Air Stable' if page_title.nil?
    "#{page_title} | Air Stable"
  end

  def current_user
    ### I DON'T UNDERSTAND WHY THIS WORKS
    return nil unless session.key(:user_id)

    @current_user ||= User.get(session[:user_id])
  end

  def user_signed_in?
    !current_user.nil?
  end

  def sign_in!(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def sign_out!
    @current_user = nil
    session.delete(:user_id)
  end
end
