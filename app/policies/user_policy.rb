# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def expected_attributes_for_action(_action_name)
    %i[id name role email_address created_at updated_at]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
