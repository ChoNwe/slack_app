# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_14_084033) do

  create_table "h_direct_msg_threads", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "dir_msg_id"
    t.integer "user_id"
    t.string "thread_msg"
    t.boolean "unread"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dir_msg_id"], name: "dir_msg_id_idx"
    t.index ["user_id"], name: "user_id_idx"
  end

  create_table "m_channels", primary_key: ["id", "user_id"], options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "id", null: false, auto_increment: true
    t.integer "user_id", null: false
    t.integer "workspace_id"
    t.string "channel_name"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "member"
    t.index ["workspace_id"], name: "workspace_id_idx"
  end

  create_table "m_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "user_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

  create_table "m_workspaces", primary_key: ["id", "user_id"], options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "id", null: false, auto_increment: true
    t.integer "user_id", null: false
    t.string "workspace_name"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "t_cha_msg_strs", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "cha_msg_id"
    t.integer "str_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cha_msg_id"], name: "cha_msg_id"
  end

  create_table "t_channel_msgs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "channel_id"
    t.integer "sender_id"
    t.string "channel_msg"
    t.integer "replier_id"
    t.integer "parent_msg_id"
    t.string "thread_msg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "channel_id_idx"
    t.index ["replier_id"], name: "replier_id_idx"
    t.index ["sender_id"], name: "sender_id_idx"
  end

  create_table "t_channel_unread_msgs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "channel_msg_id"
    t.integer "unread_user_id"
    t.boolean "unread"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_msg_id"], name: "channel_msg_id_idx"
    t.index ["unread_user_id"], name: "unread_user_id_idx"
  end

  create_table "t_dir_msg_strs", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "t_dir_msg_id"
    t.integer "dir_str_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["t_dir_msg_id"], name: "t_dir_msg_id"
  end

  create_table "t_direct_msgs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.string "message"
    t.boolean "unread"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "workspace_id", default: false
    t.index ["receiver_id"], name: "receiver_id_idx"
    t.index ["sender_id"], name: "sender_id_idx"
  end

  create_table "t_mentions", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "mentioned_user_id"
    t.integer "t_cha_msg_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentioned_user_id"], name: "mentioned_user_id"
    t.index ["t_cha_msg_id"], name: "t_cha_msg_id"
  end

  add_foreign_key "h_direct_msg_threads", "m_users", column: "user_id", name: "user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "h_direct_msg_threads", "t_direct_msgs", column: "dir_msg_id", name: "dir_msg_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "m_channels", "m_workspaces", column: "workspace_id", name: "workspace_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_cha_msg_strs", "t_channel_msgs", column: "cha_msg_id", name: "cha_msg_id_fk", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_channel_msgs", "m_channels", column: "channel_id", name: "channel_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_channel_msgs", "m_users", column: "replier_id", name: "replier_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_channel_msgs", "m_users", column: "sender_id", name: "sender_id"
  add_foreign_key "t_channel_unread_msgs", "m_users", column: "unread_user_id", name: "unread_user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_channel_unread_msgs", "t_channel_msgs", column: "channel_msg_id", name: "channel_msg_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_dir_msg_strs", "t_direct_msgs", column: "t_dir_msg_id", name: "t_dir_msg_id_fk", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_direct_msgs", "m_users", column: "receiver_id", name: "receiver_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_mentions", "m_users", column: "mentioned_user_id", name: "mentioned_user_id_fk", on_update: :cascade, on_delete: :cascade
  add_foreign_key "t_mentions", "t_channel_msgs", column: "t_cha_msg_id", name: "t_cha_msg_id_fk", on_update: :cascade, on_delete: :cascade
end
