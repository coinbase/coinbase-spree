module SpreeCoinbase
  class Engine < Rails::Engine
    engine_name 'spree_coinbase'

    initializer "spree.spree_coinbase.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::Coinbase
    end
  end
end
