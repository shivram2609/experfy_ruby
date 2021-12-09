# frozen_string_literal: true

require './type_transformation'
require './custom_transformation_builder'
require './phone'

class App < Sinatra::Base
  get '/type-conversion' do
    result = TypeTransformation.new(params).call

    Result.new(result).response
  end

  post '/custom-transformation' do
    return unless request.body
    request.body.rewind
    begin
      parse_json = JSON.parse(request.body.read, symbolize_names: true)
      data = parse_json[:params]
      type = parse_json[:type]
      schema = JSON.parse(REDIS.get(type), symbolize_names: true) if type

      result = CustomTransformationBuilder.new.transform(schema, data)

      Result.new(result).response
    rescue JSON::ParserError, TypeError => e
      message = "Not a string, or not a valid JSON"
      raise JSON::ParserError.new(message)
    end
  end

  get '/phone' do
    result = Phone.new(params).call

    Result.new(result).response
  end
end

class Result
  attr_reader :data
  
  def initialize(data)
    @data = data  
  end
  
  def response
    { 
      data: data, 
      status: 200 
    }.to_json
  end
end