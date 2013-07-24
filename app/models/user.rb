class User
  include Mongoid::Document
  
  
  field :mail, type: String
  
  
  
  
  def self.findById(id="")
	return where("_id" => id )
  end 

end
