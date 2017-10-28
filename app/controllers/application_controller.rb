class ApplicationController < ActionController::API
  include ActionController::Helpers
  include ActionController::MimeResponds
  require 'token'

  before_action :set_origin
  before_action :set_headers
  before_action :authenticate_user
  # before_action :set_locale

  ALLOWED_HOSTS = %w[
    lvh.me localhost
    gycwifi.com enter.gycwifi.com
    api.gycwifi.com auth.gycwifi.com dashboard.gycwifi.com hal.gycwifi.com login.gycwifi.com
    api2.gycwifi.com auth2.gycwifi.com dashboard2.gycwifi.com hal2.gycwifi.com login2.gycwifi.com
    api3.gycwifi.com auth3.gycwifi.com dashboard3.gycwifi.com hal3.gycwifi.com login3.gycwifi.com
  ].freeze

  def set_origin
    @origin = request.headers['HTTP_ORIGIN']
  end

  def set_headers
    if @origin
      ALLOWED_HOSTS.each do |host|
        if @origin =~ %r{/^https?:\/\/#{Regexp.escape(host)}/i}
          headers['Access-Control-Allow-Origin'] = @origin
          break
        end
      end
    else
      # or '*' for public access
      headers['Access-Control-Allow-Origin'] = '*'
    end
    headers['Access-Control-Allow-Methods'] = '*'
    # headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept'
    headers['Content-Type'] = 'application/json'
  end

  def options
    head status: 200, 'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept'
  end

  def authenticate_user
    user_not_authenticated unless authenticated_user?
  end

  def user_not_authenticated(message = nil)
    render json: { status: 'error', message: message }, status: :unauthorized
  end

  def authenticated_user?
    current_user.present?
  end
  helper_method :authenticated_user?

  def unauthenticated_user?
    current_user.nil?
  end
  helper_method :unauthenticated_user?

  def permission_denied(message = nil)
    render json: { head: :forbidden, status: 'error', message: message }
  end
  helper_method :permission_denied

  def current_user
    @current_user ||= token_user
  end
  helper_method :current_user

  def token_user
    token = Token.new(header_token)
    return unless token.valid?
    user = User.find(token.user_id)
    # пускаем под admin@example.com всегда на любой не-production среде
    user if acknowledge_token?(user.redis_token_key, header_token)
  end

  def header_token
    puts header_token = request.headers['Authorization'].to_s.split.last
    header_token
  end
end
