class CreateMChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :m_channels do |t|
      t.integer :user_id
      t.integer :workspace_id
      t.string :channel_name
      t.boolean :status

      t.timestamps
    end
  end
end
