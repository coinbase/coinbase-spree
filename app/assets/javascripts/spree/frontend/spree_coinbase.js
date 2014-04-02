SpreeCoinbase = {
  doOnSiteCheckout: function() {
    
    $('#checkout_form_payment input.continue').hide();
    $('div[data-hook="checkout_payment_step"]').html("<iframe src=\"" + SpreeCoinbase.checkoutUrl + "\" style=\"width: 500px; height: 160px; border: none; overflow: hidden;\" scrolling=\"no\" allowtransparency=\"true\" frameborder=\"0\"></iframe>" + 
      "<p><a href=\"" + SpreeCoinbase.cancelUrl + "\">Cancel and choose another payment method</a></p>");
  }
}

$(document).ready(function() {
  $('#checkout_form_payment input.continue').click(function (e) {
    checkedPaymentMethod = $('div[data-hook="checkout_payment_step"] input[type="radio"]:checked');
    
    if (checkedPaymentMethod.val() == SpreeCoinbase.paymentMethodId && !SpreeCoinbase.useOffSite) {
      // On-site checkout!
      SpreeCoinbase.doOnSiteCheckout();
      return false;
    } else {
      return true;
    }
  });
})

window.addEventListener('message', receiveMessage, false);

// Listen for messages from the on-site payment iframe
function receiveMessage(event) {

  if (event.origin == 'https://coinbase.com') {
    var event_type = event.data.split('|')[0];
    if (event_type == 'coinbase_payment_complete') {

      // Redirect to success url (wait 1 second for callback to arrive)
      setTimeout(function() {
        window.location = SpreeCoinbase.successUrl;
      }, 1000);
    }
  }
}