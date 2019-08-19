class AddMemberToMChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :m_channels, :member, :boolean
  end
end
