class ErrorsController < ApplicationController
  def not_found
    render json: { status: 404, message: 'not_found' }, status: :not_found
  end
end
