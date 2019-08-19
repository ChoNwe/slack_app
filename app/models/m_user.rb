class MUser < ApplicationRecord
    attr_accessor :remember_token, :activation_token, :reset_token, :password_confirmation
    before_save   :downcase_email
    validates :user_name,  presence: {message: "を入力してください"}, 
    length: { maximum: 50, message: "50文字より短い名前を入力してください" }
    validates :email,  presence: {message: "を入力してください"}, 
                    length: { maximum: 255, message: "が無効です" },
                    uniqueness: {message: "を入力してください",case_sensitive:true}
     has_secure_password validations:false
   validates :password,  presence: {message: "を入力してください"}, 
    length: { minimum: 6, message: "が無効です" }

    validates :password, confirmation:{message:"合わない"}
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    def new_token
      SecureRandom.urlsafe_base64
    end 
    def authenticated?(remember_token)
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
    def forget
      update_attribute(:remember_digest, nil)
    end
    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end
    def downcase_email
      self.email = email.downcase
    end
   end
  