class PostPipelinesController < ApplicationController
  # GET /post_pipelines
  # GET /post_pipelines.xml
  def index
    @post_pipelines = PostPipeline.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @post_pipelines }
    end
  end

  # GET /post_pipelines/1
  # GET /post_pipelines/1.xml
  def show
    @post_pipeline = PostPipeline.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post_pipeline }
    end
  end

  # GET /post_pipelines/new
  # GET /post_pipelines/new.xml
  def new
    @post_pipeline = PostPipeline.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post_pipeline }
    end
  end

  # GET /post_pipelines/1/edit
  def edit
    @post_pipeline = PostPipeline.find(params[:id])
  end

  # POST /post_pipelines
  # POST /post_pipelines.xml
  def create
    logger.info "debug: I'm a baby dwagon!";
    @post_pipeline = PostPipeline.new(params[:post_pipeline])

    respond_to do |format|
      if @post_pipeline.save
        flash[:notice] = 'PostPipeline was successfully created.'
        format.html { redirect_to(@post_pipeline) }
        format.xml  { render :xml => @post_pipeline, :status => :created, :location => @post_pipeline }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post_pipeline.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /post_pipelines/1
  # PUT /post_pipelines/1.xml
  def update
    @post_pipeline = PostPipeline.find(params[:id])
    logger.info "params are #{params.inspect}"

    respond_to do |format|
      if @post_pipeline.update_attributes(params[:post_pipeline])
        flash[:notice] = 'PostPipeline was successfully updated.'
        format.html { redirect_to(@post_pipeline) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post_pipeline.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /post_pipelines/1
  # DELETE /post_pipelines/1.xml
  def destroy
    @post_pipeline = PostPipeline.find(params[:id])
    @post_pipeline.destroy

    respond_to do |format|
      format.html { redirect_to(post_pipelines_url) }
      format.xml  { head :ok }
    end
  end


  def make_pipelines(sample)
    sample=Sample.find params[:sample_id] if sample.nil?
    fcls=sample.flow_cell_lanes;
    n_pipelines=0
    if (fcls.count == 0)
      @msgs << "No flow cell lane for '#{sample.name_on_tube}'"
      return 0
    end
    fcls.each do |fcl|
      pp=PostPipeline.new(params[:post_pipeline])
      pp.get_sample_params!(sample) # could possibly incorporate these into constructor...
      begin
        pp.get_pipeline_result_params!(fcl)
        pp.name=pp.label
      rescue RuntimeError => barf
        if /no pipeline_result/.match barf
          @msgs << "No (eland) pipeline for #{sample.name_on_tube}"
        else 
          raise
        end
        next
      end
      pp.save
      begin
        pp.launch
        n_pipelines+=1            # why doesn't n_pipelines++ work???
      rescue RuntimeError => barf
        @msgs << barf
        pp.delete
      end
    end
    n_pipelines
  end

  # called by views/samples/pipeline.html.erb
  # also called from launch_exp
  def launch_sample
    sample=Sample.find(params[:sample_id])
    raise "no sample w/id=#{params[:sample_id]}" if sample.nil?
    @msgs=[]
    n_pipelines=make_pipelines(sample)
    @msgs << "#{n_pipelines} pipelines launched"
    flash[:notice]=@msgs.join('<br />')
    redirect_to :controller=>:samples, :action=>:pipeline, :id=>sample.id
  end

  def launch_exp                # called by views/experiments/pipeline.html.erb
    # create a pipeline object for each flow_cell_lane object of sample
    sample_ids=params[:include_sample]
    exp=Experiment.find(params[:experiment_id])
    n_pipelines=0
    @msgs=[]
    sample_ids.each do |sid| 
      sample=Sample.find(sid)
      n_pipelines+=make_pipelines(sample)
    end
    @msgs << "#{n_pipelines} pipelines launched"
    flash[:notice]=@msgs.join('<br />')

    
    redirect_to :controller=>:experiments, :action=>:pipeline, :id=>exp.id
  end
  
end
