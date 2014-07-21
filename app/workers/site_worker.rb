class SiteWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  
  sidekiq_options queue: "default", unique: true
  recurrence { hourly }
  
  def perform(last_occurrence = nil, current_occurrence = nil)
    # Check for new transactions
    bc_wallet = Wallet.where(iso_code: "BC").first
    bc_wallet.update_wallet

    # Check timers
    Trade.where(status: 'pending').each do |trade|
      trade.check_timer
    end
    # Fetch new prices
    Site.settings.fetch_prices
    # Payout profits
    Site.settings.payout_site_profits
  end
end
