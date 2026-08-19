module Api
  module V1cube
    class DirectivesController < ApiCubeController
      def index
        render json: @cube.directives.pending
      end

      def show
        directive = @cube.directives.find_by(id: params[:id])
        return render json: {}, status: :not_found if directive.nil?

        render json: directive, status: :ok
      end

      def update
        directive = @cube.directives.find_by(id: params[:id])
        return render json: {}, status: :not_found if directive.nil?

        directive.update!(status: params[:json][:status], output: params[:json][:output])
        render json: {}, status: :ok
      end
    end
  end
end
