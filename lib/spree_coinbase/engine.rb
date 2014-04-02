module SpreeCoinbase
  class Engine < Rails::Engine
    engine_name 'spree_coinbase'

    config.to_prepare do
    	Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
			Rails.configuration.cache_classes ? require(c) : load(c)
		end
	end

    initializer "spree.spree_coinbase.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::Coinbase
    end
  end
end
