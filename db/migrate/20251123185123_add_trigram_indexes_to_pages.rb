class AddTrigramIndexesToPages < ActiveRecord::Migration[8.0]
  def change
    enable_extension :pg_trgm

    add_index :pages, :title, using: :gin, opclass: :gin_trgm_ops
    add_index :pages, :content, using: :gin, opclass: :gin_trgm_ops
  end
end
