class Wallet
  include Mongoid::Document

  field :balance,             type: Money,    default: 0
  field :transaction_fee,     type: Money
  field :confirmations,       type: Integer,  default: 1
  
  field :last_update,         type: Time,     default: Time.now
  field :transaction_count,   type: Integer,  default: 0
  field :active,              type: Boolean,  default: false
  field :iso_code,            type: String
  
  validates_presence_of :iso_code, message: "ISO code must be specified."

  has_one :currency
  has_many :accounts

  before_validation :set_transaction_fee_iso, on: :update
  def set_transaction_fee_iso
    self.transaction_fee = self.transaction_fee.to_money(self.iso_code)
  end

  after_create :initialize_currency
  def initialize_currency
    @coin = Money::Currency.table[self.iso_code.downcase.to_sym]
    self.create_currency(iso_code: @coin[:iso_code],
                         name: @coin[:name],
                         symbol: @coin[:symbol],
                         symbol_first: @coin[:symbol_first],
                         subunit: @coin[:subunit],
                         subunit_to_unit: @coin[:subunit_to_unit],
                         thousands_separator: @coin[:thousands_separator],
                         decimal_mark: @coin[:decimal_mark]
                        )
    self.balance = Money.new(0, self.iso_code)
    self.user_balance = Money.new(0, self.iso_code)
    self.transaction_fee = Money.new(0, self.iso_code)
    self.save
  end

  # Will need to find third parties to get block counts from
  def blockchain_downloaded?
    if self.iso_code == "BTC"
       if self.api.blockcount < 311778
         return false
       else
         return true
       end
    elsif self.iso_code == "BC"
      if self.api.blockcount < 292894
        return false
      else
        return true
      end
    end
  end
  
  def self.bitcoin
    Wallet.where(iso_code: 'BTC').first
  end
  
  def self.blackcoin
    Wallet.where(iso_code: 'BC').first
  end
  
  def accounts
    Account.where(iso_code: self.iso_code)
  end

  def currency_name
    self.currency.name
  end

  def self.active
    where(active: true).first
  end

  after_create :initialize_account
  def initialize_account
    if self.iso_code == "BC"
      profit = self.new_account("bcbit-profit-" + self.id)
      Account.create!(name: profit.name, address: profit.addresses.first, wallet_id: self.id, iso_code: self.iso_code)
    elsif self.iso_code == "BTC"
      bank = self.new_account("bcbit-bank-" + self.id)
      Account.create(name: bank.name, address: bank.addresses.first, wallet_id: self.id, iso_code: self.iso_code)
    end
  end

  def profit_account
    self.accounts.where(name: "bcbit-profit-#{self.id}").first
  end

  def bank_account
    self.accounts.where(name: "bcbit-bank-#{self.id}").first
  end
  
  def send_to(trade)
    if self.iso_code == "BTC" and trade.status == "processing"
      txid = self.bank_account.wallet_account.send_amount((trade.bitcoin_amount.to_f - 0.0002.to_f), trade.bitcoin_address)
      if txid == "500 Internal Server Error"
        return false
      else
        trade.update_attributes(bitcoin_txid: txid)
      end
    end
  end
  
  def refund(trade)
    if self.iso_code == "BC" and trade.status == "failed"
      txid = trade.account.wallet_account.send_amount((trade.account.unconfirmed_balance.to_f - trade.blackcoin_margin.to_f), trade.refund_address)
      trade.update_attributes(refund_txid: txid)
    end
  end

  def check_if_online
    begin
      self.api.balance
      return true
    rescue
      return false
    end
  end

  def update_wallet
    Trade.where(:status.in => ["pending"]).each do |t|
      @t.account.update_account
      @t.received_transaction
    end
    self.update_attributes(last_update: Time.now, transaction_count: self.transactions.count)
  end

  # Wallet methods
  def balance_by_account(account_name, confirmations = 0)
    self.api.balance(account_name, confirmations).to_money(self.iso_code.upcase)
  end

  def account_by_name(account_name)
    self.api.accounts.where_account_name(account_name)
  end

  def total_received_by_account(account_name)
    self.api.total_received(account_name).to_money(self.iso_code.upcase)
  end
  
  def new_account(account_name)
    self.api.accounts.new(account_name)
  end

  protected
    def api
      wallet ||= RubyWallet.connect(username: Coin.config(self.iso_code)[:rpcuser],
                                    password: Coin.config(self.iso_code)[:rpcpass],
                                    host:     Coin.config(self.iso_code)[:rpchost],
                                    port:     Coin.config(self.iso_code)[:rpcport],
                                    ssl:      Coin.config(self.iso_code)[:ssl])
    end
end
