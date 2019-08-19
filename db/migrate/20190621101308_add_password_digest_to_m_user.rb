class AddPasswordDigestToMUser < ActiveRecord::Migration[5.2]
  def change
    add_column :m_users, :password_digest, :string
  end
end
