module Spree
  class PaymentMethod::Coinbase < PaymentMethod
    preference :api_key, :string
    preference :api_secret, :string

    def auto_capture?
      true
    end

    def provider_class
      nil
    end

    def purchase(amount, source, gateway_options)


      ActiveMerchant::Billing::Response.new(true, "%{amount} and options %{YAML::dump(gateway_options)}", {}, {})
    end

    def payment_source_class
      Spree::PaymentMethod::Coinbase::DummySource
    end

    def source_required?
      true
    end
  end
end