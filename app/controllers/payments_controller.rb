class PaymentsController < ApplicationController
  before_action :require_login, except: [:webhook]
  skip_before_action :verify_authenticity_token, only: [:webhook]

  # ============================================
  # SUCCESS ACTION - User returns from Stripe
  # ============================================
  def success
    order = current_user.orders.find(params[:order_id])
    
    begin
      # Verify payment with Stripe
      payment_intent = Stripe::PaymentIntent.retrieve(order.stripe_payment_intent_id)
      
      if payment_intent.status == 'succeeded'
        # Update order only if not already paid
        unless order.paid?
          order.update!(status: 'paid')
          clear_cart
          send_confirmation_emails(order)
        end
        
        redirect_to order_path(order), notice: 'Payment successful! Check your email for confirmation.'
      else
        redirect_to checkout_order_path(order), alert: 'Payment was not completed. Please try again.'
      end
      
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error in success: #{e.message}"
      redirect_to checkout_order_path(order), alert: "Error verifying payment: #{e.message}"
    end
  end

  # ============================================
  # WEBHOOK - Stripe's asynchronous notification
  # ============================================
  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      Rails.logger.error "Webhook JSON parse error: #{e.message}"
      render json: { error: 'Invalid payload' }, status: :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Webhook signature verification failed: #{e.message}"
      render json: { error: 'Invalid signature' }, status: :bad_request
      return
    end

    # Handle the event
    case event.type
    when 'payment_intent.succeeded'
      handle_payment_success(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_failure(event.data.object)
    else
      Rails.logger.info "Unhandled webhook event: #{event.type}"
    end

    render json: { message: 'success' }, status: :ok
  end

  private

  # ============================================
  # HANDLE SUCCESSFUL PAYMENT
  # ============================================
  def handle_payment_success(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    
    unless order
      Rails.logger.error "Order not found for payment_intent: #{payment_intent.id}"
      return
    end
    
    return unless order.pending? # Only update if still pending
    
    Rails.logger.info "Processing successful payment for Order ##{order.order_number}"
    
    order.update!(status: 'paid')
    send_confirmation_emails(order)
    
    Rails.logger.info "Order ##{order.order_number} marked as paid"
  end

  # ============================================
  # HANDLE FAILED PAYMENT
  # ============================================
  def handle_payment_failure(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent.id)
    
    if order
      order.update!(status: 'failed')
      Rails.logger.info "Order ##{order.order_number} marked as failed"
    end
  end

  # ============================================
  # SEND CONFIRMATION EMAILS
  # ============================================
  def send_confirmation_emails(order)
    begin
      # Send order confirmation
      UserMailer.order_confirmation(order).deliver_now
      Rails.logger.info "Order confirmation email sent for Order ##{order.order_number}"
      
      # Send payment receipt
      UserMailer.payment_receipt(order).deliver_now
      Rails.logger.info "Payment receipt email sent for Order ##{order.order_number}"
      
    rescue => e
      Rails.logger.error "Failed to send emails for Order ##{order.order_number}: #{e.message}"
      # Don't raise error - payment already succeeded
    end
  end

  # ============================================
  # CLEAR USER'S CART
  # ============================================
  def clear_cart
    cart = current_user.carts.find_by(id: session[:cart_id])
    if cart
      cart.cart_items.destroy_all
      session.delete(:cart_id)
      Rails.logger.info "Cart cleared for user ##{current_user.id}"
    end
  end

  # ============================================
  # AUTHENTICATION CHECK
  # ============================================
  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Please log in to continue."
    end
  end
end