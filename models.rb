require 'rubygems'
require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite:airstable.db')

# A User can be an owner or requester
class User
  include DataMapper::Resource

  property :id, Serial
  property :nickname, String, required: true
  property :email, String, required: true, unique: true
  property :password, String, required: true

  has n, :stalls
  has n, :rental_requests
end

# Represents a horse stall that can be requested
class Stall
  include DataMapper::Resource

  property :id, Serial
  property :title, String, required: true, unique: true
  property :description, Text, required: true
  property :city, String, required: true
  property :state, String, required: true
  property :zip, String, required: true

  belongs_to :owner, 'User', required: true
  has n, :rental_request
end

# Represents a user's request of an owner's stall
class RentalRequest
  include DataMapper::Resource

  property :id, Serial
  property :status, Enum[:accepted, :pending, :declined], required: true
  property :message, Text
  property :date, DateTime

  belongs_to :owner, 'User', required: true
  belongs_to :requester, 'User', required: true
end

DataMapper.finalize
DataMapper.auto_upgrade!
