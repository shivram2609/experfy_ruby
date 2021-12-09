# frozen_string_literal: true

module T
  extend Dry::Transformer::Registry

  import Dry::Transformer::Coercions

  TRUE_VALUES = [true, 1, '1', 'on', 't', 'true', 'y', 'yes'].freeze
  FALSE_VALUES = [false, 0, '0', 'off', 'f', 'false', 'n', 'no', nil, 'nil', 'null'].freeze
  BOOLEAN_MAP = Hash[
    TRUE_VALUES.product([true]) + FALSE_VALUES.product([false])
  ].freeze

  def self.to_boolean(value)
    BOOLEAN_MAP.fetch(value)
  end
end

class TypeTransformation < Dry::Transformer::Pipe

  def initialize(params)
    @data = params[:data]
    @from = params[:from]
    @type = params[:to]
  end

  def call
    return unless @data || @from || @type

    case @type
    when "string"
      result = convert_data(:to_string)
    when "integer"
      result = convert_data(:to_integer)
    when "boolean"
      result = convert_data(:to_boolean)
    when "date"
      result = convert_data(:to_date)
    when "datetime"
      result = convert_data(:to_datetime)
    end


    result
  end

  def convert_data(function)
    T[function].(@data)
  end
end