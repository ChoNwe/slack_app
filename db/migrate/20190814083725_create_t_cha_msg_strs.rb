class CreateTChaMsgStrs < ActiveRecord::Migration[5.2]
  def change
    create_table :t_cha_msg_strs do |t|
      t.integer :cha_msg_id
      t.integer :str_user_id

      t.timestamps
    end
  end
end
