require 'faraday'
require 'json'
require 'ostruct'
require 'csv'
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'xmlsimple'
require 'active_support'
require 'active_support/core_ext'
require 'sax-machine'
require 'net/http'
require 'jwt'

require_relative 'vibes/api_methods'
require_relative 'vibes/mobile_db'
require_relative 'vibes/platform_callbacks'
require_relative 'vibes/incentives'
require_relative 'vibes/events'
require_relative 'vibes/mobile_wallet'
require_relative 'vibes/custom_fields'
require_relative 'vibes/messages'
require_relative 'vibes/mo_message'
require_relative 'vibes/helpers/callbacks'
require_relative 'vibes/encoder'

include Helpers::Callbacks
##
# VibesApi API Class
#
# Used to interact with various Vibes API endpoints 
##
class VibesApi
  ##
  # Hostname for Platform API
  ##
  PLATFORM_HOSTNAME = 'https://www.vibescm.com'

  ##
  # Hostname for Vibes APPs API
  ##
  VIBES_APPS_HOSTNAME = 'https://api.vibesapps.com'
  
  ##
  # Hostname for Mobile DB API
  ##
  MOBILE_DB_HOSTNAME = 'https://public-api.vibescm.com'

  ##
  # Hash for carrier code to carrier name lookup
  ##
  carrier_file = File.exists?(File.expand_path("#{Dir.pwd}/config/carrier_codes.yml")) ?
                   File.expand_path("#{Dir.pwd}/config/carrier_codes.yml") : File.expand_path("../yaml/carrier_codes.yml", __FILE__)
  CARRIER_CODE_TO_NAME = YAML.load_file(carrier_file)

  ##
  # Array for Canada Area Codes lookup
  ##
  canada_area_codes_file = File.exists?(File.expand_path("#{Dir.pwd}/config/canada_area_codes.yml")) ?
    File.expand_path("#{Dir.pwd}/config/canada_area_codes.yml") : File.expand_path("../yaml/canada_area_codes.yml", __FILE__)
  CANADA_AREA_CODES = YAML.load_file(canada_area_codes_file)

  ##
  # Creates a connection object using username and password
  #
  # @param username [String] Username to use for Basic HTTP auth
  # @param password [String] Password to use for Basic HTTP auth
  #
  # @yieldparam conn [Faraday::Connection] Authenticated API connection
  #
  # @return [Nil] Nothing
  ##
  def self.api_connection(username = nil, password = nil)
    conn = Faraday.new ssl: { verify: false }
    conn.basic_auth(username, password) if username && password
    yield(conn)
  end

  ##
  # Perform GET request to the API endpoint and yield the response
  #
  # @param endpoint [String] Endpoint within the API to be called (ex: <tt>/api/method?params=1</tt>)
  # @param opts     [Hash]   Options/overrides for the API call
  #
  # @option opts [String] :host     URL of the host of the API (ex: <tt>http://apps.vibes.com/app</tt>)
  # @option opts [String] :user     Username to use for authentication (ex: <tt>MattJohnson</tt>)
  # @option opts [String] :password Password to use for authentication (ex: <tt>S3Cret!</tt>)
  #
  # @yieldparam response [Faraday::Response] Response from API GET request
  #
  # @return [Nil] Nothing
  ##
  def self.api_get(endpoint, opts = {})
    host     = opts[:host]     || PLATFORM_HOSTNAME
    user     = opts[:user]     || ENV['SPLAT_API_USER']
    password = opts[:password] || ENV['SPLAT_API_PASS']
    api_connection(user, password) do |conn|
      p endpoint if ENV['DEBUG_API_CALLS']
      response = conn.get URI.join(host, endpoint)
      p response if ENV['DEBUG_API_CALLS']
      yield response
    end
  end

  ##
  # Perform POST request to the API endpoint and yield the response
  #
  # @param endpoint [String] Endpoint within the API to be called (ex: <tt>/api/method?params=1</tt>)
  # @param body     [String] Body or payload of POST call (ex: <tt><request><mdn>312-123-1234</mdn></request></tt>)
  # @param opts     [Hash]   Options/overrides for the API call
  #
  # @option opts [String] :host         URL of the host of the API (ex: <tt>http://apps.vibes.com/app</tt>)
  # @option opts [String] :user         Username to use for authentication (ex: <tt>MattJohnson</tt>)
  # @option opts [String] :password     Password to use for authentication (ex: <tt>S3Cret!</tt>)
  # @option opts [String] :content_type Content type of the POST body (ex: <tt>application/json</tt>)
  #
  # @yieldparam response [Faraday::Response] Response from API POST request
  #
  # @return [Nil] Nothing
  ##
  def self.api_post(endpoint, body, opts = {})
    host         = opts[:host]         || PLATFORM_HOSTNAME
    user         = opts[:user]         || ENV['SPLAT_API_USER']
    password     = opts[:password]     || ENV['SPLAT_API_PASS']
    content_type = opts[:content_type] || 'application/xml'

    api_connection(user, password) do |conn|
      p endpoint if ENV['DEBUG_API_CALLS']
      p body if ENV['DEBUG_API_CALLS']
      response = conn.post do |req|
        req.headers['Content-Type'] = content_type
        req.url URI.join(host, endpoint)
        req.body = body
      end
      p response if ENV['DEBUG_API_CALLS']
      yield response
    end
  end

  ##
  # Perform DELETE request to the API endpoint and yield the response
  #
  # @param endpoint [String] Endpoint within the API to be called (ex: <tt>/api/method?params=1</tt>)
  # @param opts     [Hash]   Options/overrides for the API call
  #
  # @option opts [String] :host     URL of the host of the API (ex: <tt>http://apps.vibes.com/app</tt>)
  # @option opts [String] :user     Username to use for authentication (ex: <tt>MattJohnson</tt>)
  # @option opts [String] :password Password to use for authentication (ex: <tt>S3Cret!</tt>)
  #
  # @yieldparam response [Faraday::Response] Response from API DELETE request
  #
  # @return [Nil] Nothing
  ##
  def self.api_delete(endpoint, opts = {})
    host     = opts[:host]     || PLATFORM_HOSTNAME
    user     = opts[:user]     || ENV['SPLAT_API_USER']
    password = opts[:password] || ENV['SPLAT_API_PASS']
    api_connection(user, password) do |conn|
      p endpoint if ENV['DEBUG_API_CALLS']
      response = conn.delete URI.join(host, endpoint)
      p response if ENV['DEBUG_API_CALLS']
      yield response
    end
  end

  ##
  # Returns the URL of the Vibes Apps API Hostname
  #
  # @return [String] URL of Vibes Apps API Host
  ##
  def self.vibes_apps_hostname
    VIBES_APPS_HOSTNAME
  end

  ##
  # Returns the URL of the Vibes Catapult API Hostname
  #
  # @return [String] URL of Vibes Catapult API Host
  ##
  def self.platform_hostname
    PLATFORM_HOSTNAME
  end

  ##
  # Returns the URL of the Vibes Mobile DB API Hostname
  #
  # @return [String] URL of Vibes Mobile DB API Host
  ##
  def self.mobile_db_hostname
    MOBILE_DB_HOSTNAME
  end

  ##
  # Clean mobile-number of non-numerics
  #
  # @param mdn [String] Mobile phone number to clean
  #
  # @return [String] Mobile phone number stripped of all non-numeric characters
  ##
  def self.clean_mdn(mdn)
    mdn.gsub(/[^0-9]/i, '') if mdn
  end

  ##
  # Clean mobile-number of non-numerics and limit it to 10 characters
  #
  # @param mdn [String] Mobile phone number to clean
  #
  # @return [String] A 10-digit mobile phone number stripped of all non-numeric characters
  ##
  def self.clean_and_format_mdn(mdn)
    if mdn && mdn.length >= 10
      mdn.gsub(/[^0-9]/i, '').slice(-10, 10)
    else
      mdn
    end
  end

  ##
  #
  # @param mdn [String] Mobile phone number to validate
  #
  # @return [Boolean] true if MDN is valid, false if not
  ##
  def self.is_valid_mdn?(mdn)
    mdn.match(/^(1-?)?(\([2-9]\d{2}\)|[2-9]\d{2})-?[2-9]\d{2}-?\d{4}$/) ? true : false
  end

  ##
  # Enter a contest campaign.
  #
  # @param campaign_id [String] Campaign to enter
  # @param attributes  [Hash]   Hash of attributes about customer
  #   * <tt>mobile_phone</tt>
  #   * <tt>first_name</tt>
  #   * <tt>last_name</tt>
  #   * <tt>email</tt>
  #   * <tt>birthday</tt>
  #   * <tt>phone</tt>
  #   * <tt>city</tt>
  #   * <tt>state_code</tt>
  #   * <tt>postal_code</tt>
  # @param custom_attributes [Hash]   Hash of custom/non-catapult attributes about customer
  # @param short_code        [String] Short-code to send bounceback message
  #
  # @return [String] Text of response upon entry as defined in campaign + sms
  #   or text stating they've already entered, if applicable
  ##
  def self.enter_contest(campaign_id, attributes, custom_attributes, short_code)
    body =  "<?xml version='1.0' encoding='UTF-8'?><contest_entry_data>"
    body << "<mobile_phone>#{clean_mdn(attributes[:mobile_phone])}</mobile_phone>" if attributes[:mobile_phone]
    body << "<first_name>#{attributes[:first_name]}</first_name>"                  if attributes[:first_name]
    body << "<last_name>#{attributes[:last_name]}</last_name>"                     if attributes[:last_name]
    body << "<email>#{attributes[:email]}</email>"                                 if attributes[:email]
    body << "<birthday>#{attributes[:birthday]}</birthday>"                        if attributes[:birthday]
    body << "<phone>#{attributes[:phone]}</phone>"                                 if attributes[:phone]
    body << "<street_address>#{attributes[:street_address]}</street_address>"      if attributes[:street_address]
    body << "<city>#{attributes[:city]}</city>"                                    if attributes[:city]
    body << "<state_code>#{attributes[:state_code]}</state_code>"                  if attributes[:state_code]
    body << "<postal_code>#{attributes[:postal_code]}</postal_code>"               if attributes[:postal_code]

    if custom_attributes
      body << "<custom_attributes>"
      custom_attributes.each_pair { |key, value| body << "<#{key}>#{value}</#{key}>" }
      body << "</custom_attributes>"
    end

    body << "</contest_entry_data>"

    api_post "/api/amoe/enter.xml?id=#{campaign_id}", body do |response|
      response_xml = XmlSimple.xml_in(response.body)
      if response_xml.key?('bad-request')
        result = response_xml['bad-request'].fetch(0, 'bad-request')
      elsif response_xml.key?('ok')
        result = response_xml['ok'].fetch(0, 'ok')
      else
        result = response.body
      end
      if short_code && attributes[:mobile_phone]
        send_message(attributes[:mobile_phone], result, short_code)
      end
      return result
    end
  end

  ##
  # Enter a contest campaign by keyword
  #
  # @param keyword [String] Keyword for a campaign
  # @param attributes  [Hash]   Hash of attributes about customer
  #   * <tt>mobile_phone</tt>
  #   * <tt>first_name</tt>
  #   * <tt>last_name</tt>
  #   * <tt>email</tt>
  #   * <tt>birthday</tt>
  #   * <tt>phone</tt>
  #   * <tt>city</tt>
  #   * <tt>state_code</tt>
  #   * <tt>postal_code</tt>
  # @param custom_attributes [Hash]   Hash of custom/non-catapult attributes about customer
  # @param short_code        [String] Short-code to send bounceback message
  # @param send_message [Boolean] Whether to send a response message after entering contest
  #
  # @return [String] Text of response upon entry as defined in campaign + sms
  #   or text stating they've already entered, if applicable
  ##
  def self.enter_contest_by_keyword(keyword, attributes, custom_attributes, short_code, send_message = false)
    body =  "<?xml version='1.0' encoding='UTF-8'?><contest_entry_data>"
    body << "<mobile_phone>#{clean_mdn(attributes[:mobile_phone])}</mobile_phone>" if attributes[:mobile_phone]
    body << "<first_name>#{attributes[:first_name]}</first_name>"                  if attributes[:first_name]
    body << "<last_name>#{attributes[:last_name]}</last_name>"                     if attributes[:last_name]
    body << "<email>#{attributes[:email]}</email>"                                 if attributes[:email]
    body << "<birthday>#{attributes[:birthday]}</birthday>"                        if attributes[:birthday]
    body << "<phone>#{attributes[:phone]}</phone>"                                 if attributes[:phone]
    body << "<street_address>#{attributes[:street_address]}</street_address>"      if attributes[:street_address]
    body << "<city>#{attributes[:city]}</city>"                                    if attributes[:city]
    body << "<state_code>#{attributes[:state_code]}</state_code>"                  if attributes[:state_code]
    body << "<postal_code>#{attributes[:postal_code]}</postal_code>"               if attributes[:postal_code]

    if custom_attributes
      body << "<custom_attributes>"
      custom_attributes.each_pair { |key, value| body << "<#{key}>#{value}</#{key}>" }
      body << "</custom_attributes>"
    end

    body << "</contest_entry_data>"

    api_post "/api/amoe/enter.xml?short_code=#{short_code}&keyword=#{keyword}", body do |response|
      response_xml = XmlSimple.xml_in(response.body)
      if response_xml.key?('bad-request')
        result = response_xml['bad-request'].fetch(0, 'bad-request')
      elsif response_xml.key?('ok')
        result = response_xml['ok'].fetch(0, 'ok')
      else
        result = response.body
      end
      if short_code && attributes[:mobile_phone] && send_message
        send_message(attributes[:mobile_phone], result, short_code)
      end
      return result
    end
  end

  ##
  # Look up Carrier for MDN
  #
  # @param mdn [String] Mobile phone number to do lookup for
  #
  # @return [Integer] Carrier code (or 0, indicating not found)
  #
  # <b>Carrier Codes</b>
  #   101 - U.S. Cellular
  #   102 - Verizon Wireless
  #   103 - Sprint Nextel(CDMA)
  #   104 - AT&T
  #   105 - T-Mobile
  #
  #   Full list of codes: https://developer.vibes.com/display/CONNECTV3/Appendix+-+Carrier+Codes
  ##
  def self.get_carrier_code(mdn)
    api_get "/MessageApi/mdns/#{clean_mdn(mdn)}", host: VIBES_APPS_HOSTNAME do |response|
      carrier_code = 0
      Nokogiri::XML(response.body).xpath('//mdn').each do |record|
        carrier_code = record.at('@carrier').text.to_i
      end
      return carrier_code
    end
  end

  ##
  # Look up Carrier Name for MDN
  #
  # @param mdn [String] Mobile phone number to do lookup for
  #
  # @return [String] Carrier name from hash CARRIER_CODE_TO_NAME (or nil, indicating not found)
  #
  ##
  def self.get_carrier_name(mdn)
    CARRIER_CODE_TO_NAME.fetch(get_carrier_code(mdn), nil)
  end

 ##
  # Look up Carrier Code by Carrier Name
  #
  # @param carrier_name [String] Name of carrier from CARRIER_CODE_TO_NAME
  #
  # @return [Integer] Carrier code (or 0, indicating not found)
  #
  ##
  def self.get_carrier_code_by_name(carrier_name)
    CARRIER_CODE_TO_NAME.key(carrier_name) || 0
  end

  ##
  # Look up Canada Area Code for MDN
  #
  # @param mdn [String] Mobile phone number to do lookup for
  #
  # @return [Boolean] Area Code found
  #
  ##
  def self.is_canadian_number?(mdn)
    mdn = clean_mdn(mdn)
    mdn = mdn.last(10) if (mdn.length == 11)
    CANADA_AREA_CODES.include? mdn[0...3]
  end
 
  ##
  # Casts a vote for the specified vote option on the specified vote campaign.
  #
  # @param user_id [String] User mdn or IP address
  # @param vote_option  [String] Keyword associated with the option to cast vote for
  # @param campaign_id  [String] Catapult Vote campaign id
  #
  # @return [String] Response body from Catapult (usually in XML)
  ##
  def self.vote(user_id, vote_option, campaign_id)
    body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><vote>"
    body << "<user-id>#{user_id}</user-id>"
    body << "<vote-option>#{vote_option}</vote-option>"
    body << "</vote>"

    api_post "/api/vote_campaigns/#{campaign_id}/votes.xml", body do |response|
      return response.body
    end
  end
  
  
  ##
  # Simple encryption method (to be used in conjunction with @decrypt_with_password)
  #
  # @param plaintext The plaintext to be encrypted
  # @param password THe password to decrypt string with
  #
  # @return [String] Encrypted text of plaintext
  ##
  def self.encrypt_with_password(plaintext, password)
    salt  = "msgtoolbox"
    key   = ActiveSupport::KeyGenerator.new(password).generate_key(salt)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    crypt.encrypt_and_sign(plaintext)
  end

  ##
  # Simple decryption method (to be used in conjunction with @encrypt_with_password)
  #
  # @param cipher Encrypted text to be decrypted
  # @param password The password to decrypt string with
  #
  # @return [String] Decrypted text of cipher
  ##
  def self.decrypt_with_password(cipher, password)
    salt  = "msgtoolbox"
    key   = ActiveSupport::KeyGenerator.new(password).generate_key(salt)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    crypt.decrypt_and_verify(cipher)
  end

end
