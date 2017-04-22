class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

    user ||= User.new # guest user (not logged in)
    if user.admin_role?
      can :manage, :all
    end
    if user.trapper_role?
      can :manage, Tubecamstation
      can :read, :all
    end

  end
end
