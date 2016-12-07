class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      token == ENV['SECRET_TOKEN']
    end
  end

  def render_unauthorized
    render json: { status: 401, message: 'invalid_token' }, status: :unauthorized
  end
end
