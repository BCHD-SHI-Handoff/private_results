class InitialSchema < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :name, null: false, unique: true
    end

    create_table :statuses do |t|
      t.string :status, null: false, unique: true
    end

    create_table :scripts do |t|
      t.string :name
      t.belongs_to :test, index: true
      t.string :language, null: false
      t.belongs_to :status, index: true
      t.text :message, null: false
    end

    create_table :clinics do |t|
      t.string :code, null: false, unique: true
      t.string :name, null: false, unique: true
    end

    create_table :visits do |t|
      t.string :patient_number, null: false
      t.belongs_to :clinic, null: false, index: true
      t.string :username, null: false
      t.string :password, null: false
      t.datetime :visited_on, null: false
    end

    create_table :deliveries do |t|
      t.datetime :delivered_at, null: false
      t.string :delivery_method, null: false
      t.string :phone_number_used
      t.text :message, null: false
    end

    create_table :results do |t|
      t.belongs_to :visit, null: false, index: true
      t.belongs_to :test, null: false, index: true
      t.boolean :positive
      t.belongs_to :status
      t.belongs_to :delivery, index: true
    end
  end
end
