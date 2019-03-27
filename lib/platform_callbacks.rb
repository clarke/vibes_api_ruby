class PlatformCallbacks
  extend ApiMethods
  ##
  # Register a Subscription Added callback endpoint (for specified company)
  #
  # @param company_key [String] Vibes API key for company
  # @param subscription_list_id  [String] ID of subscription list to register callback for
  # @param destination_url  [String] URL to receive callback
  #
  # @return [Hash] JSON Response body from mobile db
  ##
  def self.create_subscription_added(company_key, subscription_list_id, destination_url)
    create company_key, {
        event_type: "subscription_added",
        subscription_added: {
            list_id: subscription_list_id
        },
        destination: {
            url: destination_url,
            method: "POST",
            content_type: "application/json"
        }
    }
  end

  ##
  # Register a Subscription Removed callback endpoint (for specified company)
  #
  # @param company_key [String] Vibes API key for company
  # @param subscription_list_id  [String] ID of subscription list to register callback for
  # @param destination_url  [String] URL to receive callback
  #
  # @return [Hash] JSON Response body from mobile db
  ##
  def self.create_subscription_removed(company_key, subscription_list_id, destination_url)
    create company_key, {
        event_type: "subscription_removed",
        subscription_added: {
            list_id: subscription_list_id
        },
        destination: {
            url: destination_url,
            method: "POST",
            content_type: "application/json"
        }
    }
  end

  ##
  # Register a Participant Changed callback endpoint (for specified company)
  #
  # @param company_key [String] Vibes API key for company
  # @param acquisition_id  [String] API key of Acquistion campgin to register callback for
  # @param destination_url  [String] URL to receive callback
  #
  # @return [Hash] JSON Response body from mobile db
  ##
  def self.create_participant_changed(company_key, acquisition_id, destination_url)
    create company_key, {
        event_type: "ack_participant_changed",
        ack_participant_changed: {
            campaign_id: acquisition_id
        },
        destination: {
            url: destination_url,
            method: "POST",
            content_type: "application/json"
        }
    }
  end

  ##
  # Register a Participant Added callback endpoint (for specified company)
  #
  # @param company_key [String] Vibes API key for company
  # @param acquisition_id  [String] API key of Acquistion campgin to register callback for
  # @param destination_url  [String] URL to receive callback
  #
  # @return [Hash] JSON Response body from mobile db
  ##
  def self.create_participant_added(company_key, acquisition_id, destination_url)
    create company_key, {
        event_type: "ack_participant_added",
        ack_participant_added: {
            campaign_id: acquisition_id
        },
        destination: {
            url: destination_url,
            method: "POST",
            content_type: "application/json"
        }
    }
  end

  def self.create(company_key, body)
    MobileDb.post "/companies/#{company_key}/config/callbacks/", body.to_json
  end


  ##
  # List all Callbacks registered (for specified company)
  #
  # @param company_key [String] Vibes API key for company
  # 
  #
  # @return [Hash] JSON Response body from mobile db
  ##
  def self.list(company_key)
    MobileDb.get "/companies/#{company_key}/config/callbacks/"
  end

  ##
  # Delete a Callback registration (for specified company)
  #
  # @param company_key [String] Vibes API key for company
  # @param callback_id [String] ID of callback registration to delete
  # 
  #
  # @return [Hash] JSON Response body from mobile db
  ##
  def self.delete(company_key, callback_id)
    MobileDb.delete "/companies/#{company_key}/config/callbacks/#{callback_id}"
  end

  ##
  # Find a specific Callback registration (for specified company)
  #
  # @param company_key [String] Vibes API key for company
  # @param identifier [String] Callback type to retrieve
  # @option identifier [String] ack_participant_added
  # @option identifier [String] ack_participant_changed
  # @option identifier [String] subscription_added
  # @option identifier [String] subscription_removed
  # 
  #
  # @return [Hash] JSON Response body from mobile db
  ##
  def self.find_callback_for(company_key, identifier)
    list(company_key).select do |callback|
      callback.try(:[], 'ack_participant_added').try(:[], 'campaign_id') == identifier ||
          callback.try(:[], 'ack_participant_changed').try(:[], 'campaign_id') == identifier ||
          callback.try(:[], 'subscription_added').try(:[], 'list_id') == identifier ||
          callback.try(:[], 'subscription_removed').try(:[], 'list_id') == identifier
    end
  end

  ##
  # Change destination endpoint for a specific Callback registration (for specified company)
  #
  # @param company_key [String] Vibes API key for company
  # @param identifiers [Array] Callback type(s) to update
  # @option identifier [String] ack_participant_added
  # @option identifier [String] ack_participant_changed
  # @option identifier [String] subscription_added
  # @option identifier [String] subscription_removed
  # @param new_url [String] New destination URL for callback
  # 
  #
  # @return [Hash] JSON Response body from mobile db
  ##
  def self.change_url(company_key, identifiers, new_url, debug = false)
    identifiers = identifiers.is_a?(Array) ? identifiers : [identifiers]

    identifiers.each do |identifier|
      existing_callback = find_callback_for(company_key, identifier)
      puts "existing_callback: #{existing_callback}" if debug

      existing_callback.each do |c|
        deleted_callback = delete(company_key, c['callback_id'])
        puts "deleted_callback: #{deleted_callback}" if debug
      end

      existing_callback.each do |c|
        callback_type = c['event_type'].gsub(/^ack_/, '')
        created_callback = send("create_#{callback_type}", company_key, identifier, new_url)
        puts "created_callback: #{created_callback}" if debug
      end
    end
  end
end