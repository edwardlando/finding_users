class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :contact
      t.integer :influence
      t.text :description
      t.string :image

      t.timestamps
    end
  end
end
