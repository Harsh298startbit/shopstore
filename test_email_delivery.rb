#!/usr/bin/env ruby
# Test email delivery script

require 'dotenv'
Dotenv.load

puts "Testing Email Delivery Configuration..."
puts "=" * 50

# Test SMTP settings
smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'gmail.com',
  user_name: ENV['GMAIL_USERNAME'] || 'kukrejah661@gmail.com',
  password: ENV['GMAIL_PASSWORD'] || 'arpfnhrbypddmbbt',
  authentication: :plain,
  enable_starttls_auto: true
}

puts "\nSMTP Configuration:"
puts "Address: #{smtp_settings[:address]}"
puts "Port: #{smtp_settings[:port]}"
puts "Username: #{smtp_settings[:user_name]}"
puts "Password: #{'•' * smtp_settings[:password].length}"
puts "Authentication: #{smtp_settings[:authentication]}"

# Test connection
puts "\nTesting SMTP connection..."
begin
  require 'net/smtp'
  
  smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
  smtp.enable_starttls
  smtp.start(smtp_settings[:domain], smtp_settings[:user_name], smtp_settings[:password], :plain) do |smtp|
    puts "SMTP connection successful!"
  end
rescue => e
  puts "SMTP connection failed: #{e.message}"
  puts "\nPossible solutions:"
  puts "1. Use an App Password instead of regular password"
  puts "2. Enable 2-factor authentication and generate App Password"
  puts "3. Check if Gmail account allows less secure apps"
end

# Test Rails ActionMailer
puts "\n" + "=" * 50
puts "Testing Rails ActionMailer..."
puts "=" * 50

require_relative 'config/environment'

begin
  # Test with a simple mail
  test_email = UserMailer.payment_receipt(Order.new(
    order_number: 'TEST-001',
    email: ENV['GMAIL_USERNAME'] || 'kukrejah661@gmail.com',
    total_amount: 100.00,
    user: User.first || OpenStruct.new(name: 'Test User')
  ))
  
  puts "\nEmail prepared:"
  puts "From: #{test_email.from}"
  puts "To: #{test_email.to}"
  puts "Subject: #{test_email.subject}"
  
  # Try to deliver
  result = test_email.deliver_now
  puts "\nEmail sent successfully!"
  puts "Check #{test_email.to.first} for the test email"
rescue => e
  puts "Email delivery failed: #{e.message}"
  puts "\nError details:"
  puts e.backtrace.first(5).join("\n")
end

puts "\n" + "=" * 50
puts "Test completed!"

