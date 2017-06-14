class PrivateFilesController < ApplicationController
  before_action :set_private_file, only: [:show, :update, :destroy]

  # GET /private_files
  def index
    @private_files = PrivateFile.all

    render json: @private_files
  end

  # GET /private_files/1
  def show
    render json: @private_file
  end

  # POST /private_files
  def create
    @private_file = PrivateFile.new(private_file_params)

    if @private_file.save
      render json: @private_file, status: :created, location: @private_file
    else
      render json: @private_file.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /private_files/1
  def update
    if @private_file.update(private_file_params)
      render json: @private_file
    else
      render json: @private_file.errors, status: :unprocessable_entity
    end
  end

  # DELETE /private_files/1
  def destroy
    @private_file.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_private_file
      @private_file = PrivateFile.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def private_file_params
      params.fetch(:private_file, {})
    end
end
