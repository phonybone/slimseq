class PostPipeline < ActiveRecord::Base
  require 'app_config'
  belongs_to :pipeline_result
  belongs_to :sample
  belongs_to :reference_genome
  belongs_to :flow_cell_lane
  
  def stats_file
    project_name=self.sample.project.name
    sample_id=self.sample.id
    stats_file="#{project_name}.#{sample_id}.stats"
    File.join(working_dir,stats_file)
  end

  def stats()
    return "no stats available (#{stats_file})" unless FileTest.readable?(stats_file)
    stats=File.read(stats_file)
  end

  @@type_names=['Tag Counting','RNA Seq']
  def self.type_names
    @@type_names
  end
  def type_name
    @@type_names[self.runtype]
  end

  @@qsub_writer_names=['write_tc_qsub_file','write_rna_qsub_file']


  def label
    "sample_#{sample_id}_fcl_#{flow_cell_lane_id}"
  end

  def qsub_params
    <<"QSUB_PARAMS"

#PBS -N #{@label}
#PBS -M bea
#PBS -o $qsub_dir/#{@label}/#{@label}.out
#PBS -e $qsub_dir/#{@label}/#{@label}.err
#PBS -l walltime=$options{walltime}

QSUB_PARAMS
  end

  def launch
    Dir.mkdir(working_dir) unless FileTest.directory?(working_dir)

    # write one qsub file for each flow_cell_lane/pipeline_result of the sample:
    writer=self.method(@@qsub_writer_names[self.runtype]) # returns a list of qsub filenames
    qsub_files=self.sample.flow_cell_lanes.collect(&writer)

    # call qsub one each of the qsub files:
    qsub_files.each {|qfile| 
      rc=system "qsub #{qfile}"
      if (!rc) 
        raise "#{sample.name_on_tube}: failed to launch via qsub (#{$?})"
      end
    }
  end

  # get the pp's sample object; shouldn't this method have been created via the belongs_to declaration????
  def sample
    Sample.find(self.sample_id)
  end

  def get_sample_params!(sample)
    ref_gen=sample.reference_genome
    self.sample_id=sample.id
    self.ref_genome_path=ref_gen.fasta_path # fixme: need to change this to our own genomes, or change existing db
    self.org_name=ref_gen.organism.name
    self
  end

  def get_pipeline_result_params!(flow_cell_lane)
    # get the most recent pipeline_result object for this fcl:
    pipeline_result=PipelineResult.find(:all, :conditions=>{:flow_cell_lane_id=>flow_cell_lane.id}, 
                                        :order=>'updated_at ASC',:limit=>1)[0]
    if (pipeline_result.nil?)
      raise "no pipeline_result w/id=#{flow_cell_lane.id}"
    else
      self.flow_cell_lane_id=flow_cell_lane.id
      self.pipeline_result_id=pipeline_result.id
      self.working_dir=File.dirname(pipeline_result.eland_output_file)+'/post_pipeline'
      self.export_file=pipeline_result.eland_output_file
    end
    self
  end

########################################################################

  # write out one qsub file for each flow_cell_lane (which has one pipeline_results object):
  # return the filename written
  def write_tc_qsub_file(flow_cell_lane)
    AppConfig.load
    script_dir=AppConfig.script_dir
    pipeline_script=AppConfig.tc_script
    filename="#{working_dir}/#{label}.qsub"
    genomes=''                  # fixme: implement this

    
    script_contents=<<"QSUB"
#!/bin/sh
#{qsub_params}

export script_dir=#{script_dir}
perl $script_dir/#{pipeline_script} -ssid=#{sample.id} -flowcell_id=#{flow_cell_lane.id} #{genomes}
QSUB

    
    File.open(filename,"w") {|f| f.print script_contents } # fixme: what to do with exceptions?
    return filename
  end

########################################################################

  def write_rna_qsub_file(flow_cell_lane)
    AppConfig.load
    qsub_file="#{working_dir}/#{label}.qsub"

    pp_id=id
    ref_genome=get_rnaseq_ref_genome().name
    
    qsub_template=AppConfig.rna_seq_template
    old_irs=$/
    $/="this is a very unlikely string to appear in the template"
    template='';
    File.open(qsub_template) {|file| template=file.gets } # slurp!
    $/=old_irs

    script=eval template
    File.open(qsub_file, "w") {|file| file.puts script }
    return qsub_file
  end

  def get_rnaseq_ref_genome
    # so we actually use the refereence_genome_id as a key into a different table.
    RnaSeqRefGenome.find(reference_genome_id)
  end

end
