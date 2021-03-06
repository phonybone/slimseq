class FlowCellLane < ActiveRecord::Base
  belongs_to :flow_cell
  
  has_and_belongs_to_many :samples
  
  has_many :pipeline_results
  
  validates_numericality_of :starting_concentration, :loaded_concentration

  after_create :mark_samples_as_clustered
  before_destroy :mark_samples_as_submitted

  acts_as_state_machine :initial => :clustered, :column => 'status'
  
  state :clustered, :after => [:unsequence_samples]
  state :sequenced, :after => [:sequence_samples, :create_charge]
  state :completed, :after => [:complete_samples_and_flow_cell]
  
  event :sequence do
    transitions :from => :clustered, :to => :sequenced    
  end

  event :unsequence do
    transitions :from => :sequenced, :to => :clustered
  end
  
  event :complete do
    transitions :from => :sequenced, :to => :completed    
  end

  def mark_samples_as_clustered
    samples.each do |sample|
      sample = Sample.find(sample.id)
      sample.cluster!
    end
  end
  
  def mark_samples_as_submitted
    samples.each do |sample|
      sample = Sample.find(sample.id)
      sample.unsequence!
      sample.uncluster!
    end
  end
  
  def summary_hash
    return {
      :id => id,
      :flow_cell_uri => "#{SiteConfig.site_url}/flow_cells/#{flow_cell_id}",
      :lane_number => lane_number,
      :updated_at => updated_at,
      :uri => "#{SiteConfig.site_url}/flow_cell_lanes/#{id}"
    }
  end
  
  def detail_hash
    if(flow_cell.sequencing_runs.size == 0)
      sequencer_hash = {}
    else
      sequencing_run = flow_cell.sequencing_runs.best[0]
      sequencer_hash = {
        :name => sequencing_run.instrument.name,
        :serial_number => sequencing_run.instrument.serial_number,
        :instrument_version => sequencing_run.instrument.instrument_version
      }
    end
    
    return {
      :id => id,
      :flow_cell_uri => "#{SiteConfig.site_url}/flow_cells/#{flow_cell_id}",
      :flow_cell_name => flow_cell.prefixed_name,
      :lane_number => lane_number,
      :updated_at => updated_at,
      :starting_concentration => starting_concentration,
      :loaded_concentration => loaded_concentration,
      :raw_data_path => raw_data_path,
      :eland_output_file => eland_output_file,
      :summary_file => summary_file,
      :status => status,
      :comment => comment,
      :sequencer => sequencer_hash,
      :lane_yield_kb => lane_yield_kb,
      :average_clusters => average_clusters,
      :percent_pass_filter_clusters => percent_pass_filter_clusters,
      :percent_align => percent_align,
      :percent_error => percent_error,
      :sample_uris => sample_ids.collect {|x| "#{SiteConfig.site_url}/samples/#{x}" }
    }
  end
  
  def raw_data_path
    if(pipeline_results.size > 0)
      return pipeline_results.find(:first, :order => "gerald_date DESC").base_directory
    end
  end
  
  def raw_data_path=(path)
    if(pipeline_results.size > 0)
      pipeline_results.find(:first, :order => "gerald_date DESC").
        update_attribute('base_directory', path)
    end
  end
  
  def eland_output_file
    if(pipeline_results.size > 0)
      return pipeline_results.find(:first, :order => "gerald_date DESC").eland_output_file
    end
  end

  def summary_file
    if(pipeline_results.size > 0)
      return pipeline_results.find(:first, :order => "gerald_date DESC").summary_file
    end
  end
  
  def default_result_path
    lab_group_profile = LabGroupProfile.find_by_lab_group_id(samples[0].project.lab_group_id)
    "#{SiteConfig.raw_data_root_path}/#{lab_group_profile.file_folder}/" +
    "#{samples[0].project.file_folder}/#{flow_cell.sequencing_runs.best[0].run_name}"
  end
  
private
  
  def sequence_samples
    samples.each do |s|
      s = Sample.find(s.id)
      s.sequence!
    end
  end
  
  def unsequence_samples
    samples.each do |s|
      s = Sample.find(s.id)
      s.unsequence!
    end
  end

  def complete_samples_and_flow_cell
    samples.each do |s|
      s = Sample.find(s.id)
      s.complete!
    end
    
    flow_cell.complete!
  end

  def create_charge
    # charge tracking must be turned on, there must be a default charge,
    # and the sample can't be a control
    if( SiteConfig.track_charges? && ChargeTemplate.default != nil &&
        samples[0].control == false )
      charge_set = ChargeSet.find_or_create_for_latest_charge_period(
        samples[0].project,
        samples[0].budget_number
      )

      description = samples[0].name_on_tube
      (1..samples.size-1).each do |i|
        description << ", #{samples[i].name_on_tube}"
      end

      Charge.create(
        :charge_set => charge_set,
        :date => Date.today,
        :description => description,
        :cost => ChargeTemplate.default.cost)
    end
  end
end
