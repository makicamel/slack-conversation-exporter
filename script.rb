require 'slack-ruby-client'
require 'dotenv/load'

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

client = Slack::Web::Client.new
options = { include_all_metadata: true, channel: ENV['CHANNEL_ID'] }
next_cursor = nil

monthly = {}
loop do
  response = client.conversations_history(options.merge(cursor: next_cursor))
  if response['ok']
    messages = response['messages']
    messages.each do |message|
      date = Time.at(message['ts'].to_f)
      monthly[date.strftime('%Y-%m')] ||= {}
      monthly[date.strftime('%Y-%m')][date.strftime('%Y/%m/%d')] ||= []
      monthly[date.strftime('%Y-%m')][date.strftime('%Y/%m/%d')] += [message['text']]
    end
    next_cursor = response.dig(:response_metadata, :next_cursor)
    break unless  next_cursor
  else
    puts "Error: #{response['error']}"
  end
end

monthly.each do |month, dates|
  File.open("tmp/#{month}.txt", 'w', 0755) do |f|
    dates.reverse_each do |date, texts|
      f.print "## #{date}\n"
      f.print texts.reverse.map { |text| text.split('\n').join("\n") }.join("\n\n") + "\n"
      f.print "\n"
    end
  end
end
