##
# convenience class to parse mo message from MessageApi
#
# USAGE: MoMessage.parse(request.body.read)
#
# returns MoMessage object
#
# @attr mdn [String] mobile device number
# @attr carrier [String] carrier code
# @attr short_code [String] short code message was delivered to
# @attr message [String] body of MO message
# @attr messageId [String] MO message message id
# @attr receiptDate [String] MO message receipt date
# @attr attemptNumber [String] MO message delivery attempt number
#
##
module Vibes

  class MoMessage
    include SAXMachine

    element :source, value: :address, as: :mdn
    element :source, value: :carrier, as: :carrier
    element :destination, value: :address, as: :short_code
    element :message
    element :messageId
    element :receiptDate
    element :attemptNumber

  end
end

