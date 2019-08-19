module SessionsHelper
     
  def log_in(muser)
    session[:muser_id] = muser.id
    session[:muser_name] = muser.user_name
  end

  def log(mworkspace)
    session[:workspace_id] = mworkspace.id
    session[:workspace_name] = mworkspace.workspace_name
    
  end

  
  def dir(diruser)
    session[:diruser_id] = diruser.id
    session[:diruser_name] = diruser.user_name
  end

  def thread(dirthread)
    session[:dir_thread_id] = dirthread.id
  end

  def channel_thread(channelthread)
    session[:channel_thread_id] = channelthread.id
    #session[:channel_sender] = channelthread.sender_id
    #session[:channel_msg] = channelthread.channel_msg
  end
  #kmmg
  def channel(mchannel)
    session[:channel_id] = mchannel.id
    session[:channel_name] = mchannel.channel_name
    session[:status] = mchannel.status
  end

  
 
  def log_out
    #forget(current_muser)
    session.delete(:muser_id)
    session.delete(:muser_name)
    session.delete(:workspace_id)
    session.delete(:user_id)
    session.delete(:channel_id)
    session.delete(:channel_name)
    session.delete(:status)

    @current_muser=nil
  end
  #kmmg
  #def channel_name(channelname)
    #session[:channel_name] = channelname.channel_name
  #end
  
 # Returns the current logged-in user (if any).
 def current_muser
  if (muser_id = session[:muser_id])
    @current_muser ||= MUser.find_by(id: muser_id)
  elsif (muser_id = cookies.signed[:muser_id])
    muser = MUser.find_by(id: muser_id)
    if muser && muser.authenticated?(:remember, cookies[:remember_token])
      log_in muser
      @current_muser = muser
    end
  end
end
   # Returns true if the user is logged in, false otherwise.
   def logged_in?
    !current_muser.nil?
  end
end
