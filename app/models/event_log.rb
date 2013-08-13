class EventLog

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :user, inverse_of: nil
  field :action, type: String
  belongs_to :activity, inverse_of: nil
  field :client, type: String

  def self.countUsrsByDate(usrDateFrom=DateTime.new(2013,07,21), usrDateTo=DateTime.now, actDateFrom=DateTime.new(2013,07,25), actDateTo=DateTime.now, xdays=0 )
	eventLogUsrs = User.countUsrsByDate(usrDateFrom, usrDateTo)

    eventLogUsrs.map do |u|
      #udf = u["_id"]["data"] + (xdays.to_i).days
      if ( xdays.to_i > 0 )
        udf = DateTime.new(
            ((u["_id"]["data"]).to_s[0,4]).to_i,
            ((u["_id"]["data"]).to_s[5,2]).to_i,
            ((u["_id"]["data"]).to_s[8,2]).to_i
        )
        udt = DateTime.new(
            ((u["_id"]["data"]).to_s[0,4]).to_i,
            ((u["_id"]["data"]).to_s[5,2]).to_i,
            ((u["_id"]["data"]).to_s[8,2]).to_i
        ) + (xdays.to_i).days + 23.hours + 59.minutes + 59.seconds
      end
      #DateTime.new( (u["_id"]["data"]).to_s  )
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
        if ( xdays.to_i == 0 )
          events = (EventLog.where(:created_at => { '$gte' => actDateFrom, '$lte' => actDateTo } ).where("user_id" => Moped::BSON::ObjectId(ida)))
        end
        if ( xdays.to_i > 0)
          events = (EventLog.where(:created_at => { '$gte' => udf, '$lte' => udt } ).where("user_id" => Moped::BSON::ObjectId(ida)))
        end
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


