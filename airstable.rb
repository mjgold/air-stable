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
    erb :'/users/new', locals: { user: user, title: 'Create an Account' }
  end
end

get '/users/:id/edit' do
  # Render edit user
end

post '/users/:id' do
  # Process edit user
end

get '/dashboard' do
  erb :'/dashboard', locals: { user: current_user, title: 'My Dashboard' }
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
    erb :'/stalls/new', locals: { stall: stall, title: 'Create a Stall' }
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
  rental_request = RentalRequest.new

  erb :'/stalls/rental_requests/new',
      locals: {
        title: "Request #{stall.title}",
        stall: stall,
        rental_request: rental_request
              }
end

post '/stalls/:id/rental_requests' do
  PP.pp params
  stall = Stall.get(params[:id])

  rental_request = RentalRequest.new(params[:rental_request])
  rental_request.status = :pending
  rental_request.stall = stall
  rental_request.requester = current_user
  rental_request.save

  if rental_request.saved?
    set_flash(:notice, 'Rental request created!')
    redirect '/dashboard'
  else
    PP.pp rental_request
    PP.pp rental_request.errors
    erb :"/stalls/rental_requests/new",
        locals: {
          title: "Request #{stall.title}",
          stall: stall,
          rental_request: rental_request
                }
  end
end

put '/stalls/:stall_id/rental_requests/:rental_request_id/edit' do
  rental_request = RentalRequest.get(params[:rental_request_id])
  rental_request.status = params['rental_request_response'].to_sym
  rental_request.save

  if rental_request.saved?
    set_flash(:notice, "Request to #{rental_request.stall.title} #{rental_request.status}!")
    redirect '/dashboard'
  else
    fail("Could not save response to #{rental_request.stall.title}!")
  end
end

delete '/stalls/:id/rental_requests/:id' do
  # delete a rental request
end

helpers do
  def get_flash(key)
    session[:flash].delete(key) if session[:flash]
  end

  def set_flash(key, value)
    session[:flash] ||= {}
    session[:flash][key] = value
  end

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
    return if user_signed_in?
    set_flash(:notice, 'Please login to access that page.')
    redirect '/'
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

  def rental_request_stall_and_date(rental_request)
    "#{rental_request.stall.title} - #{rental_request.date}"
  end

  def username_and_email(user)
    "<a href='mailto: #{user.email}'>#{user.username} (#{user.email})</a>"
  end
end
