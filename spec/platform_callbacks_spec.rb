require 'pry'

require 'spec_helper'

# MobileDb specs/tests
describe Vibes::PlatformCallbacks do

  let(:company_key)          { "A1b2C3" }
  let(:subscription_list_id) { "10" }
  let(:callback_id)          { "456" }
  let(:acquisition_id)       { "C1q2E3" }
  let(:destination_url)      { "http://callback-url.com/enpoint"}
  let(:test_response)        { JSON.parse(%q!{ "status": "success" }!)}

  describe ".subscription_added" do
    it "should call the callback API with correct payload" do
      Vibes::MobileDb.expects(:post).with(
        includes(company_key),
        all_of(
          includes('subscription_added'),
          includes(subscription_list_id),
          includes(destination_url)
        )
      ).returns(test_response)
      Vibes::PlatformCallbacks.create_subscription_added( company_key, subscription_list_id, destination_url)
    end
  end

  describe "subscription_removed" do
    it "should call the Callbacks API with correct payload" do
      Vibes::MobileDb.expects(:post).with(
        includes(company_key),
        all_of(
          includes('subscription_removed'),
          includes(subscription_list_id),
          includes(destination_url)
        )
      ).returns(test_response)
      Vibes::PlatformCallbacks.create_subscription_removed( company_key, subscription_list_id, destination_url)
    end
  end

  describe "ack_participant_changed" do
    it "should call the Callbacks API with correct payload" do
      Vibes::MobileDb.expects(:post).with(
        includes(company_key),
        all_of(
          includes('ack_participant_changed'),
          includes(acquisition_id),
          includes(destination_url)
        )
      ).returns(test_response)
      Vibes::PlatformCallbacks.create_participant_changed( company_key, acquisition_id, destination_url)
    end
  end

  describe "ack_participant_added" do
    it "should call the Callbacks API with correct payload" do
      Vibes::MobileDb.expects(:post).with(
        includes(company_key),
        all_of(
          includes('ack_participant_added'),
          includes(acquisition_id),
          includes(destination_url)
        )
      ).returns(test_response)
      Vibes::PlatformCallbacks.create_participant_added( company_key, acquisition_id, destination_url)
    end
  end

  describe "list_Callbacks" do
    it "should call the Callbacks API with correct payload" do
      Vibes::MobileDb.expects(:get).with(includes(company_key)).returns(test_response)
      Vibes::PlatformCallbacks.list(company_key)
    end
  end

  describe "delete_callback" do
    it "should call the Callbacks API with correct payload" do
      Vibes::MobileDb.expects(:delete).with(
        all_of(
          includes(company_key),
          includes(callback_id)
        )
      ).returns(test_response)
      Vibes::PlatformCallbacks.delete(company_key, callback_id)
    end
  end

  describe 'filter & utility methods' do
    let(:subscription_added_callback) do
      {
        "callback_id"=>1,
        "event_type"=>"subscription_added",
        "subscription_added"=>{"list_id"=>"1"},
        "destination"=>{"url"=>"http://subscription_added_destination.com", "method"=>"POST", "content_type"=>"application/json"}
      }
    end

    let(:subscription_removed_callback) do
      {
        "callback_id"=>2,
        "event_type"=>"subscription_removed",
        "subscription_removed"=>{"list_id"=>"2"},
        "destination"=>{"url"=>"http://subscription_removed_destination.com", "method"=>"POST", "content_type"=>"application/json"}
      }
    end

    let(:ack_participant_changed_callback) do
      {
        "callback_id"=>3,
        "event_type"=>"ack_participant_changed",
        "ack_participant_changed"=>{"campaign_id"=>"c3c3c3"},
        "destination"=>{"url"=>"http://ack_participant_changed_destination.com", "method"=>"POST", "content_type"=>"application/json"}
      }
    end

    let(:ack_participant_added_callback) do
      {
        "callback_id"=>4,
        "event_type"=>"ack_participant_added",
        "ack_participant_added"=>{"campaign_id"=>"d4d4d4"},
        "destination"=>{"url"=>"http://ack_participant_added_destination.com", "method"=>"POST", "content_type"=>"application/json"}
      }
    end

    let(:subscription_added_identifier) { subscription_added_callback['subscription_added']['list_id'] }
    let(:subscription_removed_identifier) { subscription_removed_callback['subscription_removed']['list_id'] }
    let(:ack_participant_changed_identifier) { ack_participant_changed_callback['ack_participant_changed']['campaign_id'] }
    let(:ack_participant_added_identifier) { ack_participant_added_callback['ack_participant_added']['campaign_id'] }


    let(:mixed_callbacks) do
      [
        subscription_added_callback,
        subscription_removed_callback,
        ack_participant_changed_callback,
        ack_participant_added_callback
      ]
    end

    describe '.find_callback_for' do
      before(:each) do
        Vibes::PlatformCallbacks.expects(:list).returns(mixed_callbacks)
      end

      it 'finds a callback by list_id' do
        expect(Vibes::PlatformCallbacks.find_callback_for(company_key, subscription_added_identifier)).to eq([subscription_added_callback])
      end

      it 'finds a callback by acq_key' do
        expect(Vibes::PlatformCallbacks.find_callback_for(company_key, ack_participant_changed_identifier)).to eq([ack_participant_changed_callback])
      end
    end

    describe '.change_url' do
      let(:new_url) { 'http://my-new-url.com' }

      before(:each) do
        Vibes::PlatformCallbacks.stubs(:delete)
        Vibes::PlatformCallbacks.stubs(:create)
      end

      describe 'for all callback types' do
        describe 'finding the callback' do
          before(:each) { Vibes::PlatformCallbacks.stubs(:delete) }

          it 'uses .find_callback_for w/ correct args' do
            Vibes::PlatformCallbacks.expects(:find_callback_for).with(company_key, subscription_added_identifier).returns([subscription_added_callback])

            Vibes::PlatformCallbacks.change_url(company_key, subscription_added_identifier, new_url)
          end
        end

        describe 'deleting the existing callback' do
          before(:each) do
            Vibes::PlatformCallbacks.stubs(:find_callback_for)
                               .with(company_key, subscription_added_identifier)
                               .returns([subscription_added_callback])
          end

          let(:subscription_added_callback_id) { subscription_added_callback['callback_id'] }

          it 'uses the delete method w/ correct args' do
            Vibes::PlatformCallbacks.expects(:delete).with(company_key, subscription_added_callback_id)

            Vibes::PlatformCallbacks.change_url(company_key, subscription_added_identifier, new_url)
          end
        end
      end

      describe 'specific to callback type' do
        before(:each) do
          Vibes::PlatformCallbacks.stubs(:find_callback_for)
                             .with(company_key, subscription_added_identifier)
                             .returns([subscription_added_callback])

          Vibes::PlatformCallbacks.stubs(:find_callback_for)
                             .with(company_key, subscription_removed_identifier)
                             .returns([subscription_removed_callback])

          Vibes::PlatformCallbacks.stubs(:find_callback_for)
                             .with(company_key, ack_participant_changed_identifier)
                             .returns([ack_participant_changed_callback])

          Vibes::PlatformCallbacks.stubs(:find_callback_for)
                             .with(company_key, ack_participant_added_identifier)
                             .returns([ack_participant_added_callback])
        end

        describe 'changing a subscription_added callback' do
          it 'calls create_subscription_added w/ correct arguments' do
            Vibes::PlatformCallbacks.expects(:create_subscription_added).with(company_key, subscription_added_identifier, new_url)

            Vibes::PlatformCallbacks.change_url(company_key, subscription_added_identifier, new_url)
          end
        end

        describe 'changing a subscription_removed callback' do
          it 'calls create_subscription_removed w/ correct args' do
            Vibes::PlatformCallbacks.expects(:create_subscription_removed).with(company_key, subscription_removed_identifier, new_url)

            Vibes::PlatformCallbacks.change_url(company_key, subscription_removed_identifier, new_url)
          end
        end

        describe 'changing a ack_participant_changed callback' do
          it 'calls create_participant_changed w/ correct args' do
            Vibes::PlatformCallbacks.expects(:create_participant_changed).with(company_key, ack_participant_changed_identifier, new_url)

            Vibes::PlatformCallbacks.change_url(company_key, ack_participant_changed_identifier, new_url)
          end
        end

        describe 'changing a ack_participant_added callback' do
          it 'calls create_participant_added w/ correct args' do
            Vibes::PlatformCallbacks.expects(:create_participant_added).with(company_key, ack_participant_added_identifier, new_url)

            Vibes::PlatformCallbacks.change_url(company_key, ack_participant_added_identifier, new_url)
          end
        end
      end
    end
  end
end
