require 'coin'

Coin.set(YAML.load_file("config/coins.yml").symbolize_keys)
