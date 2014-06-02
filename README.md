Spree Coinbase Plugin (Spree 2.1)
=============

Accept bitcoin payments on your Spree store with the official Coinbase Spree plugin. For more information on Coinbase for merchants, visit https://coinbase.com/merchants.

Installation
------------

If you don't have a Coinbase account, sign up at https://coinbase.com/merchants. Coinbase offers daily payouts for merchants in the United States. For more infomation on setting up payouts, see https://coinbase.com/docs/merchant_tools/payouts.

Add spree_coinbase to your Gemfile:

```ruby
gem 'spree_coinbase', github: 'coinbase/coinbase-spree', branch: '2-1-stable'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_coinbase:install
```

After installing the gem, go to your Spree admin console and navigate to Configuration > Payment Methods > New Payment Method.

![Configuration](http://i.imgur.com/iGs9l6H.png)

Select "Spree::PaymentMethod::Coinbase" from the "Provider" dropdown, enter a name (like "Bitcoin") for the payment method, and click "Create."

![New Payment Method](http://i.imgur.com/5bdGElv.png)

Go to https://coinbase.com/settings/api and click '+ New API Key' to generate an API key and secret for this plugin. You should create a 'HMAC' key with the permission 'merchant' only.

After generating the API key, click on the shortened representation of it (looks like 'kcyPDdpjgYk...') to view the full API Key + Secret. Copy and paste the API key and API secret into the respective fields on the Edit Payment Method page, then click "Update".

Remember to enable the API key on the https://coinbase.com/settings/api page by clicking the "Enable" link. If the API key is not enabled, the plugin will not work.

![Edit Payment Method](http://i.imgur.com/UJImHrA.png)

The plugin should now be active!

Copyright (c) 2014 Coinbase, released under the New BSD License
