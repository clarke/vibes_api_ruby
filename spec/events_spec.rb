require 'spec_helper'

# MobileDb specs/tests
describe Vibes::Events do

  let(:company_key) { 'A1b2C3' }
  let(:company_id) { '12345' }
  let(:event_type) { 'day_of_delivery' }
  let(:event_data) { JSON.parse '{"first_name": "Bob", "external_person_id": "AB12345", "loyalty_points": 5000}' }
  let(:debug_data) { JSON.parse '{"field": "CUST_SYSTEM", "jobid": "12345"}' }
  let(:event_id) { '03fd4b49-a8f4-4da5-bb84-f5fcb3cd4163' }
  let(:test_response) { { status: 'success' } }

  # catapult_hostname
  describe 'hostname' do
    it 'should return URL of Vibes Public API hostname' do
      expect(Vibes::Events.hostname).to eq 'https://public-api.vibescm.com'
    end
  end

  describe "create_event" do
    it "should call the events API with correct payload" do
      endpoint = "/companies/#{company_key}/events"
      body = { event_type: event_type, event_data: event_data, debug_data: debug_data }.to_json
      Vibes::Events.expects(:post).with(endpoint, body).returns(test_response)
      expect(Vibes::Events.create_event( company_key, event_type, event_data, debug_data)).to eq(test_response)
    end
  end

  describe "create_event" do
    it "should call the events API with correct payload and event_id" do
      endpoint = "/companies/#{company_key}/events"
      body = { event_type: event_type, event_data: event_data, debug_data: debug_data, event_id: event_id }.to_json
      Vibes::Events.expects(:post).with(endpoint, body).returns(test_response)
      expect(Vibes::Events.create_event( company_key, event_type, event_data, debug_data, event_id)).to eq(test_response)
    end
  end

  describe "get_event" do
    it "should retrieve all listed events for a company" do
      endpoint = "/MessageRouter/event/companies/#{company_id}/types"
      Vibes::Events.expects(:get).returns(test_response)
      expect(Vibes::Events.get_events( company_id )).to eq(test_response)
    end
  end

  describe "delete_event" do
    it "should delete an event for a company" do
      endpoint = "/MessageRouter/event/companies/#{company_id}/types"
      Vibes::Events.expects(:delete).returns(test_response)
      expect(Vibes::Events.delete_event( company_id, 'delete_me' )).to eq(test_response)
    end
  end


end
