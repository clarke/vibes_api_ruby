class Incentives
  extend ApiMethods

  ##
  # Get all Incentive Pools for a company
  #
  # @param company_key [String] Vibes API key for company
  #
  # @return [Array] Array of Incentive Pool hash objects
  ##
  def self.get_pools(company_key)
    get("/companies/#{company_key}/incentives/pools")
  end

  ##
  # Get the specified Incentive Pool for a company
  #
  # @param company_key [String] Vibes API key for company
  # @param pool_id  [Integer] ID of the Incentive Pool
  #
  # @return [Hash] Incentive Pool object
  ##
  def self.get_pool(company_key, pool_id)
    get("/companies/#{company_key}/incentives/pools/#{pool_id}")
  end

  ##
  # Gets the specified incentive code for a company
  #
  # @param company_key [String] Vibes API key for company
  # @param code  [String] Incentive code for company
  #
  # @return [Hash] Incentive code object
  ##
  def self.get_code(company_key, code)
    get("/companies/#{company_key}/incentives/codes/#{code}")
  end

  ##
  # Get a list of all Issuances of a specified code
  #
  # @param company_key [String] Vibes API key for company
  # @param code  [String] Incentive code for company
  #
  # @return [Array] Array of Issuance hash objects
  ##
  def self.get_issuances(company_key, code)
    get("/companies/#{company_key}/incentives/codes/#{code}/issuances")
  end

  ##
  # Get a list of all Redemptions of a specified code
  #
  # @param company_key [String] Vibes API key for company
  # @param code  [String] Incentive code for company
  #
  # @return [Array] Array of Redemption hash objects
  ##
  def self.get_redemptions(company_key, code)
    get("/companies/#{company_key}/incentives/codes/#{code}/redemptions")
  end

  ##
  # Issue an incentive code from a pool
  #
  # @param company_key [String] Vibes API key for company
  # @param pool_id [Integer] Id of the Incentive pool
  # @param external_issuee_id [String] Unique external ID of issuee (usually MDN or email)
  # @param referring_application_ref_id [String] Application reference ID (usually campaign-ID of Incentive campaign)
  # @param args [Hash] Hash of any additional parameters to send with request
  #
  # @return [Hash] Code issuance entity
  ##
  def self.issue_code(company_key, pool_id, external_issuee_id, referring_application_ref_id, args={})
    args[:external_issuee_id]           = external_issuee_id.to_s
    args[:referring_application_ref_id] = referring_application_ref_id.to_s
    args[:referring_application]        = args[:referring_application] || "splat"
    post("/companies/#{company_key}/incentives/pools/#{pool_id}/issuances", args.to_json)
  end

  ##
  # Redeem an issued Incentive code for company
  #
  # @param company_key [String] Vibes API key for company
  # @param code  [String] Incentive code for company
  #
  # @return [Hash] Hash of Incentive code
  ##
  def self.redeem_code(company_key, code)
    post("/companies/#{company_key}/incentives/codes/#{code}/redemptions", "{}")
  end

end