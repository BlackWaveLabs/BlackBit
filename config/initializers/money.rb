# encoding : utf-8

MoneyRails.configure do |config|
  config.register_currency = {
     :priority            => 1,
     :iso_code            => "BC",
     :name                => "Blackcoin",
     :symbol              => "BC",
     :symbol_first        => true,
     :subunit             => "Blackcent",
     :subunit_to_unit     => 100000000,
     :thousands_separator => ",",
     :decimal_mark        => "."
  }

  config.register_currency = {
     :priority            => 1,
     :iso_code            => "BTC",
     :name                => "Bitcoin",
     :symbol              => "BTC",
     :symbol_first        => true,
     :subunit             => "Bitcent",
     :subunit_to_unit     => 100000000,
     :thousands_separator => ",",
     :decimal_mark        => "."
  }

  config.default_currency = :BC

  config.add_rate "BC", "BTC", 1
  config.add_rate "BTC", "BC", 1

end
