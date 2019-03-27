class CustomFields
  include ApiMethods

  def initialize(company_id)
    if company_id.to_s.upcase.match(/[A-Z]/)
      raise "Invalid Company ID! Company ID's are all numeric and found in https://auth.vibescm.com"
    else
      @company_id = company_id
    end
  end

  #
  # General purpose methods
  #

  def get_fields
    get "/api/companies/#{@company_id}/person_fields"
  end

  def get_field(id)
    get "/api/companies/#{@company_id}/person_fields/#{id}"
  end

  def create_field(custom_field)
    post "/api/companies/#{@company_id}/person_fields", custom_field.to_json
  end

  def update_field(id, custom_field)
    put "/api/companies/#{@company_id}/person_fields/#{id}", custom_field.to_json
  end

  def delete_field(id)
    delete "/api/companies/#{@company_id}/person_fields/#{id}"
  end

  #
  # Shortcut methods created using the examples noted in the Developer Wiki:
  # https://developer.vibes.com/display/API/Common+Custom+fields
  #

  def create_first_name_field(charset = 'ascii')
    create_field({
      name: "first_name",
      description: "First Name",
      default_value: "",
      type: "string",
      filterable: false,
      personalizable: true,
      charset: charset
    })
  end

  def create_last_name_field(charset = 'ascii')
    create_field({
      name: "last_name",
      description: "Last Name",
      default_value: "",
      type: "string",
      filterable: false,
      personalizable: true,
      charset: charset
    })
  end

  def create_email_field(charset = 'ascii')
    create_field({
      name: "email",
      description: "Email",
      default_value: "",
      type: "string",
      filterable: false,
      personalizable: false,
      charset: charset
    })
  end

  def create_postal_code_field(charset = 'ascii')
    create_field({
      name: "zip_code",
      description: "Zip Code",
      default_value: "",
      type: "postal_code",
      filterable: false,
      personalizable: true,
      charset: charset
    })
  end

  def create_zip_code_field(charset = 'ascii')
    create_field({
      name: "zip_code",
      description: "Zip Code",
      default_value: "",
      type: "string",
      filterable: true,
      personalizable: true,
      charset: charset
    })
  end

  def create_birthdate_field(charset = 'ascii')
    create_field({
      name: "birthdate",
      description: "Birthdate",
      type: "date",
      filterable: true,
      personalizable: false,
      charset: charset
    })
  end

  def create_gender_field(charset = 'ascii')
    create_field({
      name: "gender",
      description: "Gender",
      type: "single_select",
      filterable: true,
      personalizable: false,
      charset: charset,
      values:[
        { name: "Male",   option_key: "m", active: true},
        { name: "Female", option_key: "f", active: true}
      ]
    })
  end

  def create_month_field(charset = 'ascii')
    create_field({
      name: "month",
      description: "Month",
      type: "single_select",
      filterable: true,
      personalizable: false,
      charset: charset,
      values:[
        { name: "January",   option_key: "jan", active: true },
        { name: "February",  option_key: "feb", active: true },
        { name: "March",     option_key: "mar", active: true },
        { name: "April",     option_key: "apr", active: true },
        { name: "May",       option_key: "may", active: true },
        { name: "June",      option_key: "jun", active: true },
        { name: "July",      option_key: "jul", active: true },
        { name: "August",    option_key: "aug", active: true },
        { name: "September", option_key: "sep", active: true },
        { name: "October",   option_key: "oct", active: true },
        { name: "November",  option_key: "nov", active: true },
        { name: "December",  option_key: "dec", active: true }
      ]
    })
  end

  def create_state_field(charset = 'ascii')
    create_field({
      name: "state",
      description: "State",
      type: "single_select",
      filterable: true,
      personalizable: false,
      charset: charset,
      values:[
        { name: "AL", option_key: "al", active:true }, { name: "AK", option_key: "ak", active:true },
        { name: "AZ", option_key: "az", active:true }, { name: "AR", option_key: "ar", active:true },
        { name: "CA", option_key: "ca", active:true }, { name: "CO", option_key: "co", active:true },
        { name: "CT", option_key: "ct", active:true }, { name: "DE", option_key: "de", active:true },
        { name: "FL", option_key: "fl", active:true }, { name: "GA", option_key: "ga", active:true },
        { name: "HI", option_key: "hi", active:true }, { name: "ID", option_key: "id", active:true },
        { name: "IL", option_key: "il", active:true }, { name: "IN", option_key: "in", active:true },
        { name: "IA", option_key: "ia", active:true }, { name: "KS", option_key: "ks", active:true },
        { name: "KY", option_key: "ky", active:true }, { name: "LA", option_key: "la", active:true },
        { name: "ME", option_key: "me", active:true }, { name: "MD", option_key: "md", active:true },
        { name: "MA", option_key: "ma", active:true }, { name: "MI", option_key: "mi", active:true },
        { name: "MN", option_key: "mn", active:true }, { name: "MS", option_key: "ms", active:true },
        { name: "MO", option_key: "mo", active:true }, { name: "MT", option_key: "mt", active:true },
        { name: "NE", option_key: "ne", active:true }, { name: "NV", option_key: "nv", active:true },
        { name: "NH", option_key: "nh", active:true }, { name: "NJ", option_key: "nj", active:true },
        { name: "NM", option_key: "nm", active:true }, { name: "NY", option_key: "ny", active:true },
        { name: "NC", option_key: "nc", active:true }, { name: "ND", option_key: "nd", active:true },
        { name: "OH", option_key: "oh", active:true }, { name: "OK", option_key: "ok", active:true },
        { name: "OR", option_key: "or", active:true }, { name: "PA", option_key: "pa", active:true },
        { name: "RI", option_key: "ri", active:true }, { name: "SC", option_key: "sc", active:true },
        { name: "SD", option_key: "sd", active:true }, { name: "TN", option_key: "tn", active:true },
        { name: "TX", option_key: "tx", active:true }, { name: "UT", option_key: "ut", active:true },
        { name: "VT", option_key: "vt", active:true }, { name: "VA", option_key: "va", active:true },
        { name: "WA", option_key: "wa", active:true }, { name: "WV", option_key: "wv", active:true },
        { name: "WI", option_key: "wi", active:true }, { name: "WY", option_key: "wy", active:true }
      ]
    })
  end

  protected

    def hostname
      ENV['MOBILEDB_INTERNAL_API_URL'] || 'http://mobiledb-internal.cloud.vibes.com/'
    end

    def username
      ENV['SHORT_USER']
    end

    def password
      ENV['SHORT_PASS']
    end
end
