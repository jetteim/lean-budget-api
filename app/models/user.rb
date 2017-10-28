class User < ApplicationRecord
  has_one :user_profile

  def cache_token
    logger.debug "building token for user #{id}".cyan
    cache_token = token || Token.encode(id)
    REDIS.sadd(redis_token_key, cache_token)
    cache_token
  end

  def redis_token_key
    "token_#{id}"
  end
end
