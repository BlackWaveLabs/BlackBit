class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :refund]

  def new
    @trade = Trade.new
  end

  def create
    active_trade = Trade.where(ip_address: request.remote_ip, status: "pending").first
    if !active_trade   
      @trade = Trade.new(trade_params)
      @trade.ip_address = request.remote_ip
      @trade.initiated_at = Time.now
    end
    respond_to do |format|
      if active_trade
        format.html { redirect_to active_trade, notice: 'Trade already exists.' }
      elsif @trade.save
        format.html { redirect_to @trade }
      else
        format.html { render :new }
      end
    end
  end
  
  def refund
    @trade.update_attributes(refund_address: params[:trade][:refund_address])
    @trade.issue_refund
    respond_to do |format|
      format.html { redirect_to @trade, notice: 'Refund has been issued.'}
    end
  end

  private
    def set_trade
      @trade = Trade.find(params[:id])
    end

    def trade_params
      params.require(:trade).permit(:bitcoin_amount, :bitcoin_address, :refund_address)
    end
end
