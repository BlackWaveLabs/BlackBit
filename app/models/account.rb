class Account
  include Mongoid::Document

  field :name,                  type: String
  field :iso_code,              type: String
  field :address,               type: String
  field :unconfirmed_balance,   type: Money, default: 0
  field :confirmed_balance,     type: Money, default: 0
  field :total_received,        type: Money, default: 0

  field :wallet_id,             type: String
  field :trade_id,              type: String
  field :address,               type: String

  field :profit_failed,         type: Boolean, default: false

  belongs_to :wallet

  belongs_to :trade
  embeds_many :transactions

  validates_uniqueness_of :name, message: "Name must be unique."
  validates_presence_of :wallet_id,  message: "Wallet ID required."

  def trade
    Trade.find(self.trade_id)
  end

  #shortcuts
  def currency_name
    self.wallet.currency.name
  end

  def currency_symbol
    self.wallet.currency.symbol
  end

  def wallet
    Wallet.find(self.wallet_id)
  end


  def update_account
    self.update_attributes(unconfirmed_balance: self.wallet.balance_by_account(self.name, 0),
                           confirmed_balance: self.wallet.balance_by_account(self.name, 1),
                           total_received: self.wallet.total_received_by_account(self.name)
                           )
  end

  def transaction
    transactions.first
  end

  def payout_profit
    begin
      p self.wallet_account.send_amount((self.confirmed_balance.to_f - 0.02), to: Coin.config("BC")[:profitaddress])
      p "Payout SUCCESS #{self.confirmed_balance.to_f} to #{Coin.config("BC")[:profitaddress]}."
      return true
    rescue
      p "Payout failed #{self.confirmed_balance.to_f} to #{Coin.config("BC")[:profitaddress]}."
      self.update_attributes(profit_failed: true)
      return false
    end
  end

  def wallet_account
    account = self.wallet.account_by_name(self.name)
    return account
  end

end
