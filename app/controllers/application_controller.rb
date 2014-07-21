class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :check_if_wallets_available
  
  def check_if_wallets_available
    #unless Wallet.where(iso_code: "BTC").first.blockchain_downloaded? and Wallet.where(iso_code: "BC").first.blockchain_downloaded?
    #  @wallets_available = false
    #end
  end

end
