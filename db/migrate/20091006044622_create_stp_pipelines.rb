class CreateStpPipelines < ActiveRecord::Migration
  def self.up
    create_table :stp_pipelines do |t|
      t.integer :type           # tag-counting=1, rna-seq=2
      t.integer :sample_id
      t.integer :status         # since no enum support?
      t.integer :max_mismatches

      t.timestamps
    end
  end

  def self.down
    drop_table :stp_pipelines
  end
end
