class Ability
  include CanCan::Ability

  def initialize(current_user)
    return unless current_user

    case current_user
    when AdminUser
      can :manage, :all
    when User
      can :read, :all
    end
  end
end
