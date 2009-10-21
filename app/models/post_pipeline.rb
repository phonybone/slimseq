class PostPipeline < ActiveRecord::Base
  require 'app_config'
  belongs_to :samples

  @@type_names=['Tag Counting','RNA Seq']
  def self.type_names
    @@type_names
  end
  def type_name
    @@type_names[self.runtype]
  end

  @@status_names=[['Not Started','Counting','Ref DB Lookup','Aligning','Ref DB Update','Gene Assignment','Finished'],
                  ['Not Started','Counting','Aligning','Running ERANGE','Finished']]
  def self.status_names
    @@status_names
  end
  def status_name
    @@status_names[self.runtype][self.status]
  end

  @@qsub_writer_names=['write_tc_qsub_file','write_rna_qsub_file']

  def launch
    # write one qsub file for each flow_cell_lane of the sample:
    writer=self.method(@@qsub_writer_names[self.runtype])
    qsub_files=self.sample.flow_cell_lanes.collect(&writer)

    # call qsub one each of the qsub files:
    qsub_files.each {|qfile| system "qsub #{qfile}"}
  end

  # get the pp's sample object; shouldn't this method have been created via the belongs_to declaration????
  def sample
    Sample.find(self.sample_id)
  end

  # write out one qsub file for each flow_cell_lane (which has one pipeline_results object):
  # return the filename written
  def write_tc_qsub_file(flow_cell_lane)
    AppConfig.load
    qsub_dir=AppConfig.qsub_dir
    script_dir=AppConfig.script_dir
    pipeline_script=AppConfig.tc_script
    filename="#{qsub_dir}/sample_#{self.sample.id}_fcl_#{flow_cell_lane.id}.qsub"
    genomes=''                  # fixme: implement this

    script_contents=<<"QSUB"
export script_dir=#{script_dir}
perl $script_dir/#{pipeline_script} -ssid=#{self.sample.id} -flowcell_id=#{flow_cell_lane.id} #{genomes}
QSUB

    
    File.open(filename,"w") {|f| f.print script_contents } # fixme: what to do with exceptions?
    return filename
  end

  def write_rna_qsub_file(flow_cell_lane)
    
  end

end
