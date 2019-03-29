module ApiMethods

  # Default hostname
  def hostname
    ENV['VIBES_PUBLIC_API_URL'] || 'https://public-api.vibescm.com'
  end

  # Default username
  def username
    ENV['VIBES_PUBLIC_API_USERNAME'] || ENV['SPLAT_API_USER']
  end

  # Default password
  def password
    ENV['VIBES_PUBLIC_API_PASSWORD'] || ENV['SPLAT_API_PASS']
  end

  # Default content-type
  def content_type
    'application/json'
  end

  # Default proxy
  def proxy
    nil
  end

  # Default API Version of the Vibes Public API
  def api_version
    ENV['VIBES_PUBLIC_API_VERSION'] || "1"
  end

  # Default parse for response
  def parse(response)
    puts response if ENV['DEBUG_API_CALLS']
    response_body = response.respond_to?(:body) ? response.body : response
    if response_body.empty?
      {"success" => [{"status_code" => response.status, "status_message" => response.reason_phrase, "message" => "Request was successful. No body returned" }]}
    else
      JSON.parse(response_body)
    end
  end

  ##
  # Utility method that applies defaults to an options hash
  #
  # @param opts [Hash] Options hash for an API method
  #
  # @return [Hash] The newly modified options hash
  #
  # @note This method modifies the original Hash given
  ##
  def apply_defaults!(opts)
    opts[:host]          ||= hostname
    opts[:user]          ||= username
    opts[:password]      ||= password
    opts[:content_type]  ||= content_type
    opts[:proxy]         ||= proxy
    opts[:x_api_version] ||= api_version
    opts
  end

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
  def api_connection(username, password, proxy=nil)
    fail 'Vibes API: Username or Password missing. Check your environment variables.' if username.nil? || password.nil?
    if proxy
      conn = Faraday.new ssl: { verify: false }, proxy: proxy
    else
      conn = Faraday.new ssl: { verify: false }
    end
    conn.basic_auth(username, password)
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
  def get(endpoint, opts = {})
    apply_defaults!(opts)
    puts
    puts endpoint if ENV['DEBUG_API_CALLS']
    api_connection(opts[:user], opts[:password], opts[:proxy]) do |conn|
      response = conn.get do |req|
        req.headers['Content-Type'] = opts[:content_type]
        req.headers['X-API-Version'] = opts[:x_api_version]
        req.url URI.join(opts[:host], endpoint)
      end
      if block_given?
        yield response
      else
        return parse(response)
      end
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
  def post(endpoint, body, opts = {})
    apply_defaults!(opts)
    puts endpoint + "\n" + body if ENV['DEBUG_API_CALLS']
    api_connection(opts[:user], opts[:password], opts[:proxy]) do |conn|
      response = conn.post do |req|
        req.headers['Content-Type'] = opts[:content_type]
        req.headers['X-API-Version'] = opts[:x_api_version]
        req.url URI.join(opts[:host], endpoint)
        req.body = body
      end
      if block_given?
        yield response
      else
        return parse(response.body)
      end
    end
  end

  ##
  # Perform PUT request to the API endpoint and yield the response
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
  def put(endpoint, body, opts = {})
    apply_defaults!(opts)
    puts endpoint + "\n" + body if ENV['DEBUG_API_CALLS']
    api_connection(opts[:user], opts[:password], opts[:proxy]) do |conn|
      response = conn.put do |req|
        req.headers['Content-Type'] = opts[:content_type]
        req.headers['X-API-Version'] = opts[:x_api_version]
        req.url URI.join(opts[:host], endpoint)
        req.body = body
      end
      if block_given?
        yield response
      else
        return parse(response)
      end
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
  def delete(endpoint, opts = {})
    apply_defaults!(opts)
    puts endpoint if ENV['DEBUG_API_CALLS']
    api_connection(opts[:user], opts[:password], opts[:proxy]) do |conn|
      response = conn.delete do |req|
        req.headers['Content-Type'] = opts[:content_type]
        req.headers['X-API-Version'] = opts[:x_api_version]
        req.url URI.join(opts[:host], endpoint)
      end
      if block_given?
        yield response
      else
        return parse(response)
      end
    end
  end

end
