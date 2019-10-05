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

ActiveRecord::Schema.define(version: 2019_10_05_054130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "image_url"
    t.string "raw_price"
    t.decimal "price"
    t.date "published_at"
    t.datetime "last_refreshed_at"
    t.string "sourced_from"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["brand", "name"], name: "index_products_on_brand_and_name", unique: true
    t.index ["catalog_id"], name: "index_products_on_catalog_id"
  end

end
