Rails.application.routes.draw do
  resources :trades, :except => [:index, :edit, :destroy, :update] 

  patch 'trades/:id/refund' => 'trades#refund', as: 'trade_refund'

  root to: 'trades#new'
  get 'api' => 'trades#api'
  get 'faq' => 'trades#faq'
  get 'trades' => 'trades#new'
  
  namespace :api, defaults: {format: 'json'} do
    get "trade/:bitcoin_amount/:bitcoin_address" => "trades#issue", format: false, constraints: { bitcoin_amount: /[0-9]+(\.[0-9]{1,8})?/ }
    get "check/:id" => "trades#check"
  end
end
