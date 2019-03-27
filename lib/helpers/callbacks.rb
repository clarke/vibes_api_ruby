module Helpers
  module Callbacks
    ### Subscription Helpers

    # convenience class to parse JSON callbacks from public-api, such as subscription, person, or acquisition
    #
    # USAGE: JSONCallback.parse(request.body.read)
    #
    # returns Callback object
    #
    # @attr Attributes are based on the callback JSON being parsed. Each key will be an attribute, if the key is to a nested JSON object, it will then be it's own obeject
    # For subscription_added callback... JSONCallback.parse(request.body.read).subscription.person.person_id
    class JSONCallback
      def self.parse(json_body)
        JSON.parse json_body, object_class: OpenStruct
      end
    end

    #########################

  end
end
