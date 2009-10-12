require 'database_utils'

class RedoStpTable < ActiveRecord::Migration
  def self.up
    drop_table :stp_pipelines if DatabaseUtil.table_exists?('stp_pipelines')
    create_table :stp_pipelines do |t|
      t.integer :type, :default=>0          # tag-counting=0, rna-seq=1
      t.integer :status, :default=>0        # since no enum support?
      t.integer :max_mismatches, :default=>1

      t.timestamps
    end
  end

  def self.down
    drop_table :stp_pipelines
  end
end
