class StpPipelineAddSamplesAndExperiment < ActiveRecord::Migration
  def self.up
    add_column :stp_pipelines, :experiment_id, :integer
  end

  def self.down
    remove_column :stp_pipelines, :experiment_id
  end
end
