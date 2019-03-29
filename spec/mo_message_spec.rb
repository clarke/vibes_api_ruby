require 'spec_helper'

# specs/tests
describe Vibes::MoMessage do

  let(:request_body) { '<?xml version="1.0" encoding="UTF-8"?><moMessage messageId="1132c1d2-5236-4631-9c6f-43f6049cd76b" receiptDate="2016-12-04 16:47:44-0600" attemptNumber="1"><source address="+15125551212" carrier="104" type="MDN" /><destination address="63901" type="SC" /><message>test</message></moMessage>' }

  describe "parse_mo_message" do
    it "parses the request body" do
      mo = Vibes::MoMessage.parse(request_body)
      expect(mo.mdn).to eq("+15125551212")
      expect(mo.message).to eq("test")
      expect(mo.carrier).to eq("104")
      expect(mo.short_code).to eq("63901")
    end
  end

end