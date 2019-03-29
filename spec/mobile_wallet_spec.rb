require 'spec_helper'

# MobileDb specs/tests
describe Vibes::MobileWallet do

  let(:company_key) { 'A1b2C3' }
  let(:wallet_id) { '1234' }
  let(:tokens) { JSON.parse '{ "loyalty_points": 5000}' }
  let(:wallet_item_id) { '5125551212' }
  let(:test_response) { { status: 'success' } }

  # catapult_hostname
  describe 'hostname' do
    it 'should return URL of Vibes Public API hostname' do
      expect(Vibes::MobileWallet.hostname).to eq 'https://public-api.vibescm.com'
    end
  end

  describe 'update_wallet_item' do
    it 'should call the wallet campaign API with correct payload' do
      endpoint ="/companies/#{company_key}/campaigns/wallet/#{wallet_id}/items/#{wallet_item_id}"
      #body = { tokens: tokens }.to_json
      Vibes::MobileWallet.expects(:put).with(endpoint, anything).returns(test_response)
      expect(Vibes::MobileWallet.update_wallet_item(company_key, wallet_id, wallet_item_id, tokens)).to eq(test_response)
    end
  end
  
  describe 'get_wallet_item' do
    let(:endpoint) { "/companies/#{company_key}/campaigns/wallet/#{wallet_id}/items/#{wallet_item_id}" }
    context 'calls correct endpoint and returns a hash of response body' do
      before{ Vibes::MobileWallet.expects(:get).with(endpoint).returns(test_response) }
      subject { Vibes::MobileWallet.get_wallet_item(company_key, wallet_id, wallet_item_id) }
      it { should eq(test_response) }
    end
  end
  
  describe 'get_wallet_items' do
    let(:group_code) { "TEST_GROUP" }
    let(:endpoint) { "/companies/#{company_key}/campaigns/wallet" }

    context 'calls correct endpoint without group_code option and returns a hash of response body' do
      before { Vibes::MobileWallet.expects(:get).with(endpoint.concat("/#{wallet_id}/items")).returns(test_response) }
      subject { Vibes::MobileWallet.get_wallet_items(company_key, wallet_id) }
      it { should eq(test_response) }
    end
    
    context 'calls correct endpoint with group_code option and returns a hash of response body' do
      before { Vibes::MobileWallet.expects(:get).with(endpoint.concat("/#{wallet_id}/items?group_code=#{group_code}")).returns(test_response) }
      subject { Vibes::MobileWallet.get_wallet_items(company_key, wallet_id, group_code) }
      it { should eq(test_response) }
    end
  end
  
  describe 'get_wallet_campaigns' do
    let(:endpoint) { "/companies/#{company_key}/campaigns/wallet" }
    context 'calls correct endpoint and returns a hash of response body' do
      before { Vibes::MobileWallet.expects(:get).with(endpoint).returns(test_response) }
      subject{ Vibes::MobileWallet.get_wallet_campaigns(company_key) }
      it { should eq(test_response) }
    end
  end
  
  describe 'get_wallet_campaign' do
    let(:endpoint) { "/companies/#{company_key}/campaigns/wallet/#{wallet_id}" }
    context 'calls correct endpoint and returns a hash of response body' do    
      before { Vibes::MobileWallet.expects(:get).with(endpoint).returns(test_response) }
      subject{ Vibes::MobileWallet.get_wallet_campaign(company_key, wallet_id) }
      it { should eq(test_response) }
    end
  end

end
