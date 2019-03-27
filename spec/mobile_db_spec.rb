require 'spec_helper'

# MobileDb specs/tests
describe MobileDb do

  # Global setup
  before do
    ENV['SPLAT_API_USER'] = "splat_username"
    ENV['SPLAT_API_PASS'] = "splat_password"
    @company_key          = "A1b2C3"
    @test_response_body   = { status: "success" }.to_json
    @test_response        = JSON.parse(@test_response_body)
    @test_calls           = Faraday::Adapter::Test::Stubs.new
    @test_connection      = Faraday.new do |faraday|
      faraday.ssl.verify = false
      faraday.adapter :test, @test_calls
    end
  end

  # catapult_hostname
  describe "hostname" do
    it "should return URL of Vibes Public API hostname" do
      expect(MobileDb.hostname).to eq "https://public-api.vibescm.com"
    end
  end

  # api_connection
  describe "api_connection" do

    before do
      @api_username = "username"
      @api_password = "password"
    end

    it "yields connection to block" do
      expect { MobileDb.api_connection(@api_username, @api_password).to yield_control }
    end

    it "yields an authorized connection" do
      MobileDb.api_connection(@api_username, @api_password) do |connection|
        expect(connection).not_to be_nil
        expect(connection.headers[:authorization]).not_to be_nil
      end
    end

    it "does not verify ssl connection" do
      MobileDb.api_connection(@api_username, @api_password) do |connection|
        expect(connection.ssl.verify).to be false
      end
    end

    it "throws an exception if a username or password are not supplied" do
      expect { MobileDb.api_connection(nil, nil) }.to raise_error "Vibes API: Username or Password missing. Check your environment variables."
    end

  end

  # get
  describe "get" do

    before do
      @test_calls.get("/api/test_call") { [200, {}, @test_response_body ] } # Faraday stubbing
    end

    it "yields raw response from API call" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.get("/api/test_call") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "returns a parsed Hash of the response body from API call" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      response = MobileDb.get("/api/test_call")
      expect(response).to eq(JSON.parse(@test_response_body))
      @test_calls.verify_stubbed_calls

    end

    it "uses environment variables for default username and password" do
      MobileDb.expects(:api_connection).with(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'], nil).yields(@test_connection)
      MobileDb.get("/api/test_call")
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override defaults for username and password" do
      MobileDb.expects(:api_connection).with("custom_username", "custom_password",  nil).yields(@test_connection)
      MobileDb.get("/api/test_call", user: "custom_username", password: "custom_password")
      @test_calls.verify_stubbed_calls
    end

    it "uses the Vibes Public API  URL for hostname by default" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.get("/api/test_call") do |response|
        expect(full_hostname(response.env.url)).to eq MobileDb.hostname
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for hostname" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.get("/api/test_call", host: "http://www.google.com") do |response|
        expect(full_hostname(response.env.url)).to eq "http://www.google.com"
      end
      @test_calls.verify_stubbed_calls
    end
  end

  # post
  describe "post" do

    before do
      @test_endpoint = "/api/test_call"
      @test_body     = "<payload>Test Body</payload>"
      @test_calls.post(@test_endpoint) { [200, {}, @test_response_body] } # Faraday stubbing
    end

    it "yields raw response from API call" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.post(@test_endpoint, @test_body) do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses environment variables for default username and password" do
      MobileDb.expects(:api_connection).with(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'], nil).yields(@test_connection)
      MobileDb.post(@test_endpoint, @test_body)
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override defaults for username and password" do
      MobileDb.expects(:api_connection).with("custom_username", "custom_password", nil).yields(@test_connection)
      MobileDb.post(@test_endpoint, @test_body, user: "custom_username", password: "custom_password")
      @test_calls.verify_stubbed_calls
    end

    it "uses the Vibes Public API URL for hostname by default" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.post(@test_endpoint, @test_body) do |response|
        expect(full_hostname(response.env.url)).to eq MobileDb.hostname
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for hostname" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.post(@test_endpoint, @test_body, host: "http://www.google.com") do |response|
        expect(full_hostname(response.env.url)).to eq "http://www.google.com"
      end
      @test_calls.verify_stubbed_calls
    end

    it "has a default content type of application/json" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.post(@test_endpoint, @test_body) do |response|
        expect(response.env.request_headers['Content-Type']).to eq "application/json"
      end
      @test_calls.verify_stubbed_calls
    end

  end

  # put
  describe "put" do

    before do
      @test_endpoint = "/api/put_call"
      @test_body     = "<payload>Test Body</payload>"
      @test_calls.put(@test_endpoint) { [200, {}, @test_response_body] } # Faraday stubbing
    end

    it "yields raw response from API call" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.put(@test_endpoint, @test_body) do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses environment variables for default username and password" do
      MobileDb.expects(:api_connection).with(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'], nil).yields(@test_connection)
      MobileDb.put(@test_endpoint, @test_body)
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override defaults for username and password" do
      MobileDb.expects(:api_connection).with("custom_username", "custom_password", nil).yields(@test_connection)
      MobileDb.put(@test_endpoint, @test_body, user: "custom_username", password: "custom_password")
      @test_calls.verify_stubbed_calls
    end

    it "uses the Vibes Public API URL for hostname by default" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.put(@test_endpoint, @test_body) do |response|
        expect(full_hostname(response.env.url)).to eq MobileDb.hostname
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for hostname" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.put(@test_endpoint, @test_body, host: "http://www.google.com") do |response|
        expect(full_hostname(response.env.url)).to eq "http://www.google.com"
      end
      @test_calls.verify_stubbed_calls
    end

    it "has a default content type of application/json" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.put(@test_endpoint, @test_body) do |response|
        expect(response.env.request_headers['Content-Type']).to eq "application/json"
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for content-type" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.put(@test_endpoint, @test_body, content_type: 'application/xml') do |response|
        expect(response.env.request_headers['Content-Type']).to eq "application/xml"
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for content-type" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.put(@test_endpoint, @test_body, content_type: 'application/xml') do |response|
        expect(response.env.request_headers['Content-Type']).to eq "application/xml"
      end
      @test_calls.verify_stubbed_calls
    end

  end

  # delete
  describe "delete" do

    before do
      @test_calls.delete("/api/test_call") { [200, {}, @test_response_body ] } # Faraday stubbing
    end

    it "yields raw response from API call" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.delete("/api/test_call") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses environment variables for default username and password" do
      MobileDb.expects(:api_connection).with(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS'], nil).yields(@test_connection)
      MobileDb.delete("/api/test_call")
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override defaults for username and password" do
      MobileDb.expects(:api_connection).with("custom_username", "custom_password", nil).yields(@test_connection)
      MobileDb.delete("/api/test_call", user: "custom_username", password: "custom_password")
      @test_calls.verify_stubbed_calls
    end

    it "uses the Vibes Public API  URL for hostname by default" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.delete("/api/test_call") do |response|
        expect(full_hostname(response.env.url)).to eq MobileDb.hostname
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for hostname" do
      MobileDb.expects(:api_connection).yields(@test_connection)
      MobileDb.delete("/api/test_call", host: "http://www.google.com") do |response|
        expect(full_hostname(response.env.url)).to eq "http://www.google.com"
      end
      @test_calls.verify_stubbed_calls
    end
  end


  # find_person
  describe 'find_person' do
    before do
      @test_mdn = '5125551212'
      @test_company_key = 'abcdef'
      @endpoint = "/companies/#{@test_company_key}/mobiledb/persons?mdn=#{@test_mdn}"
    end

    it 'uses mobile db API with correct endpoint' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      MobileDb.find_person(@test_company_key, @test_mdn)
    end

    it 'returns hash of response body' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      expect(MobileDb.find_person(@test_company_key, @test_mdn)).to eq(JSON.parse(@test_response_body))
    end
  end

  # add_person(company_key, custom_fields, mobile_phone)
  describe 'add_person' do
    before do
      @test_company_key = 'abcdef'
      @test_mdn = '5125551212'
      @test_attributes = {mobile_phone: "#{@test_mdn}"}
      @test_custom_fields = {custom_key: 'custom_value'}
      @endpoint ="/companies/#{@test_company_key}/mobiledb/persons"
    end

    it 'uses correct hostname (mobile db) with default username and password' do
      MobileDb.expects(:post).with(@endpoint, anything).returns(@test_response)
      MobileDb.add_person(@test_company_key, @test_custom_fields, @test_mdn)
    end

    it 'includes attributes in POST body' do
      MobileDb.expects(:post).with(@endpoint, all_of(includes(@test_mdn))).returns(@test_response)
      MobileDb.add_person(@test_company_key, @test_custom_fields, @test_mdn)
    end

    it 'returns hash of response body' do
      MobileDb.expects(:post).with(@endpoint, anything).returns(@test_response)
      expect(MobileDb.add_person(@test_company_key, @test_custom_fields, @test_mdn)).to eq(JSON.parse(@test_response_body))
    end

    it 'appends custom attributes if given' do
      MobileDb.expects(:post).with(@endpoint, all_of(includes(@test_custom_fields[:custom_key]))).returns(@test_response)
      MobileDb.add_person(@test_company_key, @test_custom_fields, @test_mdn)
    end
  end

  # update_person(company_key, mobile_phone, custom_fields)
  describe 'update_person' do
    before do
      @person_id = '101'
      @company_key = 'abcdef'
      @fields = { :mdn => '3129725333', :custom_fields => { custom_field: 'custom_value' } }
      @endpoint ="/companies/#{@company_key}/mobiledb/persons/#{@person_id}"
    end

    it 'uses mobile db API with correct endpoint' do
      MobileDb.expects(:put).with(@endpoint, anything).returns(@test_response)
      MobileDb.update_person(@company_key, @person_id, @fields)
    end

    it 'includes attributes in POST body' do
      MobileDb.expects(:put).with(@endpoint, all_of( includes(@fields[:custom_fields][:custom_field]))).returns(@test_response)
      MobileDb.update_person(@company_key, @person_id, @fields)
    end

    it 'returns hash of response body' do
      MobileDb.expects(:put).with(@endpoint, anything).returns(@test_response)
      expect(MobileDb.update_person(@company_key, @person_id, @fields)).to eq(JSON.parse(@test_response_body))
    end
  end

  # get_person
  describe 'get_person' do
    before do
      @test_person_id = '101'
      @test_company_key = 'abcdef'
      @endpoint = "/companies/#{@test_company_key}/mobiledb/persons/#{@test_person_id}"
    end

    it 'uses mobile db API with correct endpoint' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      MobileDb.get_person(@test_company_key, @test_person_id)
    end

    it 'returns hash of response body' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      expect(MobileDb.get_person(@test_company_key, @test_person_id)).to eq(JSON.parse(@test_response_body))
    end
  end

  # find_person
  describe 'get_person_by_url' do
    before do
      @test_person_id = '101'
      @test_company_key = 'abcdef'
      @endpoint = "/companies/#{@test_company_key}/mobiledb/persons/#{@test_person_id}"
    end

    it 'uses mobile db API with correct endpoint' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      MobileDb.get_person_by_url(@endpoint)
    end

    it 'returns hash of response body' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      expect(MobileDb.get_person_by_url(@endpoint)).to eq(JSON.parse(@test_response_body))
    end
  end

  # subscribe
  describe 'subscribe' do
    before do
      @test_company_key = 'abcdef'
      @test_acquisition_id = 'zyxwvut'
      @test_mdn = '5125551212'
      @test_attributes = {mobile_phone: "#{@test_mdn}"}
      @test_custom_fields = {custom_key: 'custom_value'}
      @endpoint = "/companies/#{@test_company_key}/campaigns/acquisition/#{@test_acquisition_id}/participants"
    end

    it 'uses correct hostname (mobile db) with default username and password' do
      MobileDb.expects(:post).with(@endpoint, anything).returns(@test_response)
      MobileDb.subscribe(@test_company_key, @test_acquisition_id, @test_mdn, @test_custom_fields)
    end

    it 'includes attributes in POST body' do
      MobileDb.expects(:post).with(@endpoint, all_of(includes(@test_mdn))).returns(@test_response)
      MobileDb.subscribe(@test_company_key, @test_acquisition_id, @test_mdn, @test_custom_fields)
    end

    it 'returns hash of response body' do
      MobileDb.expects(:post).with(@endpoint, anything).returns(@test_response)
      expect(MobileDb.subscribe(@test_company_key, @test_acquisition_id, @test_mdn, @test_custom_fields)).to eq(JSON.parse(@test_response_body))
    end

    it 'appends custom attributes if given' do
      MobileDb.expects(:post).with(@endpoint, all_of(includes(@test_custom_fields[:custom_key]))).returns(@test_response)
      MobileDb.subscribe(@test_company_key, @test_acquisition_id, @test_mdn, @test_custom_fields)
    end

  end

  # subscribe_external_id
  describe 'subscribe_external_id' do
    before do
      @test_company_key = 'abcdef'
      @test_acquisition_id = 'zyxwvut'
      @test_mdn = '5125551212'
      @test_external_id = 'ABCD1234'
      @test_attributes = {mobile_phone: "#{@test_mdn}"}
      @test_custom_fields = {custom_key: 'custom_value'}
      @endpoint = "/companies/#{@test_company_key}/campaigns/acquisition/#{@test_acquisition_id}/participants"
    end

    it 'uses correct hostname (mobile db) with default username and password' do
      MobileDb.expects(:post).with(@endpoint, anything).returns(@test_response)
      MobileDb.subscribe_external_id(@test_company_key, @test_acquisition_id, @test_mdn, @test_external_id, @test_custom_fields)
    end

    it 'includes attributes in POST body' do
      MobileDb.expects(:post).with(@endpoint, all_of(includes(@test_mdn))).returns(@test_response)
      MobileDb.subscribe_external_id(@test_company_key, @test_acquisition_id, @test_mdn, @test_external_id, @test_custom_fields)
    end

    it 'includes attributes in POST body' do
      MobileDb.expects(:post).with(@endpoint, all_of(includes(@test_external_id))).returns(@test_response)
      MobileDb.subscribe_external_id(@test_company_key, @test_acquisition_id, @test_mdn, @test_external_id, @test_custom_fields)
    end

    it 'returns hash of response body' do
      MobileDb.expects(:post).with(@endpoint, anything).returns(@test_response)
      expect(MobileDb.subscribe_external_id(@test_company_key, @test_acquisition_id, @test_mdn, @test_external_id, @test_custom_fields)).to eq(JSON.parse(@test_response_body))
    end

    it 'appends custom attributes if given' do
      MobileDb.expects(:post).with(@endpoint, all_of(includes(@test_custom_fields[:custom_key]))).returns(@test_response)
      MobileDb.subscribe_external_id(@test_company_key, @test_acquisition_id, @test_mdn, @test_external_id, @test_custom_fields)
    end

  end

  # unsubscribe
  describe 'unsubscribe' do
    before do
      @test_company_key = 'abcdef'
      @test_person_id = '100'
      @test_subscription_list_id = '1'
      @endpoint = "/companies/#{@test_company_key}/mobiledb/persons/#{@test_person_id}/subscriptions/#{@test_subscription_list_id}"
    end

    it 'uses correct hostname (mobile db) with default username and password' do
      MobileDb.expects(:delete).with(@endpoint).returns(@test_response)
      MobileDb.unsubscribe(@test_company_key, @test_person_id, @test_subscription_list_id)
    end

    it 'returns a hash of response body' do
      MobileDb.expects(:delete).with(@endpoint).returns(@test_response)
      expect(MobileDb.unsubscribe(@test_company_key, @test_person_id, @test_subscription_list_id)).to eq(JSON.parse(@test_response_body))
    end

  end

  describe 'get subscriptions' do
    before do
      @person_id = 101
      @endpoint = "/companies/#{@company_key}/mobiledb/persons/#{@person_id}/subscriptions"
    end

    it 'calls correct endpoint on mobile db' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      MobileDb.get_subscriptions(@company_key, @person_id)
    end

    it 'returns a hash of response body' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      expect(MobileDb.get_subscriptions(@company_key, @person_id)).to eq(JSON.parse(@test_response_body))
    end
  end


  describe 'get subscription list' do
    before do
      @subscription_list_id = 5
      @endpoint = "/companies/#{@company_key}/mobiledb/subscription_lists/#{@subscription_list_id}"
    end

    it 'calls correct endpoint on mobile db' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      MobileDb.get_subscription_list(@company_key, @subscription_list_id)
    end

    it 'returns a hash of response body' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      expect(MobileDb.get_subscription_list(@company_key, @subscription_list_id)).to eq(JSON.parse(@test_response_body))
    end
  end

  describe 'get subscription lists' do
    before do
      @endpoint = "/companies/#{@company_key}/mobiledb/subscription_lists"
    end

    it 'calls correct endpoint on mobile db' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      MobileDb.get_subscription_lists(@company_key)
    end

    it 'returns a hash of response body' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      expect(MobileDb.get_subscription_lists(@company_key)).to eq(JSON.parse(@test_response_body))
    end
  end

  describe 'get acquisition campaigns' do
    before do
      @subscription_list_id = "101"
      @endpoint = "/companies/#{@company_key}/mobiledb/subscription_lists/#{@subscription_list_id}/acquisition_campaigns"
    end

    it 'calls correct endpoint on mobile db' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      MobileDb.get_acquisition_campaigns(@company_key, @subscription_list_id)
    end

    it 'returns a hash of response body' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      expect(MobileDb.get_acquisition_campaigns(@company_key, @subscription_list_id)).to eq(JSON.parse(@test_response_body))
    end
  end

  describe 'get acquisition campaign' do
    before do
      @acquisition_id = "j1E2f"
      @endpoint = "/companies/#{@company_key}/campaigns/acquisition/#{@acquisition_id}"
    end

    it 'calls correct endpoint on mobile db' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      MobileDb.get_acquisition_campaign(@company_key, @acquisition_id)
    end

    it 'returns a hash of response body' do
      MobileDb.expects(:get).with(@endpoint).returns(@test_response)
      expect(MobileDb.get_acquisition_campaign(@company_key, @acquisition_id)).to eq(JSON.parse(@test_response_body))
    end
  end
end
