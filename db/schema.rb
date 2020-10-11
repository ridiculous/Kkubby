# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_11_030320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "catalogs", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.string "image_url"
    t.integer "product_count"
    t.datetime "last_updated_at"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer "catalog_id"
    t.string "brand"
    t.string "name"
    t.string "category"
    t.string "product_type"
    t.string "raw_price"
    t.decimal "price"
    t.date "published_at"
    t.datetime "last_refreshed_at"
    t.string "image_size"
    t.string "image_url", limit: 500
    t.string "sourced_from", limit: 500
    t.string "product_url", limit: 500
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.tsvector "search_tokens"
    t.index ["brand", "name"], name: "index_products_on_brand_and_name", unique: true
    t.index ["catalog_id"], name: "index_products_on_catalog_id"
    t.index ["search_tokens"], name: "index_products_on_search_tokens"
  end

  create_table "shelf_products", force: :cascade do |t|
    t.integer "shelf_id"
    t.integer "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "notes"
    t.boolean "wishlist"
    t.integer "order_index", default: 0
    t.index ["shelf_id", "product_id"], name: "index_shelf_products_on_shelf_id_and_product_id", unique: true
  end

  create_table "shelves", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.integer "order_index", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_shelves_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.string "auth_token"
    t.string "time_zone"
    t.datetime "last_active_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "shelf_products", "products"
  add_foreign_key "shelf_products", "shelves"
  add_foreign_key "shelves", "users"
end
