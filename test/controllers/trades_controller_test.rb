require 'test_helper'

class TradesControllerTest < ActionController::TestCase
  setup do
    @trade = trades(:one)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trade" do
    assert_difference('Trade.count') do
      post :create, trade: { bitcoin_address: @trade.bitcoin_address, bitcoin_amount: @trade.bitcoin_amount, bitcoin_confirmations: @trade.bitcoin_confirmations, blackcoin_address: @trade.blackcoin_address, blackcoin_amount: @trade.blackcoin_amount, blackcoin_confirmations: @trade.blackcoin_confirmations, paid: @trade.paid }
    end

    assert_redirected_to trade_path(assigns(:trade))
  end

  test "should show trade" do
    get :show, id: @trade
    assert_response :success
  end

  # Add tests for refunding

end
