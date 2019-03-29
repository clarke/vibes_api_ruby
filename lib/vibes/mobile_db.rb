module Vibes

  class MobileDb
    extend ApiMethods

    ##
    # Check if Vibes API is newer than 1
    # raise error if it is new API and not in proper E.164 international MDN format
    #
    # @param mdn [String] mdn of person
    #
    ##
    def self.check_vibes_api_version(mdn)
      if api_version.to_i < 2
        return mdn
      end

      # For International numbers we need to be passed the + and country code with the number, can't assume its US only
      if mdn.to_s.first != "+"
        raise "\nYou are using the newer verison of Vibes API, which requires MDN to be in the E.164 international MDN format\n"
      else
        return mdn.gsub("+", "%2B")
      end

    end

    ##
    # Retrieve person data from mobile db.
    #
    # @param company_key [String] Vibes API key for company
    # @param mdn [String] mdn of person to retrieve
    #
    # @return [Array] Array of Hashes representing Person objects found for mdn
    ##
    def self.find_person(company_key, mdn)
      mdn = self.check_vibes_api_version(mdn)
      get "/companies/#{company_key}/mobiledb/persons?mdn=#{mdn}"
    end

    ##
    # Retrieve person data from mobile db.
    #
    # @param company_key [String] Vibes API key for company
    # @param person_id [String] Person ID of person to retrieve
    #
    # @return [Hash] JSON Person object from mobile db
    ##
    def self.get_person(company_key, person_id)
      get "/companies/#{company_key}/mobiledb/persons/#{person_id}"
    end

    ##
    # Retrieve person data from mobile db via person-url
    #
    # @param person_url [String] Full person URL (usually returned by API calls or callbacks)
    #
    # @return [Hash] JSON Person object from mobile db
    ##
    def self.get_person_by_url(person_url)
      get person_url
    end

    ##
    # Retrieve person data from mobile db via external person id.
    #
    # @param company_key [String] Vibes API key for company
    # @param external_person_id [String] External Person ID of person to retrieve
    #
    # @return [Hash] JSON Person object from mobile db
    ##
    def self.get_external_person(company_key, external_person_id)
      get "/companies/#{company_key}/mobiledb/persons/external/#{external_person_id}"
    end

    ##
    # Create a person in mobile db
    #
    # @param company_key [String] Vibes API key for company
    # @param custom_fields  [Hash] Hash of all fields to be added
    # @param mobile_phone  [String] MDN for the person
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.add_person(company_key, custom_fields, mobile_phone = nil)
      self.check_vibes_api_version(mobile_phone)
      body = {
          custom_fields: custom_fields
      }
      unless mobile_phone.nil?
        body[:mobile_phone] = {
            mdn: VibesApi.clean_mdn(mobile_phone)
        }
      end
      post "/companies/#{company_key}/mobiledb/persons", body.to_json
    end

    ##
    # Update person data in mobile db
    #
    # @param company_key [String] Vibes API key for company
    # @param person_id  [String] ID of person in MobileDb
    # @param fields  [Hash] Hash of all fields to be updated
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.update_person(company_key, person_id, fields)
      put "/companies/#{company_key}/mobiledb/persons/#{person_id}", fields.to_json
    end

    def self.update_external_person(company_key, external_person_id, fields)
      put "/companies/#{company_key}/mobiledb/persons/external/#{external_person_id}", fields.to_json
    end

    ##
    # Subscribe mdn, and custom attributes to mobile db acquisition campaign.
    #
    # @param company_key [String] Vibes API key for company
    # @param acquisition_id  [String]   Vibes API key for acquisition campaign belonging to company
    # @param mobile_phone  [String] MDN to subscribe
    # @param custom_fields [Hash]     Hash of custom attributes for Person subscribing
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.subscribe(company_key, acquisition_id, mobile_phone, custom_fields = {})
      self.check_vibes_api_version(mobile_phone)
      body = {
          mobile_phone: {
              mdn: VibesApi.clean_mdn(mobile_phone)
          },
          custom_fields: custom_fields
      }
      post "/companies/#{company_key}/campaigns/acquisition/#{acquisition_id}/participants", body.to_json
    end

    ##
    # Subscribe mdn, external_id and custom attributes to mobile db acquisition campaign.
    #
    # @param company_key [String] Vibes API key for company
    # @param acquisition_id  [String]   Vibes API key for acquisition campaign belonging to company
    # @param mobile_phone  [String] MDN to subscribe
    # @param external_id  [String] external_person_id to be set on user
    # @param custom_fields [Hash]     Hash of custom attributes for Person subscribing
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.subscribe_external_id(company_key, acquisition_id, mobile_phone, external_id, custom_fields = {})
      self.check_vibes_api_version(mobile_phone)
      body = {
          external_person_id: external_id,
          mobile_phone: {
              mdn: VibesApi.clean_mdn(mobile_phone)
          },
          custom_fields: custom_fields
      }
      post "/companies/#{company_key}/campaigns/acquisition/#{acquisition_id}/participants", body.to_json
    end

    ##
    # Unsubscribe person from the specified subscription_list
    #
    # @param company_key [String] Vibes API key for company
    # @param person_id [String]   ID of Person to unsubscribe
    # @param subscription_list_id  [String] ID of subscription list to remove person from
    #
    # @return [Hash] JSON Response body from mobile db
    ##
    def self.unsubscribe(company_key, person_id, subscription_list_id)
      delete "/companies/#{company_key}/mobiledb/persons/#{person_id}/subscriptions/#{subscription_list_id}"
    end

    ##
    # Get a list of all subscriptions for a person id
    #
    # @param company_key [String] Vibes API key for company
    # @param person_id [String] ID of person in mobile db
    #
    # @return [Array] Array of Hashes representing Subscriptions objects
    ##
    def self.get_subscriptions(company_key, person_id)
      get "/companies/#{company_key}/mobiledb/persons/#{person_id}/subscriptions"
    end

    ##
    # Retrieve person data from mobile db if mdn is present in the subscription list in the company
    #
    # @param company_key [String] Vibes API key for company
    # @param list_id [String] List ID of subscription list for company in mobile db
    # @param mdn [String] mdn of person to retrieve
    #
    # @return [Hash] JSON Person Object from mobile
    ##
    def self.get_person_if_subscribed_by_mdn(company_key, list_id, mdn)
      mdn = self.check_vibes_api_version(mdn)
      get "/companies/#{company_key}/mobiledb/subscription_lists/#{list_id}/subscribers?mdn=#{mdn}"
    end

    ##
    # Retrieve person data from mobile db if person_id is present in the subscription list in the company
    #
    # @param company_key [String] Vibes API key for company
    # @param list_id [String] List ID of subscription list for company in mobile db
    # @param person_id [String] id of person to retrieve
    #
    # @return [Hash] JSON Person Object from mobile
    ##
    def self.get_person_if_subscribed_by_person_id(company_key, list_id, person_id)
      get "/companies/#{company_key}/mobiledb/subscription_lists/#{list_id}/subscribers?person_id=#{person_id}"
    end

    ##
    # Retrieve person data from mobile db if external_person_id is present in the subscription list in the company
    #
    # @param company_key [String] Vibes API key for company
    # @param list_id [String] List ID of subscription list for company in mobile db
    # @param external_person_id [String] external id of person to retrieve
    #
    # @return [Hash] JSON Person Object from mobile
    ##
    def self.get_person_if_subscribed_by_external_person_id(company_key, list_id, external_person_id)
      get "/companies/#{company_key}/mobiledb/subscription_lists/#{list_id}/subscribers?external_person_id=#{external_person_id}"
    end

    ##
    # This will return the Subscription List Object for the specified ID
    #
    # @param company_key [String] Vibes API key for company
    # @param subscription_list_id  [String] ID of subscription list to get
    #
    # @return [Hash] Subscription list object
    ##
    def self.get_subscription_list(company_key, subscription_list_id)
      get "/companies/#{company_key}/mobiledb/subscription_lists/#{subscription_list_id}"
    end

    ##
    # This will return all the Subscription Lists in the Mobile Database for the specified company.
    #
    # @param company_key [String] Vibes API key for company
    #
    # @return [Hash] An Array of Subscription List Objects
    ##
    def self.get_subscription_lists(company_key)
      get "/companies/#{company_key}/mobiledb/subscription_lists"
    end

    ##
    # This will return an array of active Acquisition Campaign references that point to the specified Subscription List.
    #
    # @param company_key [String] Vibes API key for company
    # @param subscription_list_id  [String] ID of subscription list to get campaigns for
    #
    # @return [Hash] An Array of the Acquisition Campaign objects
    ##
    def self.get_acquisition_campaigns(company_key, subscription_list_id)
      get "/companies/#{company_key}/mobiledb/subscription_lists/#{subscription_list_id}/acquisition_campaigns"
    end

    ##
    # This will return an array of active Acquisition Campaign references that point to the specified Subscription List.
    #
    # @param company_key [String] Vibes API key for company
    # @param acquisition_id [String] ID of Acquisition campaign to fetch
    #
    # @return [Hash] Acquisition Campaign object
    ##
    def self.get_acquisition_campaign(company_key, acquisition_id)
      get "/companies/#{company_key}/campaigns/acquisition/#{acquisition_id}"
    end

    ## get_subscription_stream has been moved to the InternalDb class
    class << self
      delegate :get_subscription_stream, to: :InternalDb
    end
  end
end

