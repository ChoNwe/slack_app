class SessionsController < ApplicationController
  def new
  end
  def create
    muser = MUser.find_by(email: params[:session][:email].downcase)
    if muser && muser.authenticate(params[:session][:password])
        log_in muser
        redirect_to workspacecreate_path
    else
      flash.now[:danger]  = 'Invalid email/password combination'
      render 'new'
    end
  end
  def newworkspace
    @mworkspace = MWorkspace.new   
  end
  def workspacecreate
    @mworkspace = MWorkspace.new(workspace_params)
    @mworkspace.admin = 1
    @mworkspace.user_id = session[:muser_id]
    if @mworkspace.save
      session[:workspace_name] = @mworkspace.workspace_name
      @workspaces = MWorkspace.where(user_id: session[:muser_id]).order(id: :desc)
      session[:workspace_id] = @workspaces[0].id

      #log mworkspace
      redirect_to chchannel_path
    else
      render 'newworkspace'
    end
  end
  def destroy
    log_out
    redirect_to root_url
  end
  private
  def workspace_params
    params.require(:mworkspace).permit(:workspace_name)
  end

end
