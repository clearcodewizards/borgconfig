module Api
  module V1
    class CubesController < ApiController
      def index
        render json: Cube.all
      end
    end
  end
end
