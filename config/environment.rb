# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require(:default)                   # load all the default gems
Bundler.require(Sinatra::Base.environment)  # load all the environment specific gems
ENV['REDIS_URL'] ||= 'redis://localhost:6379' # Set ENV variable for redis instance
RedisURI = URI.parse(ENV["REDIS_URL"])

REDIS = Redis.new(host: RedisURI.host, port: RedisURI.port, password: RedisURI.password) # Initialize new redis instance

# Read JSON sample which represents schema in redis
file = File.open "./samples/project_sample.json"
data = JSON.load file

# Store JSON to Redis
REDIS.set("project_transformation_schema", data.to_json)