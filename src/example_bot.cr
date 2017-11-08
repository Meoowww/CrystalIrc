require "./crirc"

# Extracts the nick from the full address of a user (nick!name@host)
def extract_nick(address : String)
  address.split('!')[0]
end

private def bind_example(bot)
  bot.on_ready do
    # Join the default chan when the bot is connected
    bot.join({Crirc::Protocol::Chan.new "#equilibre2"})
  end.on("JOIN") do |msg|
    # Greet message on join
    if (extract_nick msg.source) == bot.nick
      chan = msg.message if msg.message
      bot.privmsg (Crirc::Protocol::Chan.new chan), "Hello, world!" if chan
    end
  end.on("PING") do |msg|
    # Server pong
    bot.pong(msg.message)
  end.on("PRIVMSG", message: /^!ping */) do |msg|
    # !ping command : answer !pong to the user
    chan = msg.arguments if msg.arguments
    bot.privmsg (Crirc::Protocol::Chan.new chan), "pong #{extract_nick msg.source}" if chan
  end
end

client = Crirc::Network::Client.new "Crircbot", "irc.mozilla.org", 6667, ssl: false
client.connect
client.start do |bot|
  bind_example bot
  loop do
    begin
      m = bot.gets
      puts "> #{m}"
      break if m.nil?
      spawn { bot.handle(m.as(String)) }
    rescue error
      puts error
      sleep 0.1
    end
  end
end

client.close
