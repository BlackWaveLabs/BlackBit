module Coin
  def self.config(iso_code)
    @@config[iso_code.to_sym][Rails.env].symbolize_keys
  end
  
  def self.set(hash)
    @@config = hash
  end
end
