class AddFileShaToPages < ActiveRecord::Migration
  def change
    add_column :pages, :file_sha, :string
  end
end
