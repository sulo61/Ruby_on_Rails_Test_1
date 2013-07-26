class Admin
  include Mongoid::Document
  store_in database: ENV['DATABASE_URL_STAT']
  
  field :login, type: String
  field :pass, type: String
  
  def self.findByLogin(login)
	return where("login"=> login )
  end
end
