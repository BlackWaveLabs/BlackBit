class Site
  include Mongoid::Document
  field :blackcoin_last_price,         type: BigDecimal
  field :blackcoin_price_per_bitcoin,  type: BigDecimal
  field :margin,                       type: Float,        default: 0.45
  field :calculated_margin,            type: BigDecimal
  field :online,                       type: Boolean,      default: true
  field :minutes_to_complete,          type: Integer,      default: 3
  
  validate :there_can_only_be_one, on: :create
  def there_can_only_be_one
    if Site.settings
      errors.add(:online, "Only one site config allowed.")
    end
  end
  
  after_create :initialize_site
  def initialize_site
    self.fetch_prices
    Wallet.create(iso_code: "BC")
    Wallet.create(iso_code: "BTC")
  end
  
  def self.settings
    Site.first
  end
  
  def payout_site_profit
    Trade.where(status: "completed", profit_paid: false).each do |t|
      if t.account.payout_profit
        t.update_attributes(profit_paid: true)
      end
    end
  end

  def blackcoin_trade_price
    site = Site.settings
    return (site.blackcoin_price_per_bitcoin + site.calculated_margin)
  end
  
  def bank_wallet
    Wallet.where(iso_code: "BTC").first
  end
  
  def bank_account
    Account.where(iso_code: "BTC").first
  end
  
  def update_bank_balance
    self.bank_account.update_account
  end
  
  def active_trade_balance
    trade_balance = 0.to_money
    Trade.where(state: "pending").each do |t|
      trade_balance += t.bitcoin_amount
    end
    return trade_balance
  end
  
  def bank_balance
    self.bank_wallet.balance_by_account(self.bank_account.name, 1) - self.active_trade_balance
  end
  
  def fetch_prices
    # Would be best to average among several exchanges
    if uri = URI('https://api.mintpal.com/v1/market/stats/BC/BTC') 
      market_data = JSON.parse(Net::HTTP.get(uri)).first
     
      site = Site.settings
     
      site.blackcoin_last_price = BigDecimal.new(market_data['last_price'])
      site.blackcoin_price_per_bitcoin = BigDecimal.new(1) / BigDecimal.new(site.blackcoin_last_price)
      
      site.calculated_margin = site.blackcoin_price_per_bitcoin / ( margin * 100 )
      
      site.save
      return true
    else
      return false
    end
  end
end
