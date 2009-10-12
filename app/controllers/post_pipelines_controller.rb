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

  def launch
    @pipeline=PostPipeline.create(params[:post_pipeline]);

    # create associations between pipeline object and samples:
    params[:include_sample].each do |sid|
      @pipeline.samples << Sample.find(sid)
    end

    redirect_to @pipeline
  end

end
