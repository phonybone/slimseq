class CreateStpSamplesConnector < ActiveRecord::Migration
  def self.up
    create_table :samples_stp_pipelines, :id=>false do |t|
      t.integer :sample_id, :null=>false
      t.integer :stp_pipeline_id, :null=>false
    end

    add_index :samples_stp_pipelines, [:sample_id, :stp_pipeline_id], :unique=>truex
  end

  def self.down
    remove_index :samples_stp_pipelines, :column => [:sample_id, :stp_pipeline_id]
    drop_table :samples_stp_pipeline
  end
end
