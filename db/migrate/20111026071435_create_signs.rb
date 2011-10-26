class CreateSigns < ActiveRecord::Migration
  def change
    create_table :signs do |t|
      t.integer :key_id
      t.integer :certificate_id
      t.text :body
      t.string :sha

      t.references :signable, polymorphic: true

      t.timestamps
    end
  end
end
