class TelegramResponder
  require 'telegramAPI'

  def initialize(token)
    @api = TelegramAPI.new(token)
  end

  def send_reply(reply)
    Thread.new do
      begin
        puts "sending reply: #{reply.inspect}".magenta
        res = @api.sendMessage(reply[:chat_id], reply[:reply])
      rescue StandardError => detail
        puts detail.inspect.red
        puts detail.backtrace.join("\n").red
        raise
      end
    end
  end
end
