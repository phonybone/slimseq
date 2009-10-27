class PostPipeline < ActiveRecord::Base
  require 'app_config'
  belongs_to :pipeline_result

  @@type_names=['Tag Counting','RNA Seq']
  def self.type_names
    @@type_names
  end
  def type_name
    @@type_names[self.runtype]
  end

  @@qsub_writer_names=['write_tc_qsub_file','write_rna_qsub_file']
  @@qsub_params=<<"QSUB_PARAMS"

#PBS -N #{label}
#PBS -M bea
#PBS -o $qsub_dir/#{label}/#{label}.out
#PBS -e $qsub_dir/#{label}/#{label}.err
#PBS -l walltime=$options{walltime}

QSUB_PARAMS

  def launch
    # write one qsub file for each flow_cell_lane/pipeline_result of the sample:
    writer=self.method(@@qsub_writer_names[self.runtype]) # returns a list of qsub filenames
    qsub_files=self.sample.flow_cell_lanes.collect(&writer)

    # call qsub one each of the qsub files:
    qsub_files.each {|qfile| system "qsub #{qfile}"}
  end

  # get the pp's sample object; shouldn't this method have been created via the belongs_to declaration????
  def sample
    Sample.find(self.sample_id)
  end

  def get_sample_params(sample)
    ref_gen=sample.reference_genome
    @sample_id=sample.id
    @ref_genome_path=ref_gen.fasta_path
    @org_name=ref_gen.organism.name
    self
  end

  def get_pipeline_result_params(flow_cell_lane)
    pipeline_result=PipelineResult.find(:all, :conditions=>{:flow_cell_lane_id=>flow_cell_lane.id}, 
                                        :order=>'updated_at ASC',:limit=>1)[0]
    if (!pipeline_result.nil?)
      @pipeline_result_id=pipeline_result.id
      @base_dir=pipeline_result.working_dir
      @eland_output_file=pipeline_result.eland_output_file
    end
    self
  end

  # write out one qsub file for each flow_cell_lane (which has one pipeline_results object):
  # return the filename written
  def write_tc_qsub_file(flow_cell_lane)
    get_pipeline_result_params(flow_cell_lane)
    qsub_dir=working_dir

    AppConfig.load
    script_dir=AppConfig.script_dir
    pipeline_script=AppConfig.tc_script
    label="sample_#{@sample_id}_fcl_#{flow_cell_lane.id}"
    filename="#{qsub_dir}/#{label}.qsub"
    genomes=''                  # fixme: implement this

    
    script_contents=<<"QSUB"
#!/bin/sh
@@qsub_params

export script_dir=#{script_dir}
perl $script_dir/#{pipeline_script} -ssid=#{@sample_id} -flowcell_id=#{flow_cell_lane.id} #{genomes}
QSUB

    
    File.open(filename,"w") {|f| f.print script_contents } # fixme: what to do with exceptions?
    return filename
  end

########################################################################

  def write_rna_qsub_file(flow_cell_lane)
    AppConfig.load
    script=AppConfig.rna_script
    label="sample_#{@sample_id}_fcl_#{flow_cell_lane.id}"
    filename="#{qsub_dir}/#{label}.qsub"

    script_contents=<<"QSUB"
#!/bin/sh
@@qsub_params

sh #{script} #{@working_dir} #{@export_file} #{@sample_id} #{ref_genome}
QSUB
  end



end
