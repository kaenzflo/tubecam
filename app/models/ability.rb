class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

    user ||= User.new # guest user (not logged in)
    if user.admin_role?
      can :manage, :all
    end
    if user.trapper_role?
      can :manage, TubecamDevice
      cannot :destroy, TubecamDevice
    end

    if user.verified_spotter_role?

    end

    if user.spotter_role?

    end

  end
end
