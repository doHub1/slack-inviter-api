class ErrorsController < ApplicationController
  def not_found
    render json: { status: 404, message: 'not_found' }, status: :not_found
  end

  def internal_server_error
    render json: { status: 500, message: 'internal_server_error' }, status: :internal_server_error
  end
end
