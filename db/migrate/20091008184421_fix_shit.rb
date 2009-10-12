class FixShit < ActiveRecord::Migration
  def self.up
    remove_column :stp_pipelines, :stp_pipeline_id
    remove_column :stp_pipelines, :experiment_id
  end

  def self.down
    add_column :stp_pipelines, :stp_pipeline_id, :integer
    add_column :stp_pipelines, :experiment_id, :integer
  end
end
