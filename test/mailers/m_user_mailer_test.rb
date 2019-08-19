require 'test_helper'

class MUserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    test "account_activation" do
      muser = muser(:user)
      muser.activation_token = MUser.new_token
      mail = MUserMailer.account_activation(muser)
      assert_equal "Account activation", mail.subject
      assert_equal [muser.email], mail.to
      assert_equal ["noreply@gmail.com"], mail.from
      assert_match muser.user_name,               mail.body.encoded
      assert_match muser.activation_token,   mail.body.encoded
      assert_match CGI.escape(muser.email),  mail.body.encoded
    end

  test "password_reset" do
    mail = MUserMailer.password_reset
    assert_equal "Password reset", mail.subject
    assert_equal ["to@gmail.com"], mail.to
    assert_equal ["from@gmail.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
