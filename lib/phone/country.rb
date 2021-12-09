# frozen_string_literal: true

require "yaml"

class Country < Struct.new(:name, :country_code, :char_2_code, :char_3_code, :area_code)
  module All
    attr_accessor :all
  end
  extend All

  def all
    self.class.all
  end

  def self.load
    return self.all if !self.all.nil? && !self.all.empty?

    data_file = File.join("..","..","data", "countries.yml")
    data_path = File.expand_path(data_file, File.dirname(__FILE__))

    self.all = {}
    YAML.load(File.read(data_path)).each_pair do |key, c|
      self.all[key] = Country.new(
        c[:name],
        c[:country_code],
        c[:char_2_code],
        c[:char_3_code],
        c.fetch(:area_code, "[0-9][0-9][0-9]").freeze
      )
    end

    self.all
  end

  def self.find_by_country_name(name)
    self.all[name]
  end

  def country_code_regexp
    @country_code_regexp ||= Regexp.new("^[+]#{country_code}")
  end
end