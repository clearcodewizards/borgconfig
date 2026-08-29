module AuthenticatesUserByToken
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_by_token!
  end

  def authenticate_by_token!
    token, = ActionController::HttpAuthentication::Token.token_and_options(request)
    return render json: {}, status: :unauthorized if token.blank?

    @user = User.find_by(api_token: token)
    render json: {}, status: :unauthorized unless @user
  end
end
