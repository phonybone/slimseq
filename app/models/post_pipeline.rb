class PostPipeline < ActiveRecord::Base
  has_and_belongs_to_many :samples

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

end
