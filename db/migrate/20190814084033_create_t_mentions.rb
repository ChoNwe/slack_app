class CreateTMentions < ActiveRecord::Migration[5.2]
  def change
    create_table :t_mentions do |t|
      t.integer :mentioned_user_id
      t.integer :t_cha_msg_id

      t.timestamps
    end
  end
end
