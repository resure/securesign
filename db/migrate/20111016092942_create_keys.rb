class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string :title
      t.string :password_digest
      t.text :body
      t.text :public_body
      t.integer :user_id
      t.string :sha

      t.timestamps
    end
  end
end
