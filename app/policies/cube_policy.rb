# frozen_string_literal: true

class CubePolicy < ApplicationPolicy
  def expected_attributes_for_action(_action_name)
    %i[id name registered status created_at updated_at]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
