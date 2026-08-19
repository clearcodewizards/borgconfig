module Api
  module V1cube
    class CubeFilesController < ApiCubeController
      def index
        render json: CubeFile.all
      end
    end
  end
end
