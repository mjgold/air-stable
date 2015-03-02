require 'rubygems'
require 'data_mapper'

# A User can be an owner or requester
class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String, required: true
  property :email, String,
           format: :email_address,
           required: true,
           unique: true,
           messages: {
             format: 'You must enter a valid email address.'
           }

  property :password, BCryptHash,
           required: true

  attr_accessor :password_confirmation
  validates_confirmation_of :password
  validates_length_of :password, min: 6
  validates_length_of :password_confirmation, min: 6

  has n, :stalls, child_key: [:owner_id]
  has n, :rental_requests, child_key: [:requester_id]

  def valid_password?(unhashed_password)
    password == unhashed_password
  end

  def self.find_by_credentials(email, password)
    user = User.first(email: email) || User.new(email: email)
    unless user.valid_password?(password)
      user.errors.add(:general, "We couldn't find an account with that email \
        and password. Can you double-check them?")
    end
    user
  end
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

  belongs_to :owner, 'User',
             child_key: [:owner_id],
             required: true
  has n, :rental_requests
end

# Represents a user's request of an owner's stall
class RentalRequest
  include DataMapper::Resource

  property :id, Serial
  property :message, Text
  property :date, Date
  property :status, Enum[:accepted, :pending, :declined], required: true

  belongs_to :stall, 'Stall',
             required: true

  belongs_to :requester, 'User',
             child_key: [:requester_id],
             required: true
end

DataMapper.finalize
DataMapper.auto_upgrade!
