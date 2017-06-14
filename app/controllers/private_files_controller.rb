class PrivateFilesController < ApplicationController

  before_action :authenticate

  # GET /private_file
  def get_private_file
    encoded_private_file_url = params[:url]
    return render json: { status: 400, message: 'missing_private_file_url'}, status: :bad_request unless encoded_private_file_url

    exporter = PrivateFileExporter.new
    private_file_content = exporter.get_private_file(encoded_private_file_url)

    if private_file_content[:message] == 'file_not_found'
      render json: { status: 404, message: 'file_not_found' }, status: :not_found
    else
      private_file_content[:status] = 200
      render json: private_file_content, status: :ok
    end
  rescue => error
    render json: { status: 500, message: error.message }, status: :internal_server_error
  end
end
