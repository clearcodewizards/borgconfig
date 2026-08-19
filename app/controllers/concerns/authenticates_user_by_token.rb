module AuthenticatesUserByToken
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_by_token!
  end

  def authenticate_by_token!
    authenticate_with_http_token do |token, _options|
      return render json: {}, status: :unauthorized unless token

      @user = User.find_by(api_token: token)
      return render json: {},  status: :unauthorized unless @user
    end
  end
end
