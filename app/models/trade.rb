class Trade
  include Mongoid::Document
  include Mongoid::Timestamps

  field :paid,                  type: Boolean, default: false
  field :initiated_at,          type: Time
  field :blackcoin_amount,      type: BigDecimal
  field :blackcoin_margin,      type: BigDecimal
  field :blackcoin_address,     type: String
  field :bitcoin_amount,        type: BigDecimal
  field :bitcoin_address,       type: String
  field :bitcoin_txid,          type: String
  field :account_id,            type: String
  field :ip_address,            type: String
  field :refund_address,        type: String
  field :refund_txid,           type: String
  field :profit_paid,           type: Boolean, default: false
  
  has_one :account

  validates_numericality_of :bitcoin_amount, greater_than: 0, less_than_or_equal_to: 1, message: "Invalid amount."
  validates_presence_of :bitcoin_address, :bitcoin_amount, message: "Input required."
  validate :check_format, on: :create
  validate :check_duplicate_ip, on: :create
  validate :bank_check, on: :create

  after_create :calculate_rates
  def calculate_rates
    Site.settings.fetch_prices
    self.blackcoin_amount = (self.bitcoin_amount * Site.settings.blackcoin_trade_price.to_money)
    self.blackcoin_margin = (self.bitcoin_amount * Site.settings.calculated_margin.to_money)
    
    # create new account
    w = Wallet.where(iso_code: "BC").first
    bc = w.new_account("bcbit-" + self.id)
    trade_account = Account.create(name: bc.name, address: bc.addresses.first, trade_id: self.id, wallet_id: w.id, iso_code: w.iso_code)

    self.account_id = trade_account.id
    self.blackcoin_address = trade_account.address
    
    self.save
  end
  
  def issue_refund
    if !self.refund_address.nil? and self.status == "failed"
      Wallet.blackcoin.refund(self)
      if refund_txid
        self.refund
      end
    end
  end

  def check_format
    unless (self.bitcoin_amount =~ /^[0-9]+(\.[0-9]{1,8})?$/).nil?
      errors.add(:bitcoin_amount, "Invalid amount.")
    end
    unless !!(self.bitcoin_address =~ /^[13][a-km-zA-HJ-NP-Z0-9]{26,33}$/)
      errors.add(:bitcoin_address, "Invalid address.")
    end
  end
  
  def check_duplicate_ip
    active_trade = Trade.where(ip_address: self.ip_address, status: "pending").first
    if active_trade
      errors.add(:bitcoin_address, "You can only have one active trade at a time.")
    end
  end
  
  def account
    Account.where(name: "bcbit-#{self.id}").first
  end
   
  def bank_check
    if self.bitcoin_amount.to_f > Site.settings.bank_balance.to_f
      errors.add(:bitcoin_amount, "Bitcoin bank running low. Try again soon.")
    end
  end
  
  def check_status
    self.calculate_rates if self.account.nil?
    if (self.created_at + Site.settings.minutes_to_complete.minutes) < Time.now
      self.time_ran_out
    end
    if self.status == "cancelled" and self.account.unconfirmed_balance > 0
      self.transfer_late
    end
  end

  def received_transaction
    if self.status == "pending"
      self.complete_trade
    elsif self.status == "cancelled" and self.account.unconfirmed_balance > 0
      self.transfer_late
    elsif (self.initiated_at + Site.settings.minutes_to_complete.minutes) < Time.now
      self.time_ran_out
    end
  end

  def complete_trade
    if self.account.confirmed_balance.to_f >= self.blackcoin_amount
      self.coins_received
      Wallet.bitcoin.send_to(self)
      if self.bitcoin_txid
        self.coins_sent
      else
        self.transfer_failed
      end
    elsif  self.account.unconfirmed_balance.to_f < self.blackcoin_amount
      self.not_enough_coins
    end
  end

  state_machine :status, :initial => :pending do
    event :coins_received do
      transition :pending => :processing
    end
    
    event :coins_sent do
      transition :processing => :completed
    end

    event :not_enough_coins do
      transition :pending => :failed
    end

    event :time_ran_out do
      transition :pending => :cancelled
    end
    
    event :transfer_failed do
      transition :processing => :cancelled
    end
    
    event :transfer_late do
      transition :cancelled => :failed
    end
    
    event :refund do
      transition :failed => :refunded
    end
  end
end
