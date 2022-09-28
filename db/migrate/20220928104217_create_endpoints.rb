class CreateEndpoints < ActiveRecord::Migration[7.0]
  def change
    create_table :endpoints do |t|
      t.string :path
      t.string :verb
      t.integer :code
      t.json :headers
      t.text :body

      t.timestamps
    end
  end
end
