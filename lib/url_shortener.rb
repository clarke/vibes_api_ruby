class UrlShortener
  extend ApiMethods

  ##
  # Shorten a URL
  #
  # @param url      [String] URL to be shortened
  # @param options  [Hash]   Options/overrides for the API call
  #
  # @option opts [Integer] :accountId The unique identifier for the client account asscoiated with this URL
  # @option opts [Integer] :campaignId The unique identifier for the campaign associated with this URL
  # @option opts [Integer] :recipientId Numeric Unique identifier for the recipient of the message with the short URL
  # @option opts [String] :application The application who is requesting shorten urls (defaults to 'MSG')
  # @option opts [String] :custom1 Custom parameter assigned to the short URL by the client application.
  # @option opts [String] :custom2 Custom parameter assigned to the short URL by the client application.
  # @option opts [String] :custom3 Custom parameter assigned to the short URL by the client application.
  # @option opts [String] :domain The short domain URL. If not provided, the default http://vbs.cm is used
  # @option opts [String] :mdn The Mobile phone number to include in shortening (shortcut for recipientAltKey)
  # @option opts [String] :messageTemplateId String Identifier for the message which will include the short URL. (defaults to '1')
  # @option opts [String] :recipientAltKey Unique identifier for the recipient of the message with the short URL (usually MDN)
  # @option opts [String] :shortcode The shortcode assigned to the campaign
  # @option opts [String] :urlGroupKey The group key for the longUrl on which stats are expected.
  #
  # @return [String] Shortened url
  ##
  def self.shorten(url, options={})
    body = { url: url }
    body.merge!(options)
    body[:messageTemplateId] ||= '1'
    body[:application]       ||= 'MSG'
    body[:recipientAltKey]   ||= body[:mdn].to_s
    post '/UrlShortener/api/shorten', body.to_json do |response|
      response.body # Just return response without JSON parsing
    end
  end

  ##
  # Get info about a shortened URL
  #
  # @param shortkey [String] The key in the shortened URL
  #
  # @return [Hash] Return all parameters and information around a shortened URL
  #   * <tt>url</tt>
  #   * <tt>shortUrl</tt>
  #   * <tt>accountId</tt>
  #   * <tt>campaignId</tt>
  #   * <tt>shortcode</tt>
  #   * <tt>messageTemplateId</tt>
  #   * <tt>recipientId</tt>
  #   * <tt>recipientAltKey</tt>
  #   * <tt>custom1</tt>
  #   * <tt>custom2</tt>
  #   * <tt>custom3</tt>
  #   * <tt>application</tt>
  #   * <tt>urlGroupKey</tt>
  #
  ##
  def self.get_info(shortkey)
    get "/UrlShortener/api/shortkey/#{shortkey}"
  end

  protected

    def self.hostname
      ENV['VIBES_TRUST_API_URL'] || 'https://externalapps.vibesapps.com'
    end

    def self.username
      ENV['VIBES_TRUST_API_USERNAME'] || ENV['SHORT_USER']
    end

    def self.password
      ENV['VIBES_TRUST_API_PASSWORD'] || ENV['SHORT_PASS']
    end
end