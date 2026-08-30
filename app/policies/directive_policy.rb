# frozen_string_literal: true

class DirectivePolicy < ApplicationPolicy
  def expected_attributes_for_action(_action_name)
    %i[id status filename arguments output created_at updated_at]
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
