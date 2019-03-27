class Events
  extend ApiMethods

  ##
  #  Submit a new event into the system
  #
  # @param company_key [String] Vibes API key for company
  # @param event_type [String] Valid characters in the event_type field are alphanumeric, dash and underscore. event_type values are NOT case sensitive.
  # @param event_data [Hash] The event_data object is a placeholder object that can contain any useful data relevant to the event.
  # @param debug_data [Hash] Used to provide upstream system information to help customer's diagnose how/when an event was generated.
  #
  # @return [Hash] Event entity
  ##
  def self.create_event(company_key, event_type, event_data={}, debug_data={}, event_id=nil)
    body = {
      event_type: event_type,
      event_data: event_data,
      debug_data: debug_data
    }
    body[:event_id] = event_id unless event_id.nil?
    post("/companies/#{company_key}/events", body.to_json)
  end

  ##
  #  View all events for a specific company. NOTE: This must be used on a Vibes IP
  #
  # @param company_id [String] Company ID found here https://auth.vibescm.com/admin/company
  #
  # @return [Hash] All Events for company
  ##
  def self.get_events(company_id)
    get("/MessageRouter/event/companies/#{company_id}/types", {host: 'http://internalapps.cloud.vibes.com'})
  end

  ##
  #  Delete an event from the system. NOTE: This must be used on a Vibes IP
  #
  # @param company_id [String] Company ID found here https://auth.vibescm.com/admin/company
  # @param event_name [String] Valid characters in the event_type field are alphanumeric, dash and underscore. event_type values are NOT case sensitive.
  #
  # @return [Hash] Status
  ##
  def self.delete_event(company_id, event_name)
    delete("/MessageRouter/event/companies/#{company_id}/types/#{event_name}", {host: 'http://internalapps.cloud.vibes.com'})
  end

end
