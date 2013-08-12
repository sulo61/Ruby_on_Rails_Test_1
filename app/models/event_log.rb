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
		aEvent = 0
		wEvent = 0
		iEvent = 0
		uEvent = 0
		client = "-"

		idArray.each do |ida|
			events = (EventLog.where(:created_at => { '$gte' => actDateFrom, '$lte' => actDateTo } ).where("user_id" => Moped::BSON::ObjectId(ida)))
			
			
			eventsCount = events.size
			eventSum += eventsCount
			if ( eventsCount>0 )
				activeUsrs += 1
				events.each do |fc|
					client = fc.to_a[0][:client].to_s
					case client
						when "web"
							wEvent += 1
			
						when "Android"
							aEvent += 1
			
						when "ios"
							iEvent += 1
			
						when "unknown"
							uEvent += 1
			
					end		
				end
			end
		
		end
		count = (u["value"]["Created"]).to_i
		percentActiveUsrs = (((activeUsrs.to_f / count.to_f) * 100 ).to_s )[0,5]+" %"
		{ 
			:date => u["_id"]["data"],
			:count =>  count,
			:id => idArray,
			:eventSum => eventSum,
			:androidEvent => aEvent,
			:webEvent => wEvent,
			:iosEvent => iEvent,
			:unknownEvent => uEvent,
			:activeUsrs => activeUsrs,
			:percentActiveUsrs => percentActiveUsrs
		}		
	end
  end

end


