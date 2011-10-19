class Ability
  include CanCan::Ability
  # TODO: Ability specs

  def initialize(user)
    can [:create, :login], User
    can [:access], :info
    
    if user
      can :logout, :users
      can :read, User, id: user.id
  
      unless user.blocked?
        can :update, User, id: user.id
        can :read, User
        can :read, User
        can :create, Key
        can [:sign_request, :show_request, :read, :create], Certificate
        can [:read, :update, :destroy], Key, user_id: user.id
        can [:update, :destroy], Certificate, user_id: user.id
        # TODO: check signing by anoteher user
        
        can :certificates, Key
        can [:requests, :issued], Certificate
      end
      
      if user.admin?
        can :access, :all
        can [:read, :update, :destroy, :block], User
        can [:read, :update, :destroy], :keys
        can [:read, :update, :destroy], :certificates
      end
    end
  end
end
