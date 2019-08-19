# Preview all emails at http://localhost:3000/rails/mailers/m_user_mailer
class MUserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/m_user_mailer/account_activation
  def account_activation
    muser = MUser.first
    muser.activation_token = MUser.new_token
    MUserMailer.account_activation(muser)
  end

  # Preview this email at http://localhost:3000/rails/mailers/m_user_mailer/password_reset
  def password_reset
    MUserMailer.password_reset
  end

end
