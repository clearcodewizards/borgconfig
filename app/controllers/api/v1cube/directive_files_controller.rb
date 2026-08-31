module Api
  module V1cube
    class DirectiveFilesController < ApiCubeController
      def index
        render json: DirectiveFile.all
      end
    end
  end
end
