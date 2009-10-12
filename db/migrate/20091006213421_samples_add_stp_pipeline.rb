class SamplesAddStpPipeline < ActiveRecord::Migration
  def self.up
    add_column :samples, :stp_pipeline_id, :integer
  end

  def self.down
    remove_column :samples, :stp_pipeline_id
  end
end
