require 'sinatra'
require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, Sinatra::Application.environment)

Dotenv.load('.env') if File.exist?('.env')

unless ENV.key?('DATABASE_URL')
  puts "ENV['DATABASE_URL'] is undefined.  Make sure your .env file is correct."
  puts 'To use the example file env.example, run'
  puts ''
  puts '  rake setup:dotenv'
  puts ''
  exit 1
end

DataMapper.setup(:default, ENV['DATABASE_URL'])
DataMapper::Logger.new($stdout, :debug) if Sinatra::Application.development?
