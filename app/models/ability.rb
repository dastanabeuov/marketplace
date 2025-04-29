class Ability
  include CanCan::Ability

  def initialize(current_user)
    return unless current_user

    case current_user
    when AdminUser
      can :manage, :all

    when User
      if current_user.admin?
        can :manage, :all
      else
        current_user.memberships.each do |membership|
          can [ :create_from_template, :read ], Template
          can :manage, Document, company_id: membership.company_id
          can :manage, Project, company_id: membership.company_id

          if membership.owner?
            can :manage, Membership, company_id: membership.company_id
            can :manage, Company, id: membership.company_id
          elsif membership.member?
            can :read, Company, id: membership.company_id
            can :read, Project, company_id: membership.company_id
          end
        end

        if current_user.guest?
          can :read, Template
          can :read, Company
          can :read, Document
          can :read, Project
        end
      end
    end
  end
end
