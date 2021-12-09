# frozen_string_literal: true

require './lib/phone/country'

class Phone
  NUMBER = '([0-9]{1,8})$'  
  DEFAULT_AREA_CODE = '[0-9][0-9][0-9]'
  DEFAULT_COUNTRY_CODE = "1"
  N1_LENGTH = 3
  NAMED_FORMATS = {
    :default => "+%c%a%n",
    :europe => "+%c (0) %a %f %l",
    :us => "(%a) %f-%l"
  }
  
  attr_accessor :country_code, :area_code, :number

	def initialize(params)
    @phone = params[:phone]
    @country = params[:country]
    @format = params[:format]
  end

  def call(options = {})
    return unless @phone || @country

    Country.load
    string = normalize(@phone)

    options[:country_code] ||= DEFAULT_COUNTRY_CODE
    options[:area_code] ||= DEFAULT_AREA_CODE

    parts = split_to_parts(string, @country, options)

    if @format
      output = NAMED_FORMATS[@format.to_sym]
    else
      output = NAMED_FORMATS[:us]
    end

    result = format_number(output, parts)

    return result
  end

  def split_to_parts(string, country_name, options = {})
    country = Country.find_by_country_name(country_name)

    if country
      options[:country_code] = country.country_code
      string = string.gsub(country.country_code_regexp, "0")
    end

    format = detect_format(string, country)
    return nil if format.nil?

    # Override the format IF overriding options are not present
    format = :short if options[:area_code].nil?
    parts = string.match formats(country)[format]

    return nil if parts.nil?

    case format
      when :short
        {
          :number => parts[2],
          :area_code => parts[1],
          :country_code => options[:country_code]
        }
      when :really_short
        {
          :number => parts[1],
          :area_code => options[:area_code],
          :country_code => country[:country_code]
        }
    end

  end

  def detect_format(string_with_number, country)
    arr = []
    formats(country).each_pair do |format, regexp|
      arr << format if string_with_number =~ regexp
    end

    if arr.length > 1
      return :really_short
    end
    arr.first
  end

  def formats(country)
    area_code_regexp = country.area_code || DEFAULT_AREA_CODE

    {
      # 047451588, 013668734
      :short => Regexp.new('^0?(' + area_code_regexp + ')' + NUMBER),
      # 451588
      :really_short => Regexp.new('^' + NUMBER)
    } 
  end


  def normalize(string_with_number)
    string_with_number.gsub("(0)", "").gsub(/[^0-9+]/, '').gsub(/^00/, '+').gsub(/^\+00/, '+').gsub(/^\+0/, '+')
  end

  def format_number(fmt, parts)
    result = fmt.gsub("%c", parts[:country_code] || "").
             gsub("%a", parts[:area_code] || "").
             gsub("%A", area_code_long(parts[:area_code]) || "").           
             gsub("%n", parts[:number] || "").
             gsub("%f", number1(parts[:number]) || "").
             gsub("%l", number2(parts[:number]) || "")
    return result
  end



  # format area_code with trailing zero (e.g. 91 as 091)
  # format area_code with trailing zero (e.g. 91 as 091)
  def area_code_long(area_code)
    "0" + area_code if area_code
  end

  # first n characters of :number
  def number1(number)
    number[0...N1_LENGTH]
  end

  # everything left from number after the first n characters (see number1)
  def number2(number)
    n2_length = number.size - N1_LENGTH
    number[-n2_length, n2_length]
  end
end