class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :title
      t.integer :user_id
      t.integer :certificate_id
      t.integer :key_id
      t.text :body
      t.integer :request_status
      t.string :common_name
      t.string :organization
      t.string :organization_unit
      t.string :country
      t.integer :days
      t.string :locality
      t.string :email
      t.string :state
      t.string :sha
      t.integer :serial
      t.boolean :ca

      t.timestamps
    end
  end
end
