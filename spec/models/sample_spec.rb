require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sample do

  describe "getting naming element visibility" do
    fixtures :samples, :naming_schemes, :naming_elements, :naming_terms, :sample_terms,
             :sample_texts
    
    it "should return nil with no naming scheme" do
      samples(:sample5).naming_element_visibility.should == nil
    end
    
    it "should return the correct visibility settings with a naming scheme" do
      expected_visibilities = [true, true, true, true, true]
      samples(:sample6).naming_element_visibility.should == expected_visibilities
    end
  end

  describe "getting naming scheme text values" do
    fixtures :samples, :naming_schemes, :naming_elements, :naming_terms, :sample_terms,
             :sample_texts
    
    it "should return nil with no naming scheme" do
      samples(:sample5).text_values.should == nil
    end
    
    it "should return the correct text values with a naming scheme" do
      expected_texts = {"Subject Number" => "32234"}
      samples(:sample6).text_values.should == expected_texts
    end
  end

  describe "getting naming scheme element selections" do
    fixtures :samples, :naming_schemes, :naming_elements, :naming_terms, :sample_terms,
             :sample_texts
    
    it "should return nil with no naming scheme" do
      samples(:sample5).text_values.should == nil
    end
    
    it "should return the correct selections with a naming scheme" do
      expected_selections = [naming_terms(:wild_type).id, naming_terms(:heat).id,
                             naming_terms(:time024).id, naming_terms(:replicateB).id, -1 ]
      samples(:sample6).naming_element_selections.should == expected_selections
    end
  end
  
  describe "making sample terms from schemed parameters" do
    fixtures :naming_schemes, :naming_elements, :naming_terms
    
    it "should provide an array of the sample terms" do
      @sample = Sample.new(:naming_scheme_id => naming_schemes(:yeast_scheme))
      
      schemed_params = {
        "Strain" => naming_terms(:wild_type).id, "Perturbation" => naming_terms(:heat).id,
        "Replicate" => naming_terms(:replicateA).id, "Perturbation Time" => naming_terms(:time024).id,
        "Subject Number" => "3283"
      }
      
      expected_terms = [
        @sample.sample_terms.build(:term_order => 1, :naming_term_id => naming_terms(:wild_type).id),
        @sample.sample_terms.build(:term_order => 2, :naming_term_id => naming_terms(:heat).id),
        @sample.sample_terms.build(:term_order => 3, :naming_term_id => naming_terms(:time024).id),
        @sample.sample_terms.build(:term_order => 4, :naming_term_id => naming_terms(:replicateA).id)
      ]

      @sample.terms_for(schemed_params).each do |observed_term|
        expected_term = expected_terms.shift
        observed_term.attributes.should == expected_term.attributes
      end
    end
  end

  describe "making sample terms from schemed parameters, with a hidden dependent element" do
    fixtures :naming_schemes, :naming_elements, :naming_terms
    
    it "should provide an array of the sample terms" do
      @sample = Sample.new(:naming_scheme_id => naming_schemes(:yeast_scheme))
      
      schemed_params = {
        "Strain" => naming_terms(:wild_type).id, "Perturbation" => "-1",
        "Perturbation Time" => naming_terms(:time024).id,
        "Replicate" => naming_terms(:replicateA).id, "Subject Number" => "3283"
      }
      
      expected_terms = [
        @sample.sample_terms.build(:term_order => 1, :naming_term_id => naming_terms(:wild_type).id),
        @sample.sample_terms.build(:term_order => 2, :naming_term_id => naming_terms(:replicateA).id)
      ]

      @sample.terms_for(schemed_params).each do |observed_term|
        expected_term = expected_terms.shift
        observed_term.attributes.should == expected_term.attributes
      end
    end
  end
  
  describe "making sample texts from schemed parameters" do
    fixtures :naming_schemes, :naming_elements, :naming_terms
    
    it "should provide a hash of the sample texts" do
      @sample = Sample.new(:naming_scheme_id => naming_schemes(:yeast_scheme))
      
      schemed_params = {
        "Strain" => naming_terms(:wild_type).id, "Perturbation" => naming_terms(:heat).id,
        "Replicate" => naming_terms(:replicateA), "Perturbation Time" => naming_terms(:time024),
        "Subject Number" => "3283"
      }
      
      expected_texts = [
        SampleText.new(:sample_id => @sample.id,
                       :naming_element_id => naming_elements(:subject_number).id,
                       :text => "3283"),
      ]

      @sample.texts_for(schemed_params).each do |observed_text|
        expected_text = expected_texts.shift
        observed_text.attributes.should == expected_text.attributes
      end
    end
  end
  
  describe "setting the schemed name attribute for a sample" do
    fixtures :all
    
    def do_set
      @sample = samples(:sample6)
      schemed_params = {
        "Strain" => naming_terms(:wild_type).id, "Perturbation" => naming_terms(:heat).id,
        "Replicate" => naming_terms(:replicateA).id, "Perturbation Time" => naming_terms(:time024).id,
        "Subject Number" => "3283"
      }
      @sample.schemed_name = schemed_params
    end
    
    it "should create the appropriate sample terms" do
      do_set

      expected_attribute_sets = [
        { :term_order => 1, :naming_term_id => naming_terms(:wild_type).id },
        { :term_order => 2, :naming_term_id => naming_terms(:heat).id },
        { :term_order => 3, :naming_term_id => naming_terms(:time024).id },
        { :term_order => 4, :naming_term_id => naming_terms(:replicateA).id }
      ]

      @sample.sample_terms.find(:all, :order => "term_order ASC").each do |term|
        attribute_set = expected_attribute_sets.shift
        attribute_set.each do |key, value|
          term[key].should == value
        end
      end
    end
    
    it "should create the appropriate sample texts" do       
      do_set

      attribute_set = { :naming_element_id => naming_elements(:subject_number).id, :text => "3283" }

      text = @sample.sample_texts.find(:all)[0]
      attribute_set.each do |key, value|
        text[key].should == value
      end
    end
  end
  
  describe "exporting sample info to a CSV" do
    fixtures :all

    it "should export all non-naming scheme samples when given no naming scheme" do
      csv_file_name = Sample.to_csv
    
      csv = CSV.open(csv_file_name, 'r')

      # heading
      csv.shift.should eql([
        "Sample ID",
        "Submission Date",
        "Name On Tube",
        "Sample Description",
        "Project",
        "Sample Prep Kit",
        "Reference Genome",
        "Desired Read Length",
        "Alignment Start Position",
        "Alignment End Position",
        "Insert Size",
        "Budget Number",
        "Comment",
        "Naming Scheme"
      ])
      
      # samples
      csv.shift.should eql([
        samples(:sample1).id.to_s,
        "2006-02-10",
        "yng",
        "Young",
        "MouseGroup",
        "ChIP-Seq",
        "weevil v1",
        "36",
        "1",
        "22",
        "150",
        "1234",
        "",
        "None"
      ])

      csv.shift.should eql([
        samples(:sample2).id.to_s,
        "2006-02-10",
        "old",
        "Old",
        "MouseGroup",
        "ChIP-Seq",
        "weevil v1",
        "36",
        "1",
        "22",
        "150",
        "1234",
        "",
        "None"
      ])

      csv.shift.should eql([
        samples(:sample3).id.to_s,
        "2006-02-10",
        "vold",
        "Very Old",
        "MouseGroup",
        "ChIP-Seq",
        "weevil v1",
        "36",
        "1",
        "22",
        "150",
        "1234",
        "",
        "None"
      ])

      csv.shift.should eql([
        samples(:sample4).id.to_s,
        "2006-02-10",
        "vvold",
        "Very Very Old",
        "MouseGroup",
        "ChIP-Seq",
        "weevil v1",
        "36",
        "1",
        "22",
        "150",
        "1234",
        "",
        "None"
      ])

      csv.shift.should eql([
        samples(:sample5).id.to_s,
        "2006-09-10",
        "bb",
        "BobB",
        "Bob's Stuff",
        "ChIP-Seq",
        "weevil v1",
        "36",
        "1",
        "22",
        "150",
        "1234",
        "",
        "None"
      ])      
    end
    
    it "should export all non-naming scheme samples when given no naming scheme" do
      csv_file_name = Sample.to_csv("Yeast Scheme")
    
      csv = CSV.open(csv_file_name, 'r')
      
      # heading
      csv.shift.should eql([
        "Sample ID",
        "Submission Date",
        "Name On Tube",
        "Sample Description",
        "Project",
        "Sample Prep Kit",
        "Reference Genome",
        "Desired Read Length",
        "Alignment Start Position",
        "Alignment End Position",
        "Insert Size",
        "Budget Number",
        "Comment",
        "Naming Scheme",
        "Strain",
        "Perturbation",
        "Perturbation Time",
        "Replicate",
        "Subject Number"
      ])
      
      # samples
      csv.shift.should eql([
        samples(:sample6).id.to_s,
        "2007-05-31",
        "a1",
        "wt_HT_024_B_32234",
        "Bob's Stuff",
        "ChIP-Seq",
        "weevil v1",
        "36",
        "1",
        "22",
        "150",
        "1234",
        "",
        "Yeast Scheme",
        "wild-type",
        "heat",
        "024",
        "B",
        "32234"
      ])    
    end
  end

  describe "importing sample info from a CSV" do
    fixtures :all

    it "should update unschemed samples from a CSV" do
      csv_file = "#{RAILS_ROOT}/spec/fixtures/csv/updated_unschemed_samples.csv"

      errors = Sample.from_csv(csv_file)

      errors.should == ""

      # one change was made to sample 1
      sample_1 = Sample.find( samples(:sample1).id )
      sample_1.name_on_tube.should == "yng1"

      # multiple changes to sample 2
      sample_2 = Sample.find( samples(:sample2).id )
      sample_2.submission_date.to_s.should == "2006-02-11"
      sample_2.name_on_tube.should == "old1"
      sample_2.sample_description.should == "Old1"
      sample_2.project_id.should == projects(:another).id
      sample_2.sample_prep_kit_id.should == sample_prep_kits(:tag_count).id
      sample_2.reference_genome_id.should == reference_genomes(:weevil_2).id
      sample_2.desired_read_length.should == 26
      sample_2.alignment_start_position.should == 2
      sample_2.alignment_end_position.should == 36
      sample_2.insert_size.should == 200
      sample_2.budget_number.should == "5678"
      sample_2.comment.should == "lots of updates"
    end

    it "should update schemed samples from a CSV" do
      csv_file = "#{RAILS_ROOT}/spec/fixtures/csv/updated_yeast_scheme_samples.csv"

      errors = Sample.from_csv(csv_file)

      errors.should == ""

      # changes to schemed sample
      SampleTerm.find(:first, :conditions => {
        :sample_id => samples(:sample6).id,
        :naming_term_id => naming_terms(:mutant).id } ).should_not == nil
      SampleTerm.find(:first, :conditions => {
        :sample_id => samples(:sample6).id,
        :naming_term_id => naming_terms(:replicateA).id } ).should_not == nil
      sample_6_number = SampleText.find(:first, :conditions => {
        :sample_id => samples(:sample6).id,
        :naming_element_id => naming_elements(:subject_number).id } )
      sample_6_number.text.should == "32236"
      Sample.find( samples(:sample6) ).naming_scheme.id.should == naming_schemes(:yeast_scheme).id
    end
    
    it "should update unschemed samples to being schemed from a CSV" do
      csv_file = "#{RAILS_ROOT}/spec/fixtures/csv/no_scheme_to_scheme.csv"

      errors = Sample.from_csv(csv_file)

      errors.should == ""

      # changes to schemed sample
      SampleTerm.find(:first, :conditions => {
        :sample_id => samples(:sample3).id,
        :naming_term_id => naming_terms(:wild_type).id } ).should_not == nil
      SampleTerm.find(:first, :conditions => {
        :sample_id => samples(:sample3).id,
        :naming_term_id => naming_terms(:heat).id } ).should_not == nil
      SampleTerm.find(:first, :conditions => {
        :sample_id => samples(:sample3).id,
        :naming_term_id => naming_terms(:replicateB).id } ).should_not == nil
      sample_6_number = SampleText.find(:first, :conditions => {
        :sample_id => samples(:sample3).id,
        :naming_element_id => naming_elements(:subject_number).id } )
      sample_6_number.text.should == "234"
      Sample.find( samples(:sample3).id ).naming_scheme_id.to_i.should ==
        naming_schemes(:yeast_scheme).id
    end
    
    it "should create schemed samples from a CSV" do
      csv_file = "#{RAILS_ROOT}/spec/fixtures/csv/new_yeast_scheme_sample.csv"

      errors = Sample.from_csv(csv_file)

      errors.should == ""

      # changes to schemed sample
      sample = Sample.find(:first, :conditions => "name_on_tube = 's12'")
      sample.should_not be_nil
      SampleTerm.find(:first, :conditions => {
        :sample_id => sample.id,
        :naming_term_id => naming_terms(:wild_type).id } ).should_not == nil
      SampleTerm.find(:first, :conditions => {
        :sample_id => sample.id,
        :naming_term_id => naming_terms(:replicateA).id } ).should_not == nil
      sample_number = SampleText.find(:first, :conditions => {
        :sample_id => sample.id,
        :naming_element_id => naming_elements(:subject_number).id } )
      sample_number.text.should == "32236"
      Sample.find( sample ).naming_scheme.id.should == naming_schemes(:yeast_scheme).id
    end    
  end
  
  describe "turning the alignment start and stop into a USE_BASES string for Gerald" do

    describe "with last base skipping turned off" do

      it "should return 'all' if the alignment start and stop span the full desired read" do
        @sample = Sample.new(:desired_read_length => 36, :alignment_start_position => 1,
                    :alignment_end_position => 36)
        @sample.use_bases_string(false).should == "Y36"
      end
      
      it "should return 'Y25n11' for the first 25 of 36 bases of the desired read length" do
        @sample = Sample.new(:desired_read_length => 36, :alignment_start_position => 1,
                    :alignment_end_position => 25)
        @sample.use_bases_string(false).should == "Y25n11"
      end
      
      it "should return 'n2Y34' for the last 34 of 36 bases of the desired read length" do
        @sample = Sample.new(:desired_read_length => 36, :alignment_start_position => 3,
                    :alignment_end_position => 36)
        @sample.use_bases_string(false).should == "n2Y34"
      end

      it "should return 'n4Y15n17' for the 5th through 19th bases of a 36 base read" do
        @sample = Sample.new(:desired_read_length => 36, :alignment_start_position => 5,
                    :alignment_end_position => 19)
        @sample.use_bases_string(false).should == "n4Y15n17"
      end

    end

    describe "with last base skipping turned on" do

      it "should return 'all' if the alignment start and stop span the full desired read" do
        @sample = Sample.new(:desired_read_length => 36, :alignment_start_position => 1,
                    :alignment_end_position => 36)
        @sample.use_bases_string(true).should == "Y35n1"
      end
      
      it "should return 'Y25n11' for the first 25 of 36 bases of the desired read length" do
        @sample = Sample.new(:desired_read_length => 36, :alignment_start_position => 1,
                    :alignment_end_position => 25)
        @sample.use_bases_string(true).should == "Y25n11"
      end
      
      it "should return 'n2Y34' for the last 34 of 36 bases of the desired read length" do
        @sample = Sample.new(:desired_read_length => 36, :alignment_start_position => 3,
                    :alignment_end_position => 36)
        @sample.use_bases_string(true).should == "n2Y33n1"
      end

      it "should return 'n4Y15n17' for the 5th through 19th bases of a 36 base read" do
        @sample = Sample.new(:desired_read_length => 36, :alignment_start_position => 5,
                    :alignment_end_position => 19)
        @sample.use_bases_string(true).should == "n4Y15n17"
      end

    end

  end

  it "should provide a hash of summary attributes" do
    sample = create_sample(:sample_description => "mutant_yeast")   
    
    sample.summary_hash.should == {
      :id => sample.id,
      :sample_description => "mutant_yeast",
      :submission_date => Date.today,
      :updated_at => sample.updated_at,
      :uri => "http://example.com/samples/#{sample.id}"
    }
  end

  it "should provide a hash of detailed attributes" do


    naming_scheme = create_naming_scheme(
      :name => "Beast Scheme"
    )
    naming_element_1 = create_naming_element(
      :naming_scheme => naming_scheme,
      :name => "Age"
    )
    naming_element_2 = create_naming_element(
      :naming_scheme => naming_scheme,
      :name => "Subject Number",
      :free_text => true
    )
    naming_term_1 = create_naming_term(
      :term => "Young",
      :naming_element => naming_element_1
    )
    project = create_project(:name => "Mutant Yeast")
    sample_prep_kit = create_sample_prep_kit(
      :name => "yeast kit",
      :restriction_enzyme => "DpnII"
    )
    
    sample = create_sample(
      :name_on_tube => "mut",
      :sample_description => "mutant_yeast",
      :project => project,
      :submission_date => Date.today,
      :sample_prep_kit => sample_prep_kit,
      :insert_size => 250,
      :desired_read_length => 36,
      :alignment_start_position => 2,
      :alignment_end_position => 30,
      :reference_genome => create_reference_genome(
        :name => "Yeast 5.0",
        :organism => create_organism(:name => "Yeast")
      ),
      :naming_scheme => naming_scheme,
      :budget_number => "1234",
      :sample_terms => [
        create_sample_term(:naming_term => naming_term_1)
      ],
      :sample_texts => [
        create_sample_text(:naming_element => naming_element_2, :text => "345")
      ],
      :comment => "failed"
    )   
    sample.stub!(:user).and_return( mock("User", :firstname => "Joe", :lastname => "User", :full_name => "Joe User") )

    sample.detail_hash.should == {
      :id => sample.id,
      :submission_date => Date.today,
      :updated_at => sample.updated_at,
      :comment => "failed",
      :status => "submitted",
      :submitted_by => "Joe User",
      :name_on_tube => "mut",
      :sample_description => "mutant_yeast",
      :project => "Mutant Yeast",
      :submission_date => Date.today,
      :sample_prep_kit => "yeast kit",
      :sample_prep_kit_restriction_enzyme => "DpnII",
      :sample_prep_kit_uri => "http://example.com/sample_prep_kits/#{sample_prep_kit.id}",
      :insert_size => 250,
      :desired_number_of_cycles => 36,
      :alignment_start_position => 2,
      :alignment_end_position => 30,
      :reference_genome => {
        :name => "Yeast 5.0",
        :organism => "Yeast"
      },
      :naming_scheme => "Beast Scheme",
      :budget_number => "1234",
      :comment => "failed",
      :sample_terms => ["Age" => "Young"],
      :sample_texts => ["Subject Number" => "345"],
      :flow_cell_lane_uris => [],
      :project_uri => "http://example.com/projects/#{project.id}"
    }
  end
  
  it "should provide the raw data path(s)" do
    sample = create_sample
    flow_cell = create_flow_cell
    lane_1 = create_flow_cell_lane(:samples => [sample], :flow_cell => flow_cell)
    lane_2 = create_flow_cell_lane(:samples => [sample], :flow_cell => flow_cell)
    sequencing_run = create_sequencing_run(:flow_cell => flow_cell)
    create_pipeline_result(:flow_cell_lane => lane_1, :sequencing_run => sequencing_run)
    create_pipeline_result(:flow_cell_lane => lane_2, :sequencing_run => sequencing_run)
    
    sample.raw_data_paths.should == "#{lane_1.raw_data_path}, #{lane_2.raw_data_path}"
  end
  
  it "should set the lane paths for associated flow cell lanes" do
    sample = create_sample
    flow_cell = create_flow_cell
    lane_1 = create_flow_cell_lane(:samples => [sample], :flow_cell => flow_cell)
    lane_2 = create_flow_cell_lane(:samples => [sample], :flow_cell => flow_cell)
    create_sequencing_run(:flow_cell => flow_cell)
    create_pipeline_result(:flow_cell_lane => lane_1)
    create_pipeline_result(:flow_cell_lane => lane_2)
    
    sample.lane_paths = {
      lane_1.id.to_s => {'raw_data_path' => '/new/lane_1/path'},
      lane_2.id.to_s => {'raw_data_path' => '/new/lane_2/path'}
    }
   
    sample.raw_data_paths.should == "/new/lane_1/path, /new/lane_2/path"
  end

  describe "providing comments from associated flow cell lanes, flow cells and sequencing runs" do

    it "should provide a concatenated string when there are some comments" do
      sample = create_sample(:comment => "weird IP")
      flow_cell = create_flow_cell(:comment => "Flow was all wrong")
      lane_1 = create_flow_cell_lane(:samples => [sample], :flow_cell => flow_cell,
                                     :comment => "Concentration unsually high")
      lane_2 = create_flow_cell_lane(:samples => [sample], :flow_cell => flow_cell)
      sequencing_run = create_sequencing_run(:flow_cell => flow_cell, :comment => "Prism messed up")
      
      sample.associated_comments.should == "sample: weird IP, lane: Concentration unsually high, " +
        "flow cell: Flow was all wrong, sequencing: Prism messed up"
    end

    it "should provide 'No comments' when there aren't any" do
      sample = create_sample
      flow_cell = create_flow_cell
      lane_1 = create_flow_cell_lane(:samples => [sample], :flow_cell => flow_cell)
      lane_2 = create_flow_cell_lane(:samples => [sample], :flow_cell => flow_cell)
      sequencing_run = create_sequencing_run(:flow_cell => flow_cell)
      
      sample.associated_comments.should == "No comments"
    end

  end

  it "should provide the associated user" do
    sample = create_sample(:submitted_by_id => 1)
    User.should_receive(:find).with(1).and_return( mock_user = mock_model(User) )
    sample.user.should == mock_user
  end

  it "should provide the samples accessible to a user" do
    lab_group_1 = mock_model(LabGroup)
    lab_group_2 = mock_model(LabGroup)
    user = mock_model(User, :get_lab_group_ids => [lab_group_1.id])
    sample_1 = create_sample( :project => create_project(:lab_group => lab_group_1) )
    sample_2 = create_sample( :project => create_project(:lab_group => lab_group_2) )
    
    Sample.accessible_to_user(user).should == [sample_1]
  end

  it "should generate a browsing tree Hash" do
    scheme = create_naming_scheme(:name => "Mouse")
    strain = create_naming_element(:naming_scheme => scheme, :name => "Strain")
    bl6 = create_naming_term(:naming_element => strain, :term => "Bl6")
    mutant = create_naming_term(:naming_element => strain, :term => "Mutant")
    age = create_naming_element(:naming_scheme => scheme, :name => "Age")
    one_week = create_naming_term(:naming_element => age, :term => "One Week")
    two_weeks = create_naming_term(:naming_element => age, :term => "Two Weeks")
    project_1 = create_project(:name => "ChIP-Seq")
    project_2 = create_project(:name => "RNA-Seq")
    sample_1 = create_sample(:project => project_1)
    sample_2 = create_sample(:project => project_1)
    sample_3 = create_sample(:project => project_1)
    sample_4 = create_sample(:project => project_2)
    create_sample_term(:sample => sample_1, :naming_term => bl6)
    create_sample_term(:sample => sample_2, :naming_term => bl6)
    create_sample_term(:sample => sample_3, :naming_term => mutant)
    create_sample_term(:sample => sample_4, :naming_term => bl6)
    create_sample_term(:sample => sample_1, :naming_term => one_week)
    create_sample_term(:sample => sample_2, :naming_term => one_week)
    create_sample_term(:sample => sample_3, :naming_term => two_weeks)
    create_sample_term(:sample => sample_4, :naming_term => two_weeks)

    Sample.browse_by(
      [sample_1, sample_2, sample_3, sample_4],
      ["project", "naming_element-#{strain.id}", "naming_element-#{age.id}"]
    ).should == [
      {
        :name => "ChIP-Seq",
        :number => 3,
        :search_string => "project_id=#{project_1.id}",
        :children => [
          {
            :name => "Bl6",
            :number => 2,
            :search_string => "project_id=#{project_1.id}&naming_term_id=#{bl6.id}",
            :children => [
              {
                :name => "One Week",
                :number => 2,
                :search_string => "project_id=#{project_1.id}&naming_term_id=#{bl6.id},#{one_week.id}",
                :children => nil
              }
            ]
          },
          {
            :name => "Mutant",
            :number => 1,
            :search_string => "project_id=#{project_1.id}&naming_term_id=#{mutant.id}",
            :children => [
              {
                :name => "Two Weeks",
                :number => 1,
                :search_string => "project_id=#{project_1.id}&naming_term_id=#{mutant.id},#{two_weeks.id}",
                :children => nil
              }
            ]
          }
        ]
      },
      {
        :name => "RNA-Seq",
        :number => 1,
        :search_string => "project_id=#{project_2.id}",
        :children => [
          {
            :name => "Bl6",
            :number => 1,
            :search_string => "project_id=#{project_2.id}&naming_term_id=#{bl6.id}",
            :children => [
              {
                :name => "Two Weeks",
                :number => 1,
                :search_string => "project_id=#{project_2.id}&naming_term_id=#{bl6.id},#{two_weeks.id}",
                :children => nil
              }
            ]
          }
        ]
      }
    ]
  end

  it "should find by a set of conditions after sanitizing them" do
    scheme = create_naming_scheme(:name => "Mouse")
    strain = create_naming_element(:naming_scheme => scheme, :name => "Strain")
    bl6 = create_naming_term(:naming_element => strain, :term => "Bl6")
    mutant = create_naming_term(:naming_element => strain, :term => "Mutant")
    age = create_naming_element(:naming_scheme => scheme, :name => "Age")
    one_week = create_naming_term(:naming_element => age, :term => "One Week")
    two_weeks = create_naming_term(:naming_element => age, :term => "Two Weeks")
    lab_group_1 = mock_model(LabGroup, :name => "Smith Lab")
    project_1 = create_project(:name => "ChIP-Seq", :lab_group => lab_group_1)
    project_2 = create_project(:name => "RNA-Seq")
    flow_cell = create_flow_cell
    genome = create_reference_genome
    prep_kit = create_sample_prep_kit
    sample_1 = create_sample(:project => project_1, :submission_date => '2009-05-01',
                             :insert_size => 100, :naming_scheme_id => scheme.id,
                             :reference_genome => genome, :sample_prep_kit => prep_kit)
    sample_2 = create_sample(:project => project_1, :submission_date => '2009-05-02',
                             :insert_size => 150)
    sample_3 = create_sample(:project => project_1, :submission_date => '2009-05-01',
                             :insert_size => 100, :naming_scheme_id => scheme.id,
                             :reference_genome => genome)
    sample_4 = create_sample(:project => project_2)
    flow_cell_lane = create_flow_cell_lane(:samples => [sample_1, sample_3], :flow_cell => flow_cell)
    create_sample_term(:sample => sample_1, :naming_term => bl6)
    create_sample_term(:sample => sample_2, :naming_term => mutant)
    create_sample_term(:sample => sample_3, :naming_term => bl6)
    create_sample_term(:sample => sample_4, :naming_term => bl6)
    create_sample_term(:sample => sample_1, :naming_term => one_week)
    create_sample_term(:sample => sample_2, :naming_term => one_week)
    create_sample_term(:sample => sample_3, :naming_term => two_weeks)
    create_sample_term(:sample => sample_4, :naming_term => two_weeks)

    Sample.find_by_sanitized_conditions(
      "controller" => "this",
      "action" => "that",
      "project_id" => project_1.id,
      "submission_date" => '2009-05-01',
      "insert_size" => 100,
      "reference_genome_id" => genome.id,
      "organism_id" => genome.organism_id,
      "status" => "clustered",
      "naming_scheme_id" => scheme.id,
      "naming_term_id" => "#{one_week.id},#{bl6.id}",
      "flow_cell_id" => flow_cell.id,
      "lab_group_id" => lab_group_1.id,
      "bob_id" => 123
    ).should == [sample_1]
  end

  it "should provide sample browsing categories" do
    # make sure there are no other schemes to get in the way
    NamingScheme.destroy_all

    scheme = create_naming_scheme(:name => "Mouse")
    strain = create_naming_element(:naming_scheme => scheme, :name => "Strain")

    Sample.browsing_categories.should == [
      ['Flow Cell', 'flow_cell'],
      ['Insert Size', 'insert_size'],
      ['Lab Group', 'lab_group'],
      ['Naming Scheme', 'naming_scheme'],
      ['Organism', 'organism'],
      ['Project', 'project'],
      ['Reference Genome', 'reference_genome'],
      ['Sample Prep Kit', 'sample_prep_kit'],
      ['Status', 'status'],
      ['Submission Date', 'submission_date'],
      ['Submitter', 'submitter'],
      ['Mouse: Strain', "naming_element-#{strain.id}"]
    ]
  end

  describe "providing eland seed length" do
    
    before(:each) do
      GeraldDefaults.destroy_all
      create_gerald_defaults(:eland_seed_length => 25, :eland_max_matches => 5)
      @eland_parameter_set = create_eland_parameter_set(:name => "mouse", :eland_seed_length => 20, :eland_max_matches => 10)
    end
    
    it "should provide the seed length from the sample's eland parameter set if one is specified" do
      sample = create_sample(:eland_parameter_set_id => @eland_parameter_set.id)
      sample.eland_seed_length.should == 20
    end

    it "should provide the application-wide gerald default seed length if no sample eland parameter set exists" do
      sample = create_sample
      sample.eland_seed_length.should == 25
    end

  end

  describe "providing eland max matches" do
    
    before(:each) do
      GeraldDefaults.destroy_all
      create_gerald_defaults(:eland_seed_length => 25, :eland_max_matches => 5)
      @eland_parameter_set = create_eland_parameter_set(:name => "mouse", :eland_seed_length => 20, :eland_max_matches => 10)
    end
    
    it "should provide the max matches from the sample's eland parameter set if one is specified" do
      sample = create_sample(:eland_parameter_set_id => @eland_parameter_set.id)
      sample.eland_max_matches.should == 10
    end

    it "should provide the application-wide gerald default max matches if no sample eland parameter set exists" do
      sample = create_sample
      sample.eland_max_matches.should == 5
    end

  end

end
