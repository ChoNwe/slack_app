class MuserController < ApplicationController
  def new
    @muser = MUser.new
  end
  def create
    @muser = MUser.new(user_params)
    if @muser.save
      session[:muser_id] = @muser.id
      session[:muser_name] = @muser.user_name
      flash[:success] = "Sign Up Successful"
      redirect_to workspacecreate_path
    else
      render 'new'
    end
  end
  def search
    mworkspace = MWorkspace.find_by(workspace_name: params[:workspace][:workspace_name])
    museremail=MUser.find_by(email: params[:workspace][:email].downcase)
    if mworkspace && museremail && museremail.authenticate(params[:workspace][:password])
      log mworkspace
      mworkspace = MWorkspace.find_by(workspace_name: session[:workspace_name])
      log mworkspace
      flash[:info] = "Found your Workspace"
      redirect_to home_path
    else
      flash[:danger]  = 'Invalid email/password/workspace name combination'
      redirect_to searchworkspace_path
    end
  end
  private
    def user_params
      params.require(:muser).permit(:user_name, :email, :password, :password_confirmation)
    end
end
