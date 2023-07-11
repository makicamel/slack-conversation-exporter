require 'slack-ruby-client'
require 'dotenv/load'

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

client = Slack::Web::Client.new
options = { include_all_metadata: true, channel: ENV['CHANNEL_ID'] }
next_cursor = nil
loop do
  response = client.conversations_history(options.merge(cursor: next_cursor))
  if response['ok']
    messages = response['messages']
    messages.each do |message|
      puts Time.at(message['ts'].to_f).strftime('%Y/%m/%d')
      puts message['text']
    end
    next_cursor = response.dig(:response_metadata, :next_cursor)
    break unless  next_cursor
  else
    puts "Error: #{response['error']}"
  end
end
