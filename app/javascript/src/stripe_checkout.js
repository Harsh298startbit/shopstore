// app/javascript/packs/stripe.js (or wherever your Stripe JS is)

document.addEventListener('turbolinks:load', () => {
  const checkoutForm = document.getElementById('payment-form');
  
  if (checkoutForm && window.orderData) {
    initializeStripeCheckout();
  }
});

async function initializeStripeCheckout() {
  const stripeKey = document.querySelector('meta[name="stripe-publishable-key"]')?.content;
  
  if (!stripeKey) {
    console.error('Stripe publishable key not found');
    showError('Payment system configuration error. Please contact support.');
    return;
  }

  const stripe = Stripe(stripeKey);
  
  try {
    // Fetch the payment intent client secret
    const response = await fetch(`/orders/${window.orderData.orderId}/payment_intent`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    });

    if (!response.ok) {
      throw new Error('Failed to initialize payment');
    }

    const { clientSecret } = await response.json();

    // Initialize Stripe Elements
    const elements = stripe.elements({ clientSecret });
    const paymentElement = elements.create('payment');
    paymentElement.mount('#payment-element');

    const form = document.getElementById('payment-form');
    const submitButton = document.getElementById('submit-button');
    const buttonText = document.getElementById('button-text');
    const spinner = document.getElementById('spinner');
    const termsCheckbox = document.getElementById('terms-checkbox');

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      // Validate terms acceptance
      if (!termsCheckbox.checked) {
        showError('Please accept the terms and conditions to continue.');
        return;
      }
      
      // Disable form submission while processing
      submitButton.disabled = true;
      buttonText.style.display = 'none';
      spinner.style.display = 'inline';

      const { error } = await stripe.confirmPayment({
        elements,
        confirmParams: {
          // THIS IS THE KEY CHANGE - Return to success page
          return_url: `${window.location.origin}/payments/success?order_id=${window.orderData.orderId}`,
        },
      });

      if (error) {
        // Show error message
        showError(error.message);
        
        // Re-enable form
        submitButton.disabled = false;
        buttonText.style.display = 'inline';
        spinner.style.display = 'none';
      }
      // If no error, user is redirected to Stripe and then back to return_url
    });
    
  } catch (error) {
    console.error('Payment initialization error:', error);
    showError('Failed to initialize payment. Please refresh and try again.');
  }
}

function showError(message) {
  const messageContainer = document.getElementById('payment-message');
  const errorText = document.getElementById('error-text');
  
  if (errorText && messageContainer) {
    errorText.textContent = message;
    messageContainer.style.display = 'block';
    
    // Auto-hide after 10 seconds
    setTimeout(() => {
      messageContainer.style.display = 'none';
    }, 10000);
  }
}