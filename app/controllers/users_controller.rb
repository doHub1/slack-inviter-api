class UsersController < ApplicationController
  # GET /users/:user_id/inviter
  def inviter
    user_id = params['user_id']
    return render json: { status: 400, message: 'missing_user_id'}, status: :bad_request unless user_id

    exporter = AcceptedInvitesExporter.new
    inviter_id = exporter.get_inviter_id(params['user_id'])

    if inviter_id == 'user_not_found'
      render json: { status: 404, message: 'user_not_found' }, status: :not_found
    else
      render json: { status: 200, message: 'success', inviter_id: inviter_id }, status: :ok
    end
  rescue => error
    render json: { status: 500, message: error.message }, status: :internal_server_error
  end
end
