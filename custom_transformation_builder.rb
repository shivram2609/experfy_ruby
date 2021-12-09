# frozen_string_literal: true

require 'dry/transformer/all'
require "dry/inflector"

Inflector = Dry::Inflector.new

module Functions
  extend Dry::Transformer::Registry

  import Dry::Transformer::Coercions
  import Dry::Transformer::ArrayTransformations
  import Dry::Transformer::HashTransformations
  import Dry::Transformer::ClassTransformations
  import Dry::Transformer::ProcTransformations
  import Dry::Transformer::Conditional
  import Dry::Transformer::Recursion

  import :underscore, from: Inflector

  def self.upcase(payload, key)
    payload[key.to_sym] = payload[key.to_sym].upcase
    payload
  end

  def self.downcase(payload, key)
    payload[key.to_sym] = payload[key.to_sym].downcase
    payload
  end
end

class CustomTransformationBuilder < Dry::Transformer::Pipe
  include Functions

  def t(*args)
    Functions[*args]
  end

  def transform(schema, payload)
    transformation = t(:symbolize_keys)

    schema.each do |attr_name, attr_value|
      attr_value.each do |f|
        case f[:function]
        when "rename_keys"
          function = t(f[:function].to_sym, { f[:args][:old_key].to_sym => f[:args][:new_key].to_sym })
        when "reject_keys"
          function = t(f[:function].to_sym, f[:args][:keys].map{|f| f.to_sym})
        when "nest"
          function = t(f[:function].to_sym, f[:args][:name].to_sym, f[:args][:keys].map{|f| f.to_sym})
        when "unwrap"
          # TODO: Find a way to unwrap nested objects. This case will handle only one level deep objects

          function = t(f[:function].to_sym, f[:args][:name].to_sym, f[:args][:keys].map{|f| f.to_sym})
        when "uppcase_value"
          function = t(:upcase, f[:key])
        when "downcase_value"
          function = t(:downcase, f[:key])
        when "symbolize_keys"
          function = t(f[:function].to_sym)
        end
        transformation = transformation >> function unless function.nil?
      end
    end

    result = transformation[payload]

    result
  end
end