class Ability
  include CanCan::Ability

  def initialize(user)
    can [:create, :login], User
    can [:access], :info
    
    if user
      can :logout, :users
      can :read, User, id: user.id
  
      unless user.blocked?
        can :update, User, id: user.id
        can :read, User
      end
      
      if user.admin?
        can :access, :all
        can :update, User
        can :block, :users
      end
    end
  end
end
