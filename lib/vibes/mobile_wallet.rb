module Vibes

  class MobileWallet
    extend ApiMethods

    ##
    # Update an installed mobile wallet item
    #
    # @param company_key [String] Vibes API key for company
    # @param wallet_id  [String] ID of mobile wallet campaign item belongs to
    # @param wallet_item_id [String] UUID of wallet item to update
    # @param fields  [Hash] Hash of all fields to be updated
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.update_wallet_item(company_key, wallet_id, wallet_item_id, fields = {})
      put "/companies/#{company_key}/campaigns/wallet/#{wallet_id}/items/#{wallet_item_id}", fields.to_json
    end

    ##
    # Get an installed wallet item
    #
    # @param company_key [String] Vibes API key for company
    # @param wallet_id  [String] ID of mobile wallet campaign item belongs to
    # @param wallet_item_id [String] UUID of wallet item to get
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.get_wallet_item(company_key, wallet_id, wallet_item_id)
      get "/companies/#{company_key}/campaigns/wallet/#{wallet_id}/items/#{wallet_item_id}"
    end

    ##
    # Gets a list of all installed wallet items for a specific wallet campaign
    #
    # @param company_key [String] Vibes API key for company
    # @param wallet_id  [String] ID of mobile wallet campaign
    # @param group_code [String] Optional search filter - only return items with group code
    #
    # @return [Array] JSON Response body from mobile db
    ##
    def self.get_wallet_items(company_key, wallet_id, group_code = nil)
      group_code = "?group_code=#{group_code}" if group_code
      get "/companies/#{company_key}/campaigns/wallet/#{wallet_id}/items#{group_code}"
    end

    ##
    # Gets a list of all wallet campaigns for a specific company
    #
    # @param company_key [String] Vibes API key for company
    #
    # @return [Array] JSON Response body from mobile db
    ##
    def self.get_wallet_campaigns(company_key)
      get "/companies/#{company_key}/campaigns/wallet"
    end

    ##
    # Get a wallet campaign record by wallet id (for specified company)
    #
    # @param company_key [String] Vibes API key for company
    # @param wallet_id  [String] ID of mobile wallet campaign
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.get_wallet_campaign(company_key, wallet_id)
      get "/companies/#{company_key}/campaigns/wallet/#{wallet_id}"
    end

    ##
    # Create a new Wallet Message and immediately begin sending it out to the targeted Wallet Items
    # See https://developer.vibes.com/display/APIs/Wallet+Manager+Messaging+APIs for more info
    #
    # @param company_key [String] Vibes API key for company
    # @param wallet_id [String] Wallet object to send message to
    # @param message [Hash] Message content to send. Must contain template and header keys. Must contain either :header_url or :image_url key.
    # @param filter_name [String] Name of filter to apply
    # @param filter_selector [String] Mode to apply filter; options vary per filter
    # @param filter_value [String] Value to supply for filter
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.create_generic_wallet_message(company_key, wallet_id, message, filter_name, filter_selector, filter_value)
      unless [:template, :header].all? {|k| message.key?(k)}
        raise "message param hash must contain :template and :header keys"
      end

      unless [:header_url, :image_url].any? {|k| message.key?(k)}
        raise "message param hash must contain either :header_url or :image_url key"
      end

      body = {
          message: message,
          filters: [
              {
                  name: filter_name,
                  selector: filter_selector,
                  value: filter_value
              }
          ]
      }
      post "/companies/#{company_key}/campaigns/wallet/#{wallet_id}/messages", body.to_json
    end

    ##
    # Create a new Wallet Message and immediately begin sending it out to the targeted Wallet Items
    # See https://developer.vibes.com/display/APIs/Wallet+Manager+Messaging+APIs for more info
    #
    # @param company_key [String] Vibes API key for company
    # @param wallet_id [String] Wallet object to send message to
    # @param group_code [String] Set of wallet items to target for message
    # @param message [Hash] Message content to send. Must contain template and header keys. Must contain either :header_url or :image_url key.
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.create_wallet_message(company_key, wallet_id, group_code, message)
      create_generic_wallet_message(company_key, wallet_id, message, 'group_code', 'starts_with', group_code)
    end

    ##
    # Create a new Wallet Message and immediately begin sending it out to the targeted Wallet Items
    # See https://developer.vibes.com/display/APIs/Wallet+Manager+Messaging+APIs for more info
    #
    # @param company_key [String] Vibes API key for company
    # @param wallet_id [String] Wallet object to send message to
    # @param window_start [DateTime] Only wallet installs w/ expiration_date after this time will receive message
    # @param window_end [DateTime] Only wallet installs w/ expiration_date before this time will receive message
    # @param message [Hash] Message content to send. Must contain template and header keys. Must contain either :header_url or :image_url key.
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.create_wallet_message_by_time_window(company_key, wallet_id, message, window_start, window_end)
      # this matches example at https://developer.vibes.com/display/APIs/Wallet+Manager+Messaging+APIs
      strftime_format = '%Y-%m-%dT%H:%M:%S%:z'

      create_generic_wallet_message(
          company_key,
          wallet_id,
          message,
          'expiration_date',
          'between',
          [window_start.strftime(strftime_format), window_end.strftime(strftime_format)]
      )
    end

    ##
    # Create a new Wallet Message and immediately begin sending it out to the targeted Wallet Items
    # See https://developer.vibes.com/display/APIs/Wallet+Manager+Messaging+APIs for more info
    #
    # @param company_key [String] Vibes API key for company
    # @param wallet_id [String] Wallet object to send message to
    # @param date [DateTime] Only wallet installs w/ this expiration date will get notifications. Time portion of string is ignored.
    # @param message [Hash] Message content to send. Must contain template and header keys. Must contain either :header_url or :image_url key.
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.create_wallet_message_for_date(company_key, wallet_id, message, date)
      # this matches example at https://developer.vibes.com/display/APIs/Wallet+Manager+Messaging+APIs
      strftime_format = '%Y-%m-%dT%H:%M:%S%:z'

      create_generic_wallet_message(
          company_key,
          wallet_id,
          message,
          'expiration_date',
          'on',
          date.strftime(strftime_format)
      )
    end
  end
end

