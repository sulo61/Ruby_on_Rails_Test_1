class EventLog

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  #belongs_to :user, inverse_of: nil
  field :action, type: String
  #belongs_to :activity, inverse_of: nil
  field :client, type: String
  field :user_id, type: String

  def self.findById(id)
	return find_by(:user_id => id)
  end

  def self.countById(id)
	return where(:user_id => id)
  end

  def self.countUsrsByDate(dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
	eventLogUsrs = User.countUsrsByDate(dataOd, dataDo)
	usrs = []

	eventLogUsrs.each do |u|
		idArray = []
		id = u["value"]["Id"]
		if ( (id.class.name).to_s=="Array" )
			id.each do |i|
				idArray.push(i)
			end	
		else
			idArray.push(id)
		end
		idArray = idArray.flatten
		sum = 0
		usrArray = []
		idArray.each do |ida|
			usrArray.push(EventLog.countById(ida).to_a)
			
		end
		usr = { 
			:date => u["_id"]["data"],
			:count => u["value"]["Created"],
			:id => idArray,
			:sum => usrArray
		}	
		usrs << usr	
	end
	return usrs
  end

end


