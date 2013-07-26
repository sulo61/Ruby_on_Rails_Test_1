class User
  include Mongoid::Document
  
  
  field :email, type: String
  field :name, type: String
  field :_type, type: String
  field :fanpage_ids, type: Array
  field :admin_ids, type: Array

  
  
  def self.findById(id="")
	return where("_id" => id )
  end 

  def self.findAllUsrs()
	return self
  end

  def self.findUsr(name)
	return where("name" => name)
  end

end
