class UserMailer < ApplicationMailer
  # Send password reset email
  def password_reset(user, reset_token)
    @user = user
    @reset_token = reset_token
    @reset_url = "#{ENV['MAILER_HOST']}/password_reset?token=#{reset_token}"
    
    mail(
      to: user.email,
      subject: 'Password Reset Request'
    )
  end
  
  # Send welcome email on subscription
  def welcome_email(user)
    @user = user
    
    mail(
      to: user.email,
      subject: 'Welcome to Our E-commerce Store!'
    )
  end
  
  # Send newsletter subscription confirmation
  def subscription_confirmation(email)
    @email = email
    
    mail(
      to: email,
      subject: 'Thanks for Subscribing!'
    )
  end
  
  def order_confirmation(order)
    @order = order
    @user = order.user  # ✅ Set @user from order relationship
    
    mail(
      to: @order.email,  # Sends to shipping email
      subject: "Order Confirmation - #{@order.order_number}"
    )
  end
  
  def payment_receipt(order)
    @order = order
    @user = order.user  # ✅ Set @user from order relationship
    
    mail(
      to: @order.email,  # Sends to shipping email
      subject: "Payment Receipt - #{@order.order_number}"
    )
  end
end
