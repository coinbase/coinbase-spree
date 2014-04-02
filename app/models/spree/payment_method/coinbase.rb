module Spree
  class PaymentMethod::Coinbase < PaymentMethod
    preference :api_key, :string
    preference :api_secret, :string
    preference :use_off_site_payment_page, :boolean

    def auto_capture?
      false
    end

    def provider_class
      nil
    end

    def payment_source_class
      nil
    end

    def source_required?
      false
    end
  end
end