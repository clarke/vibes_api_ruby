class Encoder
  InvalidSmartlink = Class.new(StandardError) do
    def message
      "The smartlink provided is not valid."
    end
  end

  InvalidUUID = Class.new(StandardError) do
    def message
      "The uuid provided is not valid."
    end
  end

  InvalidRSAKey = Class.new(StandardError) do
    def message
      "Please generate a valid RSA key, in a file named private, in the root"/
      "of your applications directory."
    end
  end

  class << self
    def encode!(smartlink, uuid, code = nil)
      raise InvalidSmartlink unless smartlink.present?

      data = payload(uuid, code)

      if rsa_key.present?
        encoded_data = JWT.encode(data, rsa_key, 'RS256')
      else
        raise InvalidRSAKey
      end

      "#{smartlink}?vbs_key=#{encoded_data}"
    end

    private

    def payload(uuid, code)
      raise InvalidUUID unless uuid.present?

      if code.present?
        { "unique_identifier" => uuid.to_s, "data" => { "code" => code.to_s } }
      else
        { "unique_identifier" => uuid.to_s }
      end
    end

    def rsa_key
      if Rails.env.production?
        OpenSSL::PKey::RSA.new(ENV["PRIVATE_KEY"])
      else
        OpenSSL::PKey::RSA.new(File.read('private_key'))
      end
    end
  end
end
