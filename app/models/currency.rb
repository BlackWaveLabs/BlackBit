class Currency
  include Mongoid::Document
  field :iso_code,              type: String
  field :name,                  type: String
  field :symbol,                type: String
  field :symbol_first,          type: Boolean, default: true
  field :subunit,               type: String
  field :subunit_to_unit,       type: Integer, default: 100000000
  field :thousands_separator,   type: String, default: ","
  field :decimal_mark,          type: String, default: "."
  

  belongs_to :wallet
end
