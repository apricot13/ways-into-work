class Advisor::AdvisorController < Advisor::BaseController
  before_action :check_permissions!
  expose :advisor, build: ->(params, scope) { scope.new(params.merge(login: UserLogin.new)) }

  def new; end
  
  def create
    if advisor.save
      redirect_to user_root
    else
      render :new
    end
  end
  
  private
  
  def check_permissions!
    not_authorised unless current_advisor.admin?
  end
  
  def advisor_params
    params.require(:advisor).permit(:name, :phone, :hub_id, :role, login_attributes: [:email])
  end
  
end
