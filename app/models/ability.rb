class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is?(:god)
      can :manage, :all
    end

    if user.is?(:superadmin)
      can :manage, Staff
      can :manage, Patient
    end

    if user.is?(:patient)
    end

    unless user.is?(:patient)
      can :pair_mobile, user
    end

    if user.is?(:nurse, :student)
      can :create, Encounter
      can :update, Encounter
    end

    if user.is?(:physician)
      can :be_most_responsible_for, :all
    end

    if user.is?(:physician, :np)
      can :be_most_responsible_for, Encounter
    end

    if user.is?(:physician, :np, :resident)
      can :manage, Patient
      can :manage, Encounter
      can :manage, Prescription
    end

    if user.is?(:physician, :np, :nurse, :admin)
      can :update_demographics, Patient
      can :manage, Appointment
      can :manage, Letter
      can :manage, :schedule
    end
  end
end
