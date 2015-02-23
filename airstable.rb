require 'sinatra'
require 'data_mapper'

get '/' do
  erb :index, locals: { title: 'Air Stable | Home' }
end

post '/' do
  # check login credentials
  # send to user home page if valid
  # else send back to login with error
end

get 'users/new' do
  # registration page
end

post 'users/new' do
  # create a new user
end

get 'home/:id' do
  # display dashboard for logged in user
end

get 'stall/:id' do
  # get a specific stall page
end

get 'stalls' do
  # display stall search page
end

get 'stalls/new' do
  # create a stall page
end

post 'stalls/new' do
  # create a stall
end

get 'stalls/:id/edit' do
  # edit stall page
end

put 'stalls/:id' do
  # edit stall page
end

get 'requests/new' do
  # request a stall page
end

post 'requests/new' do
  # create a rental request
end

post 'requests/:id/edit' do
  # approve or reject a request
end

delete 'stall/:id' do
  # delete a stall (cancel any pending or accepted requests)
end

delete 'request/:id' do
  # delete a rental request
end
