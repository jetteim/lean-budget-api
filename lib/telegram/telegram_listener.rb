class TelegramListener
  require 'telegramAPI'

  def initialize(token)
    @api = TelegramAPI.new(token)
  end

  def updates_bundle
    updates = @api.getUpdates('timeout' => 180)
    bundle = {}
    updates.each do |update|
      next unless (message = parse_update(update))
      next unless (username = message[:username])
      bundle[username] = [] unless bundle[username]
      bundle[username] << message
    end
    return bundle
  rescue RestClient::Exception => e
    puts e.response.to_s.red
  end

  def parse_update(update)
    puts "parsing message #{update}".yellow
    message = update['message'] || update['edited_message']

    user = message['from'] if message && message['from']
    username = user['username'] if user
    user_id = user['id'] if user

    chat = message['chat'] if message
    chat_id = chat['id'] if chat

    entities = extract_entities(message) if message['entities']

    {
      username: username,
      user_id: user_id,
      chat_id: chat_id,
      text: message['text'],
      entities: entities
    }
  end

  def extract_entities(message)
    entities = {}
    message['entities'].each do |entity|
      key = entity['type']
      entities[key] = [] unless entities[key]
      entities[key] << message['text'][entity['offset'], entity['length']]
    end
    entities
  end
 end
