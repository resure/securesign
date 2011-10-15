class Ability
  include CanCan::Ability

  def initialize(user)
    can [:create, :login], :users
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
        can :update, :users
        can :block, :users
      end
    end
  end
end
