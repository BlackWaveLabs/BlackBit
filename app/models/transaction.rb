class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :txid,           type: String
  field :amount,         type: Money
  field :address,        type: String
  field :category,       type: String
  field :confirmations,  type: Integer
  field :iso_code,       type: String

  field :occurred_at,    type: Time
  field :received_at,    type: Time

  field :recipient_id,   type: String
  field :fee_category,   type: String
  field :trade_id,       type: String

  embedded_in :account
  embedded_in :wallet

  validates_presence_of :amount, message: "Amount must be specified."
  validates_uniqueness_of :txid

  state_machine :status, :initial => :pending do
    event :confirm do
      transition :pending => :confirmed
    end
  end

  def trade
    begin
      trade = Trade.find(self.id)
      return trade
    rescue
      return nil
    end
  end

  def txn_type
    if self.category == "send"
      return "withdrawal"
    elsif self.category == "receive"
      return "deposit"
    else
      return self.category
    end
  end
  
  def timestamp
    if self.occurred_at
      return self.occurred_at
    elsif self.received_at
      return self.received_at
    else
      return self.created_at
    end
  end

  def account_type
    self.address.split("-")[0]
  end
  
  def account_trade_id
    self.address.split("-")[1]
  end
  
  def account_trade
    begin
      trade = Trade.find(self.address.split("-")[1])
      return trade
    rescue
      return false
    end
  end
  
end

