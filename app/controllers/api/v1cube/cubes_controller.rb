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

        Cube.transaction do
          cube = Cube.find_or_create_by!(api_token: token) do |new_cube|
            new_cube.name = Haikunator.haikunate(1000)
            new_cube.status = :pending
          end

          tags = tag_names.map { |name| Tag.find_or_create_by!(name:) }
          cube.tags = (cube.tags.to_a + tags).uniq
        end

        render json: {}, status: :ok
      end

      private

      def tag_names
        Array(params[:tags]).uniq
      end
    end
  end
end
