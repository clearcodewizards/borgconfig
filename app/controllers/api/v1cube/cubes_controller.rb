module Api
  module V1cube
    class CubesController < ApiCubeController
      skip_before_action :authenticate_by_token!, only: %i[create]

      def index
        render json: @cube
      end

      def create
        authenticate_with_http_token do |token, _options|
          return render json: {}, status: :unauthorized unless token

          cube = Cube.find_by(api_token: token)
          Cube.create(api_token: token, name: Haikunator.haikunate(1000), status: :pending) if cube.nil?
        end

        render json: {}, status: :ok
      end
    end
  end
end
