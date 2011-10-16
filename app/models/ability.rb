class Ability
  include CanCan::Ability

  def initialize(user)
    can [:create, :login], User
    can [:access], :info
    
    if user
      can :logout, :users
      can :read, User, id: user.id
      can :create, Key
  
      unless user.blocked?
        can :update, User, id: user.id
        can :read, User
        can [:read, :update, :destroy], Key, user_id: user.id
      end
      
      if user.admin?
        can :access, :all
        can [:read, :update, :destroy, :block], User
        can [:read, :update, :destroy], :keys
      end
    end
  end
end
