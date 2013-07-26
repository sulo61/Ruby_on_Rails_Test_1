class Admin
  include Mongoid::Document
  
  field :login, type: String
  field :pass, type: String
  
  def self.findByLogin(login)
	return where("login"=> login )
  end
end