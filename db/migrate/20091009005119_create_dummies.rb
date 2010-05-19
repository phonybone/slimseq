class CreateDummies < ActiveRecord::Migration
  def self.up
    create_table :dummies do |t|
      t.integer :dummy_id
      t.string :name

      t.timestamps
    end

    add_column :samples, :dummy_id, :integer

  end

  def self.down
    drop_table :dummies

    remove_column :samples, :dummy_id
  end
end
