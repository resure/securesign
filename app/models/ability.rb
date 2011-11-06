class Ability
  include CanCan::Ability

  def initialize(user)
    can [:create, :login], User
    can :access, :info
    
    if user
      can :logout, User
      can :read, User, id: user.id
      can :read, Page
      can :verify, Sign
  
      unless user.blocked?
        can :update, User, id: user.id
        can :read, User
        can :create, Key
        can [:read, :create], Certificate
        can [:sign_request, :show_request], Certificate, parent_certificate_owner_id: user.id
        can [:read, :update, :destroy], Key, user_id: user.id
        can [:update, :destroy], Certificate, user_id: user.id
        
        can :show_certificates, Key, user_id: user.id
        can [:show_signs, :show_requests, :show_issued], Certificate, user_id: user.id
        
        can :create, Page
        can [:sign, :edit, :update, :destroy], Page, user_id: user.id
      end
      
      if user.admin?
        can :access, :all
        can [:read, :update, :destroy, :block], User
        can [:show_certificates, :read, :update, :destroy], :keys
        can [:show_requestsm, :show_issued, :read, :update, :destroy], :certificates
      end
    end
  end
end
