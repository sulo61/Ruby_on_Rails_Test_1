class EventLog

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :user, inverse_of: nil
  field :action, type: String
  belongs_to :activity, inverse_of: nil
  field :client, type: String

  def self.countUsrsByDate(usrDateFrom=DateTime.new(2000,01,01), usrDateTo=DateTime.new(2013-01-01), actDateFrom, actDateTo )
	eventLogUsrs = User.countUsrsByDate(usrDateFrom, usrDateTo)
	
	eventLogUsrs.map do |u|
		idArray = []
		id = u["value"]["Id"]
		if id.kind_of? Array
			id.each do |i|
				idArray.push(i)
			end	
		else
			idArray.push(id)
		end
		idArray = idArray.flatten
		eventSum = 0
		activeUsrs = 0

		idArray.each do |ida|
			tmp = (EventLog.where(:created_at => { '$gte' => actDateFrom, '$lte' => actDateTo } ).where("user_id" => Moped::BSON::ObjectId(ida)).count)
			eventSum += tmp
			activeUsrs += 1 if tmp>0
		end

		{ 
			:date => u["_id"]["data"],
			:count => (u["value"]["Created"]).to_i,
			:id => idArray,
			:eventSum => eventSum,
			:activeUsrs => activeUsrs
		}		
	end
  end

end


