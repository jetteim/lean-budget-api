class InputProcessor
  require 'telegramAPI'
  require 'redis'
  MAX_PROCESSORS = 16
  def initialize(token)
    @redis = Redis.new
    @token = token
    @api = TelegramAPI.new(token)
    @processors = ThreadGroup.new
    @garbage_collector = Thread.new do
      sleep(10)
      while Thread.main.alive?
        begin
          pending = @processors.list.select(&:alive?)
          pending.each { |th| th.terminate unless th.join(10) }
          sleep(1)
        rescue StandardError => detail
          puts detail.inspect.red
          puts detail.backtrace.join("\n").red
          # raise
        end
      end
    end
  end

  def process_telegram(user, input)
    # TODO: - авторизовать пользователя
    puts "processing updates from user #{user}: #{input.inspect}".green
    @processors.add(
      Thread.new do
        begin
          sender = TelegramResponder.new(@token)
          input.each do |message|
            if pending = @redis.LPOP(user)
              sender.send_reply(chat_id: message[:chat_id], reply: do_command(user, message, pending))
            end
            sender.send_reply(chat_id: message[:chat_id], reply: do_update(user, message))
            queue_commands(user, message[:entities]['bot_command']) if message[:entities]
          end
        rescue StandardError => detail
          puts detail.inspect.red
          puts detail.backtrace.join("\n").red
          raise
        end
      end
    )
    check_processors_queue
  end

  def check_processors_queue
    loop do
      pending = @processors.list.select(&:alive?)
      break unless pending.count > MAX_PROCESSORS
      puts 'responders queue overloaded, waiting for garbage collector to proceed'.red
      sleep(1)
    end
  end

  def queue_commands(user, commands)
    puts "commands received: #{commands.inspect}".cyan
    commands.each { |u| @redis.RPUSH(user, u) }
  end

  def do_update(user, message)
    # здесь добавляем новую транзакцию
    puts "doing update for user #{user}: #{message.inspect}".magenta
    JSON.parse(RestClient.get("localhost:3000/user/#{user}"))
  end

  def do_command(user, message, command)
    # здесь выполняем, собственно, команду
    return bind_token(user, message[:text]) if command == '/register'
  end

  def bind_token(user, string)
    puts "binding token #{string} for user #{user}".yellow
    puts "got users #{bind = JSON.parse(RestClient.get("localhost:3000/user/#{user}"))}"
    bind
  end

  def check_authorization(user); end
end
