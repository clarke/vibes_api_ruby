module Vibes

  class Messages
    extend ApiMethods

    ##
    # Get info on a Message from Catapult
    #
    # @param message_id [String] The GUID string that is returned from the MessageAPI on send (or delivery receipt)
    #
    # @return [Hash] Message information
    ##
    def self.get_message(message_id)
      get("/MessageApi/mt/messages/#{message_id}")
    end

    ##
    # Get a summary of all of the responses received from for a particular MT message at the various stages of processing.
    #
    # @param message_id [String] The GUID string that is returned from the MessageAPI on send (or delivery receipt)
    #
    # @return [Hash] Message Response Information
    def self.get_responses(message_id)
      get("/MessageApi/mt/messages/#{message_id}/responses")
    end

    ##
    # Send an SMS via Core MessageAPI
    #
    # @param mdn        [String] Mobile phone number to send SMS to
    # @param text       [String] Content of SMS
    # @param short_code [String] Short code to use when sending SMS
    # @param options    [Hash] Hash of optional parameters
    # @option options   [Integer] :carrier_code The carrier network the Mobile Phone number is on. Not required, but saves us money.
    # @option options   [String] :company_key If carrier_code is not supplied, this is used to find recipient in Mobile DB and retrieve Carrier Code for MDN. Not required, but saves us money!
    # @option options   [Integer] :company_id The Company Id this message is being sent for
    # @option options   [String] :submitter_message_id A client definable identifier for a message (aka "client_message_id" )
    # @option options   [Boolean] :alternate_delivery Retry on long code if short code fails. Needs special short code setup.
    # @option options   [String] :callback_url Defines the URL that all receipt notifications should be delivered to
    # @option options   [String] :receipt_option Indicates the types of notifications that should be send to *callback_url* Defaults to 'ALL' if not specified.
    # @option options   [String] :split_long_message Boolean flag, used to request that any messages greater than 160 characters be split into multiple messages.
    #   * <tt>NONE</tt>
    #   * <tt>ERROR</tt>
    #   * <tt>ALL</tt>
    #   * <tt>SMSC_ERROR</tt>
    #   * <tt>SMSC_ALL</tt>
    # @return [String] Response body from MessageAPI (usually in XML)
    ##
    def self.submit(text, mdn, short_code, options = {})
      if !options[:carrier_code] && options[:company_key]
        person = MobileDb.find_person(options[:company_key], mdn)
        options[:carrier_code] = person[0]['mobile_phone']['carrier_code'] if person && person[0]
      end
      body = "<?xml version='1.0' encoding='UTF-8'?>"
      body << "<mtMessage #{"submitterMessageId='#{options[:submitter_message_id]}'" if options[:submitter_message_id]} #{"alternateDelivery='true'" if options[:alternate_delivery]} #{"splitLongMessage='true'" if options[:split_long_message]}>"
      body << "<destination address='#{VibesApi.clean_mdn(mdn)}' #{ "carrier='#{options[:carrier_code]}'" if options[:carrier_code] }/>"
      body << "<source address='#{short_code}' type='SC' />"
      body << "<text><![CDATA[#{text}]]></text>"
      body << "<companyId>#{options[:company_id].to_i}</companyId>" if options[:company_id]
      body << "<receiptOption callbackUrl='#{options[:callback_url]}'>#{options[:receipt_option] || 'ALL'}</receiptOption>" if options[:callback_url]
      body << "</mtMessage>"
      post("/MessageApi/mt/messages", body)
    end

    ##
    # Look up Carrier for MDN
    #
    # @param mdn [String] Mobile phone number to do lookup for
    #
    # @return [Integer] Carrier code (or 0, indicating not found)
    #
    # <b>Major Carrier Codes</b>
    #   101 - U.S. Cellular
    #   102 - Verizon Wireless
    #   103 - Sprint Nextel(CDMA)
    #   104 - AT&T
    #   105 - T-Mobile
    #
    #   Full list of codes: https://developer.vibes.com/display/CONNECTV3/Appendix+-+Carrier+Codes
    ##
    def self.get_carrier_code(mdn)
      clean_mdn = VibesApi.clean_mdn(mdn)
      response = get("/MessageApi/mdns/#{clean_mdn}")
      response["carrier"].to_i || 0
    end

    ##
    # Look up Carrier for MDN, raise exception if carrier not provisioned
    #
    # @param mdn [String] Mobile phone number to do lookup for
    # @param short_code [String] Optional short code to check if carrier is provisioned
    #
    # @return [Integer] Carrier code (or 0, indicating not found)
    #
    # <b>Major Carrier Codes</b>
    #   101 - U.S. Cellular
    #   102 - Verizon Wireless
    #   103 - Sprint Nextel(CDMA)
    #   104 - AT&T
    #   105 - T-Mobile
    #
    #   Full list of codes: https://developer.vibes.com/display/CONNECTV3/Appendix+-+Carrier+Codes
    ##
    def self.get_carrier_code!(mdn, short_code = nil)
      clean_mdn = VibesApi.clean_mdn(mdn)
      endpoint = "/MessageApi/mdns/#{clean_mdn}"
      endpoint += "?shortcode=#{short_code.try(:strip)}" if short_code.present?
      response = get(endpoint)
      if response["carrier"].present? and response["provisioned"] == "false"
        fail "Carrier #{response["carrier"]} not provisioned in shortcode #{short_code}"
      end
      response["carrier"].to_i || 0
    end

    protected

    def self.hostname
      ENV['VIBES_MESSAGE_API_URL'] || 'https://messageapi.vibesapps.com'
    end

    def self.username
      ENV['VIBES_MESSAGE_API_USERNAME'] || ENV['SPLAT_API_USER']
    end

    def self.password
      ENV['VIBES_MESSAGE_API_PASSWORD'] || ENV['SPLAT_API_PASS']
    end

    def self.content_type
      'application/xml'
    end

    def self.parse(response)
      puts response if ENV['DEBUG_API_CALLS']
      response_body = response.respond_to?(:body) ? response.body : response
      XmlSimple.xml_in(response_body)
    end

  end
end

