class ExperimentAddStpPipeline < ActiveRecord::Migration
  def self.up
    add_column :experiments, :stp_pipeline_id, :integer
  end

  def self.down
    add_column :experiments, :stp_pipeline_id
  end
end
