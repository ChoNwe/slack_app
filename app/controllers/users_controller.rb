class UsersController < ApplicationController
    
    def welcome
    end
    
    def home
        #call list method
        left_panel
    end
    
    #Channel Chat Room
    def channel_chat
        channel_memberlist
        #create session for channel
        mchannel = MChannel.find_by(id:params[:chid])
        channel mchannel
        

        #select all user for mention
        @channeluser = MChannel.select("m_users.id as userid, m_users.user_name").
        joins("join m_users on m_users.id = m_channels.user_id").
        where("m_channels.member=1 and m_channels.id=?",session[:channel_id])
        
        #select corresponding channel messages
        @channel_msg = TChannelMsg.select("m_users.user_name,t_channel_msgs.id, t_channel_msgs.channel_msg, t_channel_msgs.sender_id, t_channel_msgs.created_at").
        joins("join m_users on t_channel_msgs.sender_id = m_users.id").
        where("t_channel_msgs.channel_id = ?", session[:channel_id]).
        order("t_channel_msgs.created_at")

        #update channel message as read after click event
        TChannelUnreadMsg.joins("join t_channel_msgs on t_channel_msgs.id = t_channel_unread_msgs.channel_msg_id").
                    where("t_channel_msgs.channel_id=? and t_channel_unread_msgs.unread_user_id=?",session[:channel_id],session[:muser_id]).update(:unread=>0)
        
        #channel thread count
        @ch_thread_count = []
        for channelmsg in @channel_msg
            @channel_msg_thread = TChannelMsg.select("count(t_channel_msgs.parent_msg_id) as count,t_channel_msgs.parent_msg_id").
                    where("t_channel_msgs.parent_msg_id= ?", channelmsg.id)
            for msg_thread in @channel_msg_thread
                @ch_thread_count << msg_thread
            end
        end
        
        #select star message id for channel
        @chastrid=TChaMsgStr.select("cha_msg_id").where("str_user_id=?",session[:muser_id])

        #create array and push star message id in array
        @t_chastarids = Array.new
        @chastrid.each{|i| @t_chastarids.push(i.cha_msg_id)}
         
        #call list method
        left_panel
    end

    #send message when click send button
    def msgsend
        
        @channel_msg = TChannelMsg.new
        @channel_msg.channel_id = session[:channel_id]
        @channel_msg.sender_id = session[:muser_id]
        @channel_msg.channel_msg = params[:tchamsg][:msg]
        @channel_msg.save
        #current message id
        last_id = TChannelMsg.maximum("id")
        channel_memberlist
        @member_list.each do |memberlist|
            @channel_unread = TChannelUnreadMsg.new
            @channel_unread.channel_msg_id = last_id
            @channel_unread.unread_user_id = memberlist.userid
            @channel_unread.unread = 1
            @channel_unread.save
        end

        #mention
        mention_name = params[:tchamsg][:memtion_name]
        mention_name[0] = ''
        @mention_user = MUser.find_by(user_name: mention_name) 

        unless @mention_user.nil?
            @channel_mention = TMention.new
            mention = MUser.find_by(user_name: mention_name)
            if mention
                @channel_mention.mentioned_user_id = mention.id
                @channel_mention.t_cha_msg_id = last_id
                @channel_mention.save
            end
        end
        
        redirect_back(fallback_location:msgsend_path)
    end
	
	
	
	
	
	
	#mention select
	def mention
        left_panel
        #select mention item
        @mention = TMention.select("t_channel_msgs.channel_msg,m_users.user_name, t_channel_msgs.created_at").
        joins("join t_channel_msgs on t_channel_msgs.id = t_mentions.t_cha_msg_id").
        joins("join m_users on t_channel_msgs.sender_id = m_users.id").
        where("t_mentions.mentioned_user_id =?", session[:muser_id])
    end

    #Channel Thread
    def channelthread
        channel_memberlist
        channelthread= TChannelMsg.find_by(id:params[:channel_thread_id])
        channel_thread channelthread
       
        #select parent message
        @channel_original_msg = TChannelMsg.select("m_users.user_name, t_channel_msgs.channel_msg, t_channel_msgs.created_at").
                            joins("join m_users on m_users.id = t_channel_msgs.sender_id").
                            where("t_channel_msgs.id=?", session[:channel_thread_id])
        #select thread message
        @channel_thread_msg = TChannelMsg.select("m_users.user_name, t_channel_msgs.thread_msg, t_channel_msgs.created_at").
                            joins("join m_users on m_users.id = t_channel_msgs.replier_id").
                            where("t_channel_msgs.parent_msg_id=?", session[:channel_thread_id])

        left_panel
    end
    
    #insert channel thread message
    def channelthread_insert
        @cha_thread = TChannelMsg.new 
        @cha_thread.replier_id = session[:muser_id]
        @cha_thread.parent_msg_id = session[:channel_thread_id]
        @cha_thread.thread_msg = params[:channelthread][:msg]
        @cha_thread.save
        redirect_back(fallback_location:channelthread_path)
    end

    #insert channel star message
    def chastar_message
        if params[:t_cha_star_id]
            @m_cha_msg_str=TChaMsgStr.new(:cha_msg_id =>params[:t_cha_star_id],:str_user_id =>session[:muser_id])
            @m_cha_msg_str.save   
        end
        redirect_back(fallback_location:channelchat_path)
    end

    #destroy channel star message 
    def chaunstar_message
        messageid=params[:t_cha_star_id]
        @ch_msg_strid=TChaMsgStr.select("id").where("cha_msg_id=?", messageid)
        @m_cha_msg_unstar=TChaMsgStr.where(:id => @ch_msg_strid).destroy_all
        redirect_back(fallback_location:channelchat_path)
    end
   
    #Direct Chat Room
    def dirchat
        diruser= MUser.find_by(id:params[:id])
        dir diruser
      
        #select corresponding direct message
        @dir_msg_all = TDirectMsg.select("sender.user_name as s, receiver.user_name as r, t_direct_msgs.id, t_direct_msgs.message, t_direct_msgs.created_at").
                    joins("join m_users as sender on t_direct_msgs.sender_id = sender.id").
                    joins("join m_users as receiver on t_direct_msgs.receiver_id = receiver.id ").
                    where("(t_direct_msgs.sender_id = ?
                    and t_direct_msgs.receiver_id = ?
                    or t_direct_msgs.sender_id = ?
                    and t_direct_msgs.receiver_id = ?)
                    and t_direct_msgs.workspace_id = ?",
                    session[:diruser_id], session[:muser_id], session[:muser_id], session[:diruser_id], session[:workspace_id])
        
        #direct thread count
        @dir_thread_count = []
        for dirmsgread in @dir_msg_all
            @dir_msg_thread = HDirectMsgThread.select("count(h_direct_msg_threads.dir_msg_id) as count,h_direct_msg_threads.dir_msg_id").
                    joins("join t_direct_msgs on h_direct_msg_threads.dir_msg_id = t_direct_msgs.id").
                    where("h_direct_msg_threads.dir_msg_id= ?", dirmsgread.id)
            for msg_thread in @dir_msg_thread
                @dir_thread_count << msg_thread
            end
        end

        #select direct unread message
        @dir_msg_unread = TDirectMsg.select("m_users.user_name, t_direct_msgs.message, t_direct_msgs.created_at").
                    joins("join m_users on t_direct_msgs.sender_id = m_users.id").
                    where("t_direct_msgs.unread=1 and t_direct_msgs.sender_id = ?
                    and t_direct_msgs.receiver_id = ?
                    and t_direct_msgs.workspace_id = ?",
                    session[:diruser_id], session[:muser_id], session[:workspace_id])
        
        @dir_msg_sent = TDirectMsg.select("m_users.user_name, t_direct_msgs.message, t_direct_msgs.created_at").
                    joins("join m_users on t_direct_msgs.sender_id = m_users.id").
                    where("t_direct_msgs.unread=1 and t_direct_msgs.sender_id = ?
                    and t_direct_msgs.receiver_id = ?
                    and t_direct_msgs.workspace_id = ?",
                    session[:muser_id], session[:diruser_id], session[:workspace_id])
        #update direct message as read after click event          
        TDirectMsg.where(:receiver_id=>session[:muser_id], :sender_id=>session[:diruser_id]).update(:unread=>0)
        @dirstrid = TDirMsgStr.select("t_dir_msg_id").where("dir_str_user_id=?",session[:muser_id]) 
        
        #create array and push star message id in array
        @t_dirstarids = Array.new
        @dirstrid.each{|i| @t_dirstarids.push(i.t_dir_msg_id)}
        
        left_panel
    end

    #send message when click send button
    def dirmsgsend
        @dir_msg = TDirectMsg.new
        @dir_msg.sender_id = session[:muser_id]
        @dir_msg.receiver_id = session[:diruser_id]
        @dir_msg.workspace_id = session[:workspace_id]
        @dir_msg.message = params[:dirmsg][:msg]
        @dir_msg.unread = 1
        @dir_msg.save
        #@dir_msg.reload
        redirect_back(fallback_location:dirmsgsend_path)

    end

    #Direct Thread
    def dirthread
        dirthread= TDirectMsg.find_by(id:params[:dir_thread_id])
        thread dirthread

        #select parent message
        @dir_original_msg = TDirectMsg.select("t_direct_msgs.message, m_users.user_name, t_direct_msgs.created_at").
                            joins("join m_users on m_users.id = t_direct_msgs.sender_id").
                            where("t_direct_msgs.id=?", session[:dir_thread_id])
        #select thread message        
        @dir_thread_msg = MUser.select("m_users.user_name, h_direct_msg_threads.thread_msg, h_direct_msg_threads.created_at").
                            joins("join h_direct_msg_threads on m_users.id = h_direct_msg_threads.user_id").
                            joins("join t_direct_msgs on t_direct_msgs.id = h_direct_msg_threads.dir_msg_id").
                            where("t_direct_msgs.id=?", session[:dir_thread_id])
        left_panel
    end
    
    #insert direct thread message
    def dirthread_insert
        @dir_thread = HDirectMsgThread.new
        @dir_thread.dir_msg_id = session[:dir_thread_id]
        @dir_thread.user_id = session[:muser_id]
        @dir_thread.thread_msg = params[:dirthread][:msg]
        @dir_thread.unread = 1
        @dir_thread.save
        redirect_back(fallback_location:dirthread_path)
    end

    #direct message delete
    def dirdelete
       
        TDirectMsg.where(:id=>params[:t_dir_star_id]).delete_all
		flash[:success]="Message Deleted"
        redirect_back(fallback_location:dirchat_path)
    end

    #channel message delete
    def chadelete
       
        TChannelMsg.where(:id=>params[:t_cha_star_id]).delete_all
		flash[:success]="Message Deleted"
        redirect_back(fallback_location:channelchat_path)
    end
    #insert star message
    def dirstar_message
        if params[:t_dir_star_id]
            @m_dir_msg_str=TDirMsgStr.new(:t_dir_msg_id =>params[:t_dir_star_id],:dir_str_user_id =>session[:muser_id])
            @m_dir_msg_str.save   
        end
        left_panel
        redirect_back(fallback_location:dirchat_path)
    end

    #destroy direct star message
    def dirunstar_message
        messageid=params[:t_dir_star_id]
        @delete=TDirMsgStr.select("id").where("t_dir_msg_id=?", messageid)
        TDirMsgStr.where(:id => @delete).destroy_all
        redirect_back(fallback_location:dirchat_path)
    end
    


    #Select thread message
    def threadselect
        #select parent message
        @dirorigin = TDirectMsg.select("t_direct_msgs.message, m_users.user_name,t_direct_msgs.id, t_direct_msgs.created_at").
                            joins("join m_users on m_users.id = t_direct_msgs.sender_id").
                            joins("join h_direct_msg_threads on h_direct_msg_threads.dir_msg_id = t_direct_msgs.id").
                            where("h_direct_msg_threads.user_id = ?", session[:muser_id])

        @thread_msg_array = []
        for dirorigin in @dirorigin
            @dirreply = MUser.select("h_direct_msg_threads.dir_msg_id, m_users.user_name, h_direct_msg_threads.thread_msg, h_direct_msg_threads.created_at").
            joins("join h_direct_msg_threads on m_users.id = h_direct_msg_threads.user_id").
            where("h_direct_msg_threads.dir_msg_id=?", dirorigin.id)
            for reply in @dirreply
                @thread_msg_array << reply
            end
        end
        
        @parent_id = TChannelMsg.select("distinct(parent_msg_id)").where("replier_id = ?", session[:muser_id])
        @parent_user = []
        for id in @parent_id
            @channelorigin = MUser.select("m_users.user_name, t_channel_msgs.id, t_channel_msgs.channel_msg, t_channel_msgs.created_at").
                joins("join t_channel_msgs on t_channel_msgs.sender_id = m_users.id").
                where("t_channel_msgs.id = ?", id.parent_msg_id)
            for par_user in @channelorigin
                @parent_user << par_user 
            end
        end
        @thread_user = []
        for chthread in @parent_id
            @channelthread = MUser.select("m_users.user_name, t_channel_msgs.parent_msg_id, t_channel_msgs.thread_msg, t_channel_msgs.created_at").
                        joins("join t_channel_msgs on t_channel_msgs.replier_id = m_users.id").
                        where("t_channel_msgs.parent_msg_id=?", chthread.parent_msg_id)
            for thr_user in @channelthread
                @thread_user << thr_user
            end
        end
        left_panel
    end
    

    def memberlist
        left_panel
        channel_memberlist
    end

    #show all member
    def addmember
        left_panel
        channel_memberlist
        exist
    end
  
    #add member to channel
    def add
        
        user_id = params[:user_id]
        @exist_member=MChannel.select("user_id").
        where("m_channels.id = ? and workspace_id=? and user_id=?", session[:channel_id], session[:workspace_id], user_id)
        #@array3 = Array.new
        #@exist_member.each{|i| @array3.push(i.user_id)}

        if @exist_member.exists?
                MChannel.where(:id=>session[:channel_id],:user_id=>user_id).update_all(:member=>1)
        else
            @add = MChannel.new(:id=>session[:channel_id], :user_id=>user_id, :workspace_id=>session[:workspace_id], :channel_name=>session[:channel_name], :status=>session[:status], :member=>1)
            @add.save
           
        end
        redirect_to addmember_path
    end
   

    #remove member from channel
    def remove
        member_id=params[:user_id]
        MChannel.where(:id=>session[:channel_id],:user_id=>member_id).update_all(:member=>0)
        flash[:success] = "User deleted"
        redirect_to memberlist_path
    end
    
    #change user to admin
    def admin
        admin_id=params[:user_id]
        MWorkspace.where(:id=>session[:workspace_id],:user_id=>admin_id).update_all(:admin=>1)
        flash[:success] = "Admin Changed"
        redirect_to managemember_path
    end

    #change admin to user
    def user
        user_id=params[:user_id]
        MWorkspace.where(:id=>session[:workspace_id],:user_id=>user_id).update_all(:admin=>0)
        flash[:success] = "User Changed"
        redirect_to managemember_path
    end

    #manage member if current user is admin
    def managemember
        left_panel
        @admin=MWorkspace.select("user_id").joins("join m_users on m_users.id=m_workspaces.user_id").
                where("m_workspaces.admin=1 and m_workspaces.id=?",session[:workspace_id])
    end

	
	#Unread Message
    def unread

        
        #update direct message as read
        @m_dir_msg=TDirectMsg.where(:sender_id => params[:sender_id],:receiver_id => session[:muser_id]).update(:unread => 0)
        
        #update channel message as read
        @m_channel_msg=TChannelUnreadMsg.joins("join t_channel_msgs on t_channel_msgs.id = t_channel_unread_msgs.channel_msg_id").
                    where("t_channel_msgs.channel_id=? and t_channel_unread_msgs.unread_user_id=?",params[:channel_id],session[:muser_id]).update(:unread=>0)

          
        left_panel 
        #select all direct unread message
        @all_dir_unread=TDirectMsg.select("t_direct_msgs.sender_id as sender_id,sender.user_name, t_direct_msgs.message, t_direct_msgs.id, t_direct_msgs.created_at").
                joins("left join m_users as sender on t_direct_msgs.sender_id = sender.id").
                where("t_direct_msgs.receiver_id = ?
                and t_direct_msgs.unread=1", session[:muser_id]).
                order("sender.user_name")
        

        #select all channel unread message
        @all_channel_unread=TChannelUnreadMsg.select("distinct(m_channels.channel_name),m_channels.id as channel_id,m_users.user_name,t_channel_msgs.id as ch_msg_id, t_channel_msgs.channel_msg,t_channel_msgs.created_at").
        joins("join t_channel_msgs on t_channel_msgs.id = t_channel_unread_msgs.channel_msg_id").
        joins("join m_channels on t_channel_msgs.channel_id = m_channels.id").
        joins("join m_users on t_channel_msgs.sender_id = m_users.id").
        where("t_channel_unread_msgs.unread = 1
        and t_channel_unread_msgs.unread_user_id = ?", session[:muser_id])
    end


    #update all unread message as read
    def unreadall
     
        #select all direct unread message
        @all_dir_unread=TDirectMsg.select("t_direct_msgs.sender_id as sender_id,sender.user_name, t_direct_msgs.message, t_direct_msgs.id, t_direct_msgs.created_at").
                joins("left join m_users as sender on t_direct_msgs.sender_id = sender.id").
                where("t_direct_msgs.receiver_id = ?
                and t_direct_msgs.unread=1", session[:muser_id]).
                order("sender.user_name")
        
        #select all channel unread message
        @all_channel_unread=TChannelUnreadMsg.select("distinct(m_channels.channel_name),m_channels.id as channel_id,m_users.user_name,t_channel_msgs.id as ch_msg_id, t_channel_msgs.channel_msg,t_channel_msgs.created_at").
                        joins("join t_channel_msgs on t_channel_msgs.id = t_channel_unread_msgs.channel_msg_id").
                        joins("join m_channels on t_channel_msgs.channel_id = m_channels.id").
                        joins("join m_users on t_channel_msgs.sender_id = m_users.id").
                        where("t_channel_unread_msgs.unread = 1
                        and t_channel_unread_msgs.unread_user_id = ?", session[:muser_id])

        #update all channel message as read
        @all_channel_unread.each do |c|
            TChannelUnreadMsg.where(:channel_msg_id => c.ch_msg_id,:unread => 1).update(:unread => 0)
        end
        #update all direct message as read
        @all_dir_unread.each do |c|
            TDirectMsg.where(:id => c.id,:unread => 1).update(:unread => 0)
        end
    
       
        redirect_to unread_path

    end

    #Member Invitation
    def memberinvite
        
        @mworkspace = MWorkspace.select("id,workspace_name").where("id=?", session[:workspace_id])
    end

    #Invitation Success
    def invitesuccess
        left_panel
        @muser1= MUser.new()
        @muser1.email = params[:invite][:email1]
        @mworkspace = MWorkspace.new()
        @mworkspace.id = session[:workspace_id]
        
        #Confirm user already exist in user table
        user1 = MUser.find_by(email: @muser1.email )
        if user1
            if (MWorkspace.where("user_id=? and id=?", user1.id, @mworkspace.id))==nil
                UserMailer.invite(user1,@mworkspace).deliver_now
            else
                flash[:danger] = 'Already Exist User'
                redirect_to memberinvite_path
            end 
        else
            UserMailer.invite(@muser1,@mworkspace).deliver_now
        end 
        

        @muser2= MUser.new()
        @muser2.email = params[:invite][:email2]
        
       
        #Confirm user already exist in user table
        user2 = MUser.find_by(email: @muser2.email )
        
        if user2
            if (MWorkspace.where("user_id=? and id=?", user2.id, @mworkspace.id)[0])==nil
                UserMailer.invite(@muser2,@mworkspace).deliver_now
            else
                flash[:danger] = 'Already Exist User'
                redirect_to memberinvite_path
            end 
        else
            UserMailer.invite(@muser2,@mworkspace).deliver_now
        end 

        @muser3= MUser.new()
        @muser3.email = params[:invite][:email3]
       
        
        #Confirm user already exist in user table
        user3 = MUser.find_by(email: @muser3.email )
        if user3
            if (MWorkspace.where("user_id=? and id=?", user3.id, @mworkspace.id)[0])==nil
                UserMailer.invite(@muser3,@mworkspace).deliver_now
            else
                flash[:danger] = 'Already Exist User'
                redirect_to memberinvite_path
            end 
        else
            UserMailer.invite(@muser3,@mworkspace).deliver_now
        end 
       
     
    end
    def member
        @muser = MUser.new()
        @muser.email = params[:email]
        @mworkspace = MWorkspace.select("workspace_name").where("id=?", params[:workspace_id])
        
    end

    #join to workspace from email
    def join 
        email = params[:email]
        
        if MUser.find_by(email: email)
            @user = MUser.find_by(email: email)
            #Confirm User 
            if @user && @user.user_name == params[:muser][:user_name] && @user.authenticate(params[:muser][:password])
                @i_workspace =MWorkspace.find_by(id: params[:workspace_id])
                #create seesion for user
                session[:muser_name] = @user.user_name
                session[:muser_id] = @user.id
                #create new workspace
        
                @mworkspace = MWorkspace.new(:id=>@i_workspace.id, :user_id=>@user.id, :workspace_name=>@i_workspace.workspace_name, :admin=> 0)
                @mworkspace.save
                #create seesion for workspace
                session[:workspace_id] = @mworkspace.id
                session[:workspace_name] = @mworkspace.workspace_name
                redirect_to home_url
            else
                flash[:danger] = 'Did not match User Name Or Password!'
                redirect_to member_path
            end
        else
            
            @muser = MUser.new()
            @muser = MUser.new(user_params)    # Not the final implementation!
            if @muser.save
                @i_workspace =MWorkspace.find_by(id: params[:workspace_id])
                #create session for user
                session[:muser_name] = @muser.user_name
                session[:muser_id] = @muser.id
                @mworkspace = MWorkspace.new(:id=>@i_workspace.id, :user_id=>@muser.id, :workspace_name=>@i_workspace.workspace_name, :admin=> 0)
                
                @mworkspace.save
                #create session for workspace
                session[:workspace_id] = @mworkspace.id
                session[:workspace_name] = @mworkspace.workspace_name
                
                redirect_to home_url
            else
                flash[:danger] = 'Something went wrong!'
                redirect_to member_path
            end
        end
        
        left_panel
    end

    #select star item
    def star
        left_panel
        
        #select channel star message
        @show_ch_msgstr=TChannelMsg.select("distinct(t_channel_msgs.channel_msg), m_users.user_name, t_channel_msgs.created_at, m_channels.channel_name").
              joins("join t_cha_msg_strs on t_cha_msg_strs.cha_msg_id=t_channel_msgs.id").
              joins("join m_users on t_channel_msgs.sender_id=m_users.id").
              joins("join m_channels on t_channel_msgs.channel_id=m_channels.id").
              where("t_cha_msg_strs.str_user_id=?", session[:muser_id])
        
              #select direct star message
        @show_dir_msgstr=TDirectMsg.select("t_direct_msgs.message, m_users.user_name, t_direct_msgs.created_at").
              joins("join t_dir_msg_strs on t_dir_msg_strs.t_dir_msg_id=t_direct_msgs.id").
              joins("join m_users on t_direct_msgs.sender_id=m_users.id").
              where("t_dir_msg_strs.dir_str_user_id=?", session[:muser_id])
    end
    

    
    #refresh div
    def refresh

        #check user
        @check_admin = MWorkspace.select("workspace_name,admin").where("id=? and user_id=?",session[:workspace_id], session[:muser_id])
        
        #select user
        @muser=MUser.select("m_users.id, m_users.user_name").joins("join m_workspaces on m_users.id=m_workspaces.user_id ").
                where("m_workspaces.id=?",session[:workspace_id])

        @public_channel=MChannel.select("distinct(channel_name),id,status").
                where("status=1 and workspace_id=?",session[:workspace_id])


        #select channel
        @mchannel=MChannel.select("id,channel_name,status").
                where("member=1 and status=0 and workspace_id=? and user_id=?",session[:workspace_id], session[:muser_id])
        
        #select direct message count
        @dir_count=TDirectMsg.select("sum(unread) as count, m_users.user_name").
                    joins("join m_users on m_users.id=t_direct_msgs.sender_id").
                    where("t_direct_msgs.unread=1 and t_direct_msgs.workspace_id=?
                    and t_direct_msgs.receiver_id=?", session[:workspace_id], session[:muser_id]).
                    group("t_direct_msgs.sender_id")
         
        #select channel message count            
        @channel_count=TChannelUnreadMsg.select("sum(unread)as count,t_channel_msgs.channel_id").
                        joins("join t_channel_msgs on t_channel_msgs.id=t_channel_unread_msgs.channel_msg_id").
                        where("t_channel_unread_msgs.unread=1 and t_channel_unread_msgs.unread_user_id=?", session[:muser_id]).
                        group("t_channel_msgs.channel_id")
                        
        @all_dir_un_count=0
        @all_ch_un_count=0
        @channel_count.each do |c|
            @all_ch_un_count+=c.count
        end
        @dir_count.each do |c|
            @all_dir_un_count+=c.count
        end 
        @all_count=@all_dir_un_count+@all_ch_un_count
        
        

        #dirchat for refresh
        
       
        
        @dir_msg_all = TDirectMsg.select("sender.user_name as s, receiver.user_name as r, t_direct_msgs.id, t_direct_msgs.message, t_direct_msgs.created_at").
                    joins("join m_users as sender on t_direct_msgs.sender_id = sender.id").
                    joins("join m_users as receiver on t_direct_msgs.receiver_id = receiver.id ").
                    where("(t_direct_msgs.sender_id = ?
                    and t_direct_msgs.receiver_id = ?
                    or t_direct_msgs.sender_id = ?
                    and t_direct_msgs.receiver_id = ?)
                    and t_direct_msgs.workspace_id = ?",
                    session[:diruser_id], session[:muser_id], session[:muser_id], session[:diruser_id], session[:workspace_id])
        
        @dir_thread_count = []
        for dirmsgread in @dir_msg_all
            @dir_msg_thread = HDirectMsgThread.select("count(h_direct_msg_threads.dir_msg_id) as count,h_direct_msg_threads.dir_msg_id").
                    joins("join t_direct_msgs on h_direct_msg_threads.dir_msg_id = t_direct_msgs.id").
                    where("h_direct_msg_threads.dir_msg_id= ?", dirmsgread.id)
            for msg_thread in @dir_msg_thread
                @dir_thread_count << msg_thread
            end
        end

        @dir_msg_unread = TDirectMsg.select("m_users.user_name, t_direct_msgs.message, t_direct_msgs.created_at").
                    joins("join m_users on t_direct_msgs.sender_id = m_users.id").
                    where("t_direct_msgs.unread=1 and t_direct_msgs.sender_id = ?
                    and t_direct_msgs.receiver_id = ?
                    and t_direct_msgs.workspace_id = ?",
                    session[:diruser_id], session[:muser_id], session[:workspace_id])

        @dir_msg_sent = TDirectMsg.select("m_users.user_name, t_direct_msgs.message, t_direct_msgs.created_at").
                    joins("join m_users on t_direct_msgs.sender_id = m_users.id").
                    where("t_direct_msgs.unread=1 and t_direct_msgs.sender_id = ?
                    and t_direct_msgs.receiver_id = ?
                    and t_direct_msgs.workspace_id = ?",
                    session[:muser_id], session[:diruser_id], session[:workspace_id])
                    
        TDirectMsg.where(:receiver_id=>session[:muser_id], :sender_id=>session[:diruser_id]).update(:unread=>0)
        @dirstrid = TDirMsgStr.select("t_dir_msg_id").where("dir_str_user_id=?",session[:muser_id]) 
        
     
        @t_dirstarids = Array.new
        @dirstrid.each{|i| @t_dirstarids.push(i.t_dir_msg_id)}
    
        


        #channel chat refresh
        @channel_msg = TChannelMsg.select("m_users.user_name,t_channel_msgs.id, t_channel_msgs.channel_msg, t_channel_msgs.sender_id, t_channel_msgs.created_at").
        joins("join m_users on t_channel_msgs.sender_id = m_users.id").
        where("t_channel_msgs.channel_id = ?", session[:channel_id]).
        order("t_channel_msgs.created_at")

        TChannelUnreadMsg.joins("join t_channel_msgs on t_channel_msgs.id = t_channel_unread_msgs.channel_msg_id").
                    where("t_channel_msgs.channel_id=? and t_channel_unread_msgs.unread_user_id=?",session[:channel_id],session[:muser_id]).update(:unread=>0)
        
        #channel thread count#
        @ch_thread_count = []
        for channelmsg in @channel_msg
            @channel_msg_thread = TChannelMsg.select("count(t_channel_msgs.parent_msg_id) as count,t_channel_msgs.parent_msg_id").
                    where("t_channel_msgs.parent_msg_id= ?", channelmsg.id)
            for msg_thread in @channel_msg_thread
                @ch_thread_count << msg_thread
            end
        end
        
        @chastrid=TChaMsgStr.select("cha_msg_id").where("str_user_id=?",session[:muser_id])

        @t_chastarids = Array.new
        @chastrid.each{|i| @t_chastarids.push(i.cha_msg_id)}


        respond_to do |format|
            format.js
        end

        #delete message after 7 days
        TDirectMsg.where('created_at < ?', 7.days.ago).each do |model|
            model.destroy
        end
        TChannelMsg.where('created_at < ?', 7.days.ago).each do |model|
                model.destroy
        end
        #delete message after 7 days
        
    end
    #remove channel
    def removechannel
        MChannel.where(:id => params[:chid]).delete_all
        flash[:success]="Channel Deleted"
        redirect_back(fallback_location:refresh_path)
    end

    private  
    

    def user_params
        params.require(:muser).permit(:user_name, :email, :password,
                                     :password_confirmation)
    end
    
    def left_panel 
        #check admin
        @check_admin = MWorkspace.select("workspace_name,admin").where("id=? and user_id=?",session[:workspace_id], session[:muser_id])
        #select user
        @muser=MUser.select("m_users.id, m_users.user_name").joins("join m_workspaces on m_users.id=m_workspaces.user_id ").
                where("m_workspaces.id=?",session[:workspace_id])

        @public_channel=MChannel.select("distinct(channel_name),id,status").
                where("status=1 and workspace_id=?",session[:workspace_id])

        
        @mchannel=MChannel.select("id,channel_name,status").
                where("member=1 and status=0 and workspace_id=? and user_id=?",session[:workspace_id], session[:muser_id])
        
        @dir_count=TDirectMsg.select("sum(unread) as count,m_users.id, m_users.user_name,t_direct_msgs.message,t_direct_msgs.created_at").
                    joins("join m_users on m_users.id=t_direct_msgs.sender_id").
                    where("t_direct_msgs.unread=1 and t_direct_msgs.workspace_id=?
                    and t_direct_msgs.receiver_id=?", session[:workspace_id], session[:muser_id]).
                    group("t_direct_msgs.sender_id")

        
                     
        @channel_id=TChannelMsg.select("distinct(m_channels.channel_name), m_channels.id").
                    joins("join m_channels on m_channels.id = t_channel_msgs.channel_id").
                    joins("join t_channel_unread_msgs on t_channel_unread_msgs.channel_msg_id = t_channel_msgs.id").
                    where("t_channel_unread_msgs.unread = 1 
                    and t_channel_unread_msgs.unread_user_id=?", session[:muser_id])
        @channel_count = []
        for chcount in @channel_id
            @channel_count1=TChannelUnreadMsg.select("sum(unread) as count,t_channel_unread_msgs.channel_msg_id,t_channel_msgs.channel_id,t_channel_msgs.channel_msg, m_users.user_name").
                        joins("join t_channel_msgs on t_channel_msgs.id=t_channel_unread_msgs.channel_msg_id").
                        joins("join m_users on m_users.id = t_channel_msgs.sender_id").
                        where("t_channel_unread_msgs.unread=1 
                        and t_channel_unread_msgs.unread_user_id=? and
                        t_channel_msgs.channel_id=?", session[:muser_id], chcount.id).
                        group("t_channel_msgs.channel_id").
                        order("t_channel_msgs.channel_id")
            for count in @channel_count1
                @channel_count << count
            end
        end            
    
        

        @all_dir_un_count=0
        @all_ch_un_count=0
        @channel_count.each do |c|
            @all_ch_un_count+=c.count
        end
        @dir_count.each do |c|
            @all_dir_un_count+=c.count
        end  
        
       
    end

    def channel_memberlist
       @member_list = MChannel.select("m_users.id as userid, m_users.user_name").
       joins("join m_users on m_users.id = m_channels.user_id").
       where("m_channels.member=1 and m_channels.id=?",session[:channel_id]).
       paginate(page: params[:page],per_page: 5) 

       @member_list_count = MChannel.select("m_users.id as userid, m_users.user_name").
       joins("join m_users on m_users.id = m_channels.user_id").
       where("m_channels.member=1 and m_channels.id=?",session[:channel_id])
       
    end

     
     def exist
        @exist=MChannel.select("user_id").
        where("m_channels.member=1 and m_channels.id = ? and workspace_id=?", session[:channel_id], session[:workspace_id])
        
    end
end
