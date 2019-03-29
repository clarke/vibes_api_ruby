require 'spec_helper'

# MobileDb specs/tests
describe Vibes::Incentives do

  let(:company_key) { 'A1b2C3' }
  let(:pool_id) { '1' }
  let(:code) { '03fd4b49-a8f4-4da5-bb84-f5fcb3cd4163' }
  let(:mdn) { '312-972-5333' }
  let(:campaign_id) { '706922' }
  let(:test_response) { { status: 'success' } }

  # catapult_hostname
  describe 'hostname' do
    it 'should return URL of Vibes Public API hostname' do
      expect(Vibes::Incentives.hostname).to eq 'https://public-api.vibescm.com'
    end
  end

  describe "get_pools" do
    it 'calls correct endpoint and returns a hash of response body' do
      endpoint = "/companies/#{company_key}/incentives/pools"
      Vibes::Incentives.expects(:get).with(endpoint).returns(test_response)
      expect(Vibes::Incentives.get_pools(company_key)).to eq(test_response)
    end
  end

  describe "get_pool" do
    it 'calls correct endpoint and returns a hash of response body' do
      endpoint = "/companies/#{company_key}/incentives/pools/#{pool_id}"
      Vibes::Incentives.expects(:get).with(endpoint).returns(test_response)
      expect(Vibes::Incentives.get_pool(company_key, pool_id)).to eq(test_response)
    end
  end

  describe "get_code" do
    it 'calls correct endpoint and returns a hash of response body' do
      endpoint = "/companies/#{company_key}/incentives/codes/#{code}"
      Vibes::Incentives.expects(:get).with(endpoint).returns(test_response)
      expect(Vibes::Incentives.get_code(company_key, code)).to eq(test_response)
    end
  end

  describe "get_issuances" do
    it 'calls correct endpoint and returns a hash of response body' do
      endpoint = "/companies/#{company_key}/incentives/codes/#{code}/issuances"
      Vibes::Incentives.expects(:get).with(endpoint).returns(test_response)
      expect(Vibes::Incentives.get_issuances(company_key, code)).to eq(test_response)
    end
  end

  describe "get_redemptions" do
    it 'calls correct endpoint and returns a hash of response body' do
      endpoint = "/companies/#{company_key}/incentives/codes/#{code}/redemptions"
      Vibes::Incentives.expects(:get).with(endpoint).returns(test_response)
      expect(Vibes::Incentives.get_redemptions(company_key, code)).to eq(test_response)
    end
  end

  describe 'issue_code' do
    it 'calls correct endpoint and returns a hash of response body' do
      endpoint = "/companies/#{company_key}/incentives/pools/#{pool_id}/issuances"
      body = { external_issuee_id: mdn, referring_application_ref_id: campaign_id, referring_application: 'splat' }.to_json
      Vibes::Incentives.expects(:post).with(endpoint, body).returns(test_response)
      expect(Vibes::Incentives.issue_code(company_key, pool_id, mdn, campaign_id)).to eq(test_response)
    end
  end

  describe 'redeem_code' do
    it 'calls correct endpoint and returns a hash of response body' do
      endpoint = "/companies/#{company_key}/incentives/codes/#{code}/redemptions"
      body = {}.to_json
      Vibes::Incentives.expects(:post).with(endpoint, body).returns(test_response)
      expect(Vibes::Incentives.redeem_code(company_key, code)).to eq(test_response)
    end
  end

end
