Spree::Core::Engine.routes.draw do
  get '/spree_coinbase/redirect', :to => "coinbase#redirect", :as => :spree_coinbase_redirect
  post '/spree_coinbase/callback', :to => "coinbase#callback", :as => :spree_coinbase_callback
  get '/spree_coinbase/cancel', :to => "coinbase#cancel", :as => :spree_coinbase_cancel
  get '/spree_coinbase/success', :to => "coinbase#success", :as => :spree_coinbase_success
end
