class AddFileToPages < ActiveRecord::Migration
  def change
    add_column :pages, :file, :string
  end
end
