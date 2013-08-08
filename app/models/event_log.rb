class EventLog

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :user, inverse_of: nil
  field :action, type: String
  belongs_to :activity, inverse_of: nil
  field :client, type: String

  def self.countUsrsByDate(dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
	eventLogUsrs = User.countUsrsByDate(dataOd, dataDo)
	usrs = []

	eventLogUsrs.each do |u|
		idArray = []
		id = u["value"]["Id"]
		if ( id.kind_of?(Array) )
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
			usrArray.push(EventLog.where("client" => "web").first.to_a)
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


