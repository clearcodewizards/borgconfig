module Api
  module V1cube
    class CubesController < ApiCubeController
      skip_before_action :authenticate_by_token!, only: %i[create]

      def index
        render json: @cube
      end

      def create
        token, = ActionController::HttpAuthentication::Token.token_and_options(request)
        return render json: {}, status: :unauthorized if token.blank?

        Cube.find_or_create_by!(api_token: token) do |cube|
          cube.name = Haikunator.haikunate(1000)
          cube.status = :pending
        end

        render json: {}, status: :ok
      end
    end
  end
end
