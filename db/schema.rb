# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_06_063241) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "public_status", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name"
    t.index ["public_status"], name: "index_categories_on_public_status"
  end

  create_table "category_companies", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "company_id"], name: "index_category_companies_on_category_id_and_company_id", unique: true
    t.index ["category_id"], name: "index_category_companies_on_category_id"
    t.index ["company_id"], name: "index_category_companies_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "email"
    t.string "phone"
    t.string "website"
    t.string "address"
    t.integer "public_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_companies_on_email"
    t.index ["name"], name: "index_companies_on_name"
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id", "category_id"], name: "index_product_categories_on_product_id_and_category_id", unique: true
    t.index ["product_id"], name: "index_product_categories_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "price"
    t.string "producer"
    t.string "delivery_date"
    t.text "description"
    t.integer "public_status", default: 1, null: false
    t.integer "product_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name"
    t.index ["public_status"], name: "index_products_on_public_status"
  end

  add_foreign_key "category_companies", "categories"
  add_foreign_key "category_companies", "companies"
  add_foreign_key "product_categories", "categories"
  add_foreign_key "product_categories", "products"
end
