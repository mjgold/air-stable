# Why does rerun sometimes not work?
# Why is my Airstable calling a route that it shouldn't?
# How to use current user in routes instead of passing user as local?
#   Should I just use user instance variable?

require 'sinatra'
require './setup'
require './models'
require 'PP'

set(:sessions, true)
set(:session_secret, ENV['SESSION_SECRET'])

# set(:requires_login) do
#   condition do
#     redirect '/' unless user_signed_in?
#   end
#   true
# end

get '/' do
  user = User.new
  erb :index, locals: { user: user, title: 'Home' }
end

get '/sessions/sign_out' do
  sign_out!
  redirect('/')
end

post '/sessions' do
  user = User.find_by_credentials(params[:email], params[:password])

  if user.errors.any?
    erb :index, locals: { user: user, title: 'Home' }
  else
    sign_in!(user)
    redirect('/stalls')
  end
end

get '/users/new' do
  user = User.new
  erb :'/users/new', locals: { user: user, title: 'Create Account' }
end

post '/users/new' do
  user = User.create(params[:user])

  if user.saved?
    sign_in!(user)
    redirect("/home/#{user.id}")
  else
    erb :'/users/new', locals: { object: user }
  end
end

get '/users/:id/edit' do
  # Render edit user
end

post '/users/:id' do
  # Process edit user
end

get '/dashboard', requires_login: true do
  if user = current_user
    erb :'/dashboard', locals: { user: user, title: 'My Dashboard' }
  else
    redirect '/'
  end
end

get '/stalls' do
  stalls = Stall.all

  erb :'/stalls/index', locals: { stalls: stalls, title: 'All Stalls' }
end

get '/stalls/new' do
  stall = Stall.new

  erb :'/stalls/new', locals: { stall: stall, title: 'Create a Stall' }
end

get '/stalls/:id' do
  stall = Stall.get(params[:id])

  erb :'/stalls/show', locals: { stall: stall, title: "#{stall.title}" }
end

post '/stalls' do
  stall = Stall.create(params[:stall])

  if stall.saved?
    redirect("/stalls/#{stall.id}")
  else
    erb :'/stalls/new', locals: { stall: stall }
  end
end

get '/stalls/:id/edit' do
  stall = Stall.get(params[:id])

  erb :'/stalls/edit', locals: { stall: stall, title: "Edit #{stall.title}" }
end

put '/stalls/:id' do
  stall = Stall.get(params[:id])
  stall.attributes = params[:stall] if params[:stall]
  stall.save

  puts "Stall dirty?: #{stall.dirty?}"
  if stall.saved?
    PP.pp params[:stall]
    PP.pp stall.attributes
    puts "Stall saved?: #{stall.saved?}"
    redirect("/stalls/#{stall.id}")
  else
    erb :'/stalls/new', locals: { object: stall }
  end
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

helpers do
  def current_user
    # Return nil if no user is logged in
    return nil unless session.key?(:user_id)

    # If @current_user is undefined, define it by
    # fetching it from the database.
    @current_user ||= User.get(session[:user_id])
  end

  def user_signed_in?
    # A user is signed in if the current_user method
    # returns something other than nil
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

  def create_or_edit_text(object)
    object.new? ? 'Create' : 'Edit'
  end

  def title_text(page_title)
    return 'Air Stable' if page_title.nil?
    "#{page_title} | Air Stable"
  end

  def city_state_zip(stall)
    "#{stall.city}, #{stall.state} #{stall.zip}"
  end
end
