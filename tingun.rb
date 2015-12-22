#!/usr/bin/env ruby

require 'mailgun'
require 'CSV'

# Mailgun API
@mailgun_client = Mailgun::Client.new("your_mailgun_api_key")

# Mailing list alias address
@mailing_list_alias_address = ARGV[0]

# Recipient defaults
@recipients = []
@recipient_count = 0

def startup
  puts "Downloading #{@mailing_list_alias_address} recipient list..."
end

def run
  startup
  yield
  shutdown
end

def shutdown
  puts "#{@recipient_count} contact(s) downloaded"
end

run do
  # Get recipient count
  @recipient_count = @mailgun_client.get("/lists", { limit: 100, skip: 0 }).to_h["items"].select { |h| h["address"] == @mailing_list_alias_address }.first["members_count"]
  
  # Number of pages recipients are spread across (Mailgun limts requests to 100 records)
  # Pages may not be the best term. "number_of_requests" perhaps?
  number_of_pages = (@recipient_count.to_f / 100)
  number_of_pages = number_of_pages % 1 == 0 ? number_of_pages.floor - 1 : number_of_pages.floor
  
  # Add recipients to @recipients (Loops through each page, plus 1 to include carry over)
  number_of_pages.downto(0) do |page_num|
    # Set skip count
    skip_count = page_num * 100
    
    # Get recipients from the current page
    page_recipients = @mailgun_client.get("/lists/#{@mailing_list_alias_address}/members", { limit: 100, skip: skip_count })
    @recipients += page_recipients.to_h["items"]
  end
  
  # To CSV
  CSV.open( "#{@mailing_list_alias_address}.csv","wb" ) do |csv|
    # Header row
    csv << ["Recipient Address", "Full Name", "Subscription"]

    # Add the recipients
    @recipients.each do |recipient|
      csv << [recipient['name'], recipient['address'], recipient['subscribed']]
    end
  end
end
