### More elegant way to do authorization?

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

# Before filter that redirects user to login page unless user is logged in
# or page does not require login

### This eliminates the possibility of a 404 page. Better way to redirect only
### for valid routes?
before do
  request_path = request.path_info.split('/')

  if (['sessions', nil].include? request_path[1]) ||
     (request_path[1] == 'users' && request_path[2] == 'new')
    pass
  else
    authorize!
  end
end

def get_flash(key)
  session[:flash].delete(key) if session[:flash]
end

def set_flash(key, value)
  session[:flash] ||= {}
  session[:flash][key] = value
end

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
    redirect('/dashboard')
  end
end

get '/users/new' do
  user = User.new
  erb :'/users/new', locals: { user: user, title: 'Create an Account' }
end

post '/users/new' do
  user = User.create(params[:user])

  if user.saved?
    sign_in!(user)
    redirect('/dashboard')
  else
    erb :'/users/new', locals: { user: user }
  end
end

get '/users/:id/edit' do
  # Render edit user
end

post '/users/:id' do
  # Process edit user
end

get '/dashboard' do
  user = current_user
  if user
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
    puts "Stall saved?: #{stall.saved?}"
    redirect("/stalls/#{stall.id}")
  else
    erb :'/stalls/new', locals: { stall: stall }
  end
end

delete '/stalls/:id' do
  # delete a stall (cancel any pending or accepted requests)
end

get '/stalls/:id/rental_requests/new' do
  stall = Stall.get(params[:id])

  erb :'/stalls/rental_requests/new', \
      locals: { title: "Request #{stall.title}", stall: stall }
end

post '/stalls/:id/rental_requests' do
  # create a rental request
end

put '/stalls/:id/rental_requests/:id/edit' do
  # approve or reject a request
end

delete '/stalls/:id/rental_requests/:id' do
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

  def authorize!
    if !user_signed_in?
      set_flash(:notice, 'Please login to access that page.')
      redirect '/'
    end
  end

  def create_or_edit_text(object)
    object.new? ? 'Create' : 'Edit'
  end

  def title_text(page_title)
    return 'Air Stable' if page_title.nil?
    "#{page_title} | Air Stable"
  end

  def stall_info(stall)
    <<-STALL
    <h2>#{stall.title}</h2>

    <i>#{city_state_zip(stall)}</i> - hosted by #{stall.owner.username}
    STALL
  end

  def city_state_zip(stall)
    "#{stall.city}, #{stall.state} #{stall.zip}"
  end
end
