class ApiCubeController < ApplicationController
  include AuthenticatesCubeByToken

  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token
end
