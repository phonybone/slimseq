class ChangeSamplePpRshipAgain < ActiveRecord::Migration
  def self.up
    drop_table :post_pipelines_samples;
    add_column :post_pipelines, :sample_id, :integer
  end

  def self.down
    create_table :post_pipelines_samples, :id=>false do |t|
      t.integer :post_pipeline_id, :null=>false
      t.integer :sample_id, :null=>false
    end
    remove_column :post_pipelines, :sample_id
  end
end
