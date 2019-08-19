class UserMailer < ApplicationMailer

  default from: "yinyinaye12795@gmail.com"
  

  def invite(user, mworkspace)
    @user = user
    @mworkspace = mworkspace
    mail to: user.email, subject: "Member invitation"
  end
end
