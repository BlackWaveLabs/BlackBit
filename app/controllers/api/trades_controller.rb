module Api
  class TradesController < ApplicationController # use an API base controller
    respond_to :json
    
    def issue
      active_trade = Trade.where(ip_address: request.remote_ip, status: "pending").first
      if !active_trade   
        @trade = Trade.create(bitcoin_amount: params[:bitcoin_amount], bitcoin_address: params[:bitcoin_address], ip_address:  request.remote_ip, initiated_at: Time.now)
      else
        @trade = active_trade
      end
      
      respond_to do |format|
        if @trade.bitcoin_amount.to_f > Site.settings.bank_balance.to_f
          format.json { render status: 401, json: {error: "Bitcoin bank running low. Try again soon."}}
        elsif @trade
          trade_summary = {
            'id' => @trade.id.to_s,
            'deadline' => @trade.initiated_at + 2.minutes,
            'status' => @trade.status,
            'blackcoin_amount' => @trade.blackcoin_amount.to_s,
            'blackcoin_address' => @trade.blackcoin_address.to_s,
          }.to_json
  
          format.json { render status: 200, json: trade_summary }
        else
          format.json { render status: 401, json: {error: "Unable to issue trade."}}
        end
      end
    end

    def check
      @trade = Trade.find(params[:id])
      respond_to do |format|
        if @trade
          trade_summary = {
            'id' => @trade.id.to_s,
            'deadline' => (@trade.initiated_at + 2.minutes),
            'status' => @trade.status,
            'blackcoin_amount' => @trade.blackcoin_amount.to_s,
            'blackcoin_address' => @trade.blackcoin_address.to_s,
          }.to_json

          format.json { render status: 200, json: trade_summary }
        else
          format.json { render status: 401, json: {error: "No trade found."}}
        end
      end
    end
  end
end