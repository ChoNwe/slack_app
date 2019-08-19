Rails.application.routes.draw do

  root 'users#welcome'
  
  #Yin Yin Aye 
  get '/workspacecreate',    to: 'users#workspacecreate'
  get '/managemember',    to: 'users#managemember'
  get '/home',    to: 'users#home'
  ##post '/home',    to: 'users#home'
  get  '/welcome',    to: 'users#welcome'
  get  '/memberlist',    to: 'users#memberlist'
  get  '/addmember',    to: 'users#addmember'
  get  '/memberadd',    to: 'users#add'
  ##get  '/remove',    to: 'users#remove'
  delete  '/remove',    to: 'users#remove'
  ##get  '/admin',    to: 'users#admin'
  patch  '/admin',    to: 'users#admin' 
  #20190711
  ##get  '/user',    to: 'users#user'
  patch  '/user',    to: 'users#user' 
  #20190711
  #20190625
  get '/unread',    to: 'users#unread'
  post '/unread',    to: 'users#unread'
  patch '/unread',    to: 'users#unread'
  get '/unreadall',    to: 'users#unreadall'
  patch '/unreadall',    to: 'users#unreadall'
  get '/invite',    to: 'users#invite'
  post '/join',    to: 'users#join'
  #Thu Zin Tun
  get  '/invitesuccess',    to: 'users#invitesuccess'
  post '/invitesuccess',    to: 'users#invitesuccess'
  get  '/memberinvite',    to: 'users#memberinvite' 
  get 'sessions/new'
  get  '/signup',  to: 'muser#new'
  post  '/create',  to: 'muser#create'
  get  '/workspacecreate',  to: 'muser#workspacecreate' 
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy' 
  get  '/searchworkspace',    to: 'users#searchworkspace' 
  post  '/searchworkspace',    to: 'muser#search' 
  
  #Aye Aye Mu
  #get  '/searchworkspace',    to: 'users#searchworkspace'
  #get  '/newworkspace',    to: 'users#newworkspace'
  #get  '/channelcreate',    to: 'users#channelcreate'
  #post  '/channelcreate',    to: 'users#channelcreate'
  get  '/member',    to: 'users#member'

  #KMMG
  get '/newworkspace', to: 'sessions#newworkspace'
 # post '/newworkspace', to: 'sessions#newworkspace'
  post  '/workspacecreate',    to: 'sessions#workspacecreate'
  #get  '/workspacecreate',    to: 'sessions#workspacecreate'
  get  '/chchannel',    to: 'channel#chchannel'
  #post  '/chchannel',    to: 'channel#chchannel'
  get  '/createchannel',    to: 'channel#createchannel'
  post  '/createchannel',    to: 'channel#createchannel'

  #chat
  #cna
  get '/channelchat',    to: 'users#channel_chat'
  ##post '/channelchat',    to: 'users#channel_chat'
  get '/dirchat',    to: 'users#dirchat'
  post '/dirchat',    to: 'users#dirchat'
  ##get '/msgsend',    to: 'users#msgsend'
  post '/msgsend',    to: 'users#msgsend'
  get '/mention', to: 'users#mention'
  post '/mention', to: 'users#mention'
  get '/dirmsgsend',    to: 'users#dirmsgsend'
  post '/dirmsgsend',    to: 'users#dirmsgsend'
  get '/dirthread',    to: 'users#dirthread'
  post '/dirthread',    to: 'users#dirthread'
  get '/dirthreadinsert',    to: 'users#dirthread_insert'
  post '/dirthreadinsert',    to: 'users#dirthread_insert'
  get '/channelthread',    to: 'users#channelthread'
  ##post '/channelthread',    to: 'users#channelthread'
  ##get '/channelthreadinsert',    to: 'users#channelthread_insert'
  post '/channelthreadinsert',    to: 'users#channelthread_insert'
  get '/threadselect',    to: 'users#threadselect'
  ##post  '/removechannel',    to: 'users#removechannel'
  delete  '/removechannel',    to: 'users#removechannel'
  
  # direct star
  get '/dirstar',  to: 'users#dirstar_message'
  get '/dirunstar',  to: 'users#dirunstar_message'

  get '/chastar',  to: 'users#chastar_message'
  get '/chaunstar',  to: 'users#chaunstar_message'
 
  get '/star',  to: 'users#star'
  get '/dirdelete', to:'users#dirdelete'
  get '/chadelete', to:'users#chadelete'
  get '/destroy', to:'sessions#destroy'
  delete '/destroy', to:'sessions#destroy'
  
  get '/refresh', to: 'users#refresh'
  
  
  resources :m_channels
  resources :m_users
  resources :account_activations, only: [:edit]
  #resources :t_channel_msg,          only: [:msgsend, :destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
end
