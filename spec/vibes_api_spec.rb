require 'spec_helper'

# MsgToolbox specs/tests
describe Vibes::VibesApi do

  # Global setup
  before do
    ENV['SPLAT_API_USER'] = "splat_username"
    ENV['SPLAT_API_PASS'] = "splat_password"
    @test_response_body   = Random.new.rand(0..500)
    @test_calls           = Faraday::Adapter::Test::Stubs.new
    @test_connection      = Faraday.new do |faraday|
      faraday.ssl.verify = false
      faraday.adapter :test, @test_calls
    end
  end

  # platform_hostname
  describe "platform_hostname" do
    it "should return URL of Vibes Catapult API hostname" do
      expect(Vibes::VibesApi.platform_hostname).to eq "https://www.vibescm.com"
    end
  end

  # vibes_apps_hostname
  describe "vibes_apps_hostname" do
    it "should return URL of Vibes Apps API hostname" do
      expect(Vibes::VibesApi.vibes_apps_hostname).to eq "https://api.vibesapps.com"
    end
  end


  # api_connection
  describe "api_connection" do

    before do
      @api_username = "username"
      @api_password = "password"
    end

    it "yields connection to block" do
      expect { Vibes::VibesApi.api_connection(@api_username, @api_password).to yield_control }
    end

    it "yields an authorized connection" do
      Vibes::VibesApi.api_connection(@api_username, @api_password) do |connection|
        expect(connection).not_to be_nil
        expect(connection.headers[:authorization]).not_to be_nil
      end
    end

    it "does not verify ssl connection" do
      Vibes::VibesApi.api_connection(@api_username, @api_password) do |connection|
        expect(connection.ssl.verify).to be false
      end
    end

  end

  # api_get
  describe "api_get" do

    before do
      @test_calls.get("/api/test_call") { [200, {}, @test_response_body ] }
    end

    it "yields response to block" do
      expect { Vibes::VibesApi.api_get("/api/test_call").to yield_control }
    end

    it "yields response from API call" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_get("/api/test_call") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses environment variables for default username and password" do
      Vibes::VibesApi.expects(:api_connection).with(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS']).yields(@test_connection)

      Vibes::VibesApi.api_get("/api/test_call") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override defaults for username and password" do
      Vibes::VibesApi.expects(:api_connection).with("custom_username", "custom_password").yields(@test_connection)
      Vibes::VibesApi.api_get("/api/test_call", user: "custom_username", password: "custom_password") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses the Vibes Catapult URL for hostname by default" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_get("/api/test_call") do |response|
        expect(full_hostname(response.env.url)).to eq Vibes::VibesApi.platform_hostname
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for hostname" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_get("/api/test_call", host: "http://www.google.com") do |response|
        expect(full_hostname(response.env.url)).to eq "http://www.google.com"
      end
      @test_calls.verify_stubbed_calls
    end
  end

  # api_post
  describe "api_post" do

    before do
      @test_endpoint = "/api/test_call"
      @test_body     = "<payload>Test Body</payload>"
      @test_calls.post(@test_endpoint) { [200, {}, @test_response_body] }
    end

    it "yields response to block" do
      expect { Vibes::VibesApi.api_post(@test_endpoint, @test_body).to yield_control }
    end

    it "yields response from API call" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_post(@test_endpoint, @test_body) do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses environment variables for default username and password" do
      Vibes::VibesApi.expects(:api_connection).with(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS']).yields(@test_connection)
      Vibes::VibesApi.api_post(@test_endpoint, @test_body) do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override defaults for username and password" do
      Vibes::VibesApi.expects(:api_connection).with("custom_username", "custom_password").yields(@test_connection)
      Vibes::VibesApi.api_post(@test_endpoint, @test_body, user: "custom_username", password: "custom_password") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses the Vibes Catapult URL for hostname by default" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_post(@test_endpoint, @test_body) do |response|
        expect(full_hostname(response.env.url)).to eq Vibes::VibesApi.platform_hostname
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for hostname" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_post(@test_endpoint, @test_body, host: "http://www.google.com") do |response|
        expect(full_hostname(response.env.url)).to eq "http://www.google.com"
      end
      @test_calls.verify_stubbed_calls
    end

    it "has a default content type of application/xml" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_post(@test_endpoint, @test_body) do |response|
        expect(response.env.request_headers['Content-Type']).to eq "application/xml"
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for content-type" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_post(@test_endpoint, @test_body, content_type: 'application/json') do |response|
        expect(response.env.request_headers['Content-Type']).to eq "application/json"
      end
      @test_calls.verify_stubbed_calls
    end

  end

  # api_delete
  describe "api_delete" do

    before do
      @test_calls.delete("/api/test_call") { [200, {}, @test_response_body ] } # Faraday stubbing
    end

    it "yields response to block" do
      expect { Vibes::VibesApi.api_delete("/api/test_call").to yield_control }
    end

    it "yields response from API call" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_delete("/api/test_call") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses environment variables for default username and password" do
      Vibes::VibesApi.expects(:api_connection).with(ENV['SPLAT_API_USER'], ENV['SPLAT_API_PASS']).yields(@test_connection)
      Vibes::VibesApi.api_delete("/api/test_call") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override defaults for username and password" do
      Vibes::VibesApi.expects(:api_connection).with("custom_username", "custom_password").yields(@test_connection)
      Vibes::VibesApi.api_delete("/api/test_call", user: "custom_username", password: "custom_password") do |response|
        expect(response.body).to eq(@test_response_body)
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses the Vibes Public API  URL for hostname by default" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_delete("/api/test_call") do |response|
        expect(full_hostname(response.env.url)).to eq Vibes::VibesApi.platform_hostname
      end
      @test_calls.verify_stubbed_calls
    end

    it "uses an options hash to override default for hostname" do
      Vibes::VibesApi.expects(:api_connection).yields(@test_connection)
      Vibes::VibesApi.api_delete("/api/test_call", host: "http://www.google.com") do |response|
        expect(full_hostname(response.env.url)).to eq "http://www.google.com"
      end
      @test_calls.verify_stubbed_calls
    end
  end



  # enter_contest
  describe "enter_contest" do
    before do
      @test_campaign          = "12345"
      @endpoint               = "/api/amoe/enter.xml?id=#{@test_campaign}"
      @test_attributes        = { first_name: "Vincent", last_name: "Vega", mobile_phone: "3121231234" }
      @test_custom_attributes = { custom_key: "custom_value" }
      @test_short_code        = "63901"
      @test_ok_message        = "Success"
      @test_bad_message       = "Failure"
      @test_ok_response       = stub(status: 200, headers: {}, body: "<response><ok>#{@test_ok_message}</ok></response>")
      @test_bad_response      = stub(status: 200, headers: {}, body: "<response><bad-request>#{@test_bad_message}</bad-request></response>")
      @test_unknown_response  = stub(status: 200, headers: {}, body: "<response><unknown>Hmm?</unknown></response>")
    end

    it "uses default (Catapult API) hostname with default username and password" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_ok_response).once
      Vibes::VibesApi.enter_contest(@test_campaign, @test_attributes, nil, nil)
    end

    it "includes attributes in POST body" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, all_of(includes(@test_attributes[:first_name]), includes(@test_attributes[:last_name]), includes(@test_attributes[:mobile_phone]))).yields(@test_ok_response).once
      Vibes::VibesApi.enter_contest(@test_campaign, @test_attributes, nil, nil)
    end

    it "returns OK message if successful" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_ok_response).once
      expect(Vibes::VibesApi.enter_contest(@test_campaign, @test_attributes, nil, nil)).to eq("Success")
    end

    it "returns BAD message if unsuccessful" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_bad_response).once
      expect(Vibes::VibesApi.enter_contest(@test_campaign, @test_attributes, nil, nil)).to eq("Failure")
    end

    it "returns whole response if unknown" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_unknown_response).once
      expect(Vibes::VibesApi.enter_contest(@test_campaign, @test_attributes, nil, nil)).to eq("<response><unknown>Hmm?</unknown></response>")
    end

    it "appends custom attributes if given" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, all_of(includes("custom_attributes"), includes(@test_custom_attributes[:custom_key]))).yields(@test_ok_response).once
      expect(Vibes::VibesApi.enter_contest(@test_campaign, @test_attributes, @test_custom_attributes, nil)).to eq(@test_ok_message)
    end

    it "will send an SMS to MDN if a short_code is given" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_ok_response).once
      Vibes::VibesApi.expects(:send_message).with(@test_attributes[:mobile_phone], @test_ok_message, @test_short_code).once
      Vibes::VibesApi.enter_contest(@test_campaign, @test_attributes, @test_custom_attributes, @test_short_code)
    end
  end

  # enter_contest_by_keyword
  describe "enter_contest_by_keyword" do
    before do
      @test_keyword           = "KEYWORD"
      @test_short_code        = "63901"
      @endpoint               = "/api/amoe/enter.xml?short_code=#{@test_short_code}&keyword=#{@test_keyword}"
      @test_attributes        = { first_name: "Vincent", last_name: "Vega", mobile_phone: "3121231234" }
      @test_custom_attributes = { custom_key: "custom_value" }
      @test_ok_message        = "Success"
      @test_bad_message       = "Failure"
      @test_ok_response       = stub(status: 200, headers: {}, body: "<response><ok>#{@test_ok_message}</ok></response>")
      @test_bad_response      = stub(status: 200, headers: {}, body: "<response><bad-request>#{@test_bad_message}</bad-request></response>")
      @test_unknown_response  = stub(status: 200, headers: {}, body: "<response><unknown>Hmm?</unknown></response>")
    end

    it "uses default (Catapult API) hostname with default username and password" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_ok_response).once
      Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, nil, @test_short_code)
    end

    it "includes attributes in POST body" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, all_of(includes(@test_attributes[:first_name]), includes(@test_attributes[:last_name]), includes(@test_attributes[:mobile_phone]))).yields(@test_ok_response).once
      Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, nil, @test_short_code)
    end

    it "returns OK message if successful" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_ok_response).once
      expect(Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, nil, @test_short_code)).to eq("Success")
    end

    it "returns BAD message if unsuccessful" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_bad_response).once
      expect(Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, nil, @test_short_code)).to eq("Failure")
    end

    it "appends custom attributes if given" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, all_of(includes("custom_attributes"), includes(@test_custom_attributes[:custom_key]))).yields(@test_ok_response).once
      expect(Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, @test_custom_attributes, @test_short_code)).to eq(@test_ok_message)
    end

    it "returns whole response if unknown" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_unknown_response).once
      expect(Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, @test_custom_attributes, @test_short_code)).to eq("<response><unknown>Hmm?</unknown></response>")
    end

    it "will not send an SMS to MDN if message flag is not set" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_ok_response).once
      Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, @test_custom_attributes, @test_short_code)
    end

    it "will send an SMS to MDN if message flag is set to true" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_ok_response).once
      Vibes::VibesApi.expects(:send_message).with(@test_attributes[:mobile_phone], @test_ok_message, @test_short_code).once
      Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, @test_custom_attributes, @test_short_code, true)
    end

    it "will not send an SMS to MDN if message flag is set to false" do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_ok_response).once
      Vibes::VibesApi.enter_contest_by_keyword(@test_keyword, @test_attributes, @test_custom_attributes, @test_short_code, false)
    end
  end

  # get_carrier_code
  describe "get_carrier_code" do
    before do
      @test_mdn      = "3129725333"
      @endpoint      = "/MessageApi/mdns/#{@test_mdn}"
      @test_response = stub(status: 200, headers: {}, body: "<mdn carrier='104' address='#{@test_mdn}'/>")
    end

    it "uses Vibes Apps API with correct endpoint" do
      Vibes::VibesApi.expects(:api_get).with(@endpoint, {host: Vibes::VibesApi.vibes_apps_hostname }).yields(@test_response).once
      Vibes::VibesApi.get_carrier_code(@test_mdn)
    end

    it "returns carrier code on success" do
      Vibes::VibesApi.expects(:api_get).with(@endpoint, {host: Vibes::VibesApi.vibes_apps_hostname }).yields(@test_response).once
      expect(Vibes::VibesApi.get_carrier_code(@test_mdn)).to eq 104
    end

    it "returns zero if no endpoint is found" do
      @test_response = stub(status: 200, headers: {}, body: "<error description='Invalid value'/>")
      Vibes::VibesApi.expects(:api_get).with(@endpoint, {host: Vibes::VibesApi.vibes_apps_hostname }).yields(@test_response).once
      expect(Vibes::VibesApi.get_carrier_code(@test_mdn)).to eq 0
    end
  end

  # get_carrier_name
  describe 'get_carrier_name' do
    before do
      @mdn = "3129725333"
      @carrier_code = 104
    end

    it "should call get_carrier_code to look up carrier for MDN" do
      Vibes::VibesApi.expects(:get_carrier_code).with(@mdn).returns(@carrier_code)
      Vibes::VibesApi.get_carrier_name(@mdn)
    end

    it "should return the correct name of the carrier for MDN" do
      Vibes::VibesApi.expects(:get_carrier_code).with(@mdn).returns(@carrier_code)
      expect(Vibes::VibesApi.get_carrier_name(@mdn)).to eq("AT&T")
    end
  end

  describe "get_carrier_code_by_name" do
    before do
      @valid_carrier = Vibes::VibesApi::CARRIER_CODE_TO_NAME.first
    end

    it "should return a valid carrier code for a recognized carrier name" do
      carrier_code = Vibes::VibesApi.get_carrier_code_by_name(@valid_carrier[1])
      expect(carrier_code).to eq(@valid_carrier[0])
    end

    it "should return 0 for an unrecognized carrier name" do
      carrier_code = Vibes::VibesApi.get_carrier_code_by_name("McFly Wirelesss 1985")
      expect(carrier_code).to eq(0)
    end
  end


  # vote
  describe 'vote' do
    before do
      @test_campaign          = '12345'
      @test_vote_option       = 'foo'
      @test_user_id           = '5125551212'
      @endpoint               = "/api/vote_campaigns/#{@test_campaign}/votes.xml"
      @test_response          = stub(status: 200, headers: {}, body: @test_response_body)
    end

    it 'uses default (Catapult API) hostname with default username and password' do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_response).once
      Vibes::VibesApi.vote(@test_user_id, @test_vote_option, @test_campaign)
    end

    it 'includes attributes in POST body' do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, all_of(includes(@test_vote_option), includes(@test_user_id))).yields(@test_response).once
      Vibes::VibesApi.vote(@test_user_id, @test_vote_option, @test_campaign)
    end

    it 'returns response body' do
      Vibes::VibesApi.expects(:api_post).with(@endpoint, anything).yields(@test_response).once
      Vibes::VibesApi.vote(@test_user_id, @test_vote_option, @test_campaign)
    end
  end

  # is valid mdn
  describe "is_valid_mdn" do

    it 'returns true for a valid mdn with no dashes' do
      mdn = '3129725333'
      expect(Vibes::VibesApi.is_valid_mdn?(mdn)).to eq(true)
    end

    it 'returns true for a valid mdn with dashes' do
      mdn = '312-972-5333'
      expect(Vibes::VibesApi.is_valid_mdn?(mdn)).to eq(true)
    end

    it 'returns true for a valid mdn with a country code' do
      mdn = '13129725333'
      expect(Vibes::VibesApi.is_valid_mdn?(mdn)).to eq(true)
    end

    it 'returns true for a valid mdn with a country code and dashes' do
      mdn = '1-312-972-5333'
      expect(Vibes::VibesApi.is_valid_mdn?(mdn)).to eq(true)
    end

    it 'returns false for an mdn that is too long' do
      mdn = '131297253333'
      expect(Vibes::VibesApi.is_valid_mdn?(mdn)).to eq(false)
    end

    it 'returns false for an mdn that has improper characters in it' do
      mdn = '312.972.53333'
      expect(Vibes::VibesApi.is_valid_mdn?(mdn)).to eq(false)
    end

    it 'returns false for an mdn that is blank' do
      mdn = ''
      expect(Vibes::VibesApi.is_valid_mdn?(mdn)).to eq(false)
    end

  end


end
