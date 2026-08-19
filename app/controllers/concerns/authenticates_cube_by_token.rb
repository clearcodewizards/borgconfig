module AuthenticatesCubeByToken
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_by_token!
  end

  def authenticate_by_token!
    authenticate_with_http_token do |token, _options|
      return render json: {}, status: :unauthorized unless token

      @cube = Cube.find_by(api_token: token, registered: true)
      return render json: {},  status: :unauthorized unless @cube
    end
  end
end
