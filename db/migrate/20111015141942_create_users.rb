class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email,            null: false
      t.string :password_digest,  default: nil
      t.string :first_name,       default: nil
      t.string :last_name,        default: nil
      t.boolean :block,           default: false
      t.boolean :admin,           default: false

      t.timestamps
    end
  end
end
