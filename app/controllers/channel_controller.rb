class ChannelController < ApplicationController
  
  

    def chchannel
     
    end
    def createchannel
      @mchannel = MChannel.new(channel_params)
     
      @mchannel.user_id = session[:muser_id]
      
      @mchannel.workspace_id = session[:workspace_id]
      
      @mchannel.member = 1
      if @mchannel.save
        session[:channel_name] = @mchannel.channel_name
        
        mchannel = MChannel.find_by(channel_name: session[:channel_name])
       
        channel mchannel
        
        redirect_to home_path
      else
        redirect_to login_path
      end 
    end
    private
    def channel_params
      params.require(:mchannel).permit(:channel_name,:status)
    end
  end
    
  

 


  
  
