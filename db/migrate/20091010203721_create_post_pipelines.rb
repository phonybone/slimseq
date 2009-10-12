class CreatePostPipelines < ActiveRecord::Migration
  def self.up
    create_table :post_pipelines do |t|
      t.integer :runtype, :default=>0, :null=>false
      t.integer :max_mismatches, :default=>1
      t.string :name, :null=>false
      t.integer :status, :default=>0, :null=>false

      t.timestamps
    end

    create_table :post_pipelines_samples, :id=>false do |t|
      t.integer :post_pipeline_id, :null=>false
      t.integer :sample_id, :null=>false
    end

    add_index :post_pipelines_samples, [:post_pipeline_id, :sample_id], :unique=>true
  end

  def self.down
    remove_index :post_pipelines_samples, :column=>[:post_pipeline_id, :sample_id]
    drop_table :post_pipelines
  end
end
