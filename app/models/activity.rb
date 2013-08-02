class EnrolledUser
  include Mongoid::Document

  field :oid, type: String
  embedded_in :activity
end

class Activity
  include Mongoid::Document
  include Mongoid::Timestamps 

  field :author_id, type: String
  field :client, type: String
  field :description, type: String
  field :discipline, type: String
  field :created_at, type: DateTime
  field :repeat, type: String
  field :moc, type: String
  field :state, type: String
  
  embeds_many :enrolled_users
  
  # activities, zliczanie klientow, grupowanie po dniach
  def self.countActivities(dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
	map = %Q{
		function(){
						
			var date = (new Date(this.created_at)).toISOString();
			var dataKey = (date.substring(0,4)+"-"+date.substring(5,7)+"-"+date.substring(8,10));
			var key = {data: dataKey};
			var client = this.client
			switch(client){
				case "web":
					emit (key, { "web": 1, "Android": 0, "ios": 0, "unknown": 0, "all": 1} );
					break;
				case "Android":
					emit (key, { "web": 0, "Android": 1, "ios": 0, "unknown": 0, "all": 1} );
					break;
				case "ios":
					emit (key, { "web": 0, "Android": 0, "ios": 1, "unknown": 0, "all": 1} );
					break;
				case "unknown":
					emit (key, { "web": 0, "Android": 0, "ios": 0, "unknown": 1, "all": 1} );
					break;				
			}			
		}
	}
	
	reduce = %Q{
	  function(key, values) {	    
	    cWeb = 0, cAndroid = 0, cIos = 0, cUnknown = 0, cAll = 0;	    
	    values.forEach(function(v) {
		cWeb += v.web;
		cAndroid += v.Android;
		cIos += v.ios;
		cUnknown += v.unknown;
		cAll += v.all;
	    });
	    return { "web": cWeb, "Android": cAndroid, "ios": cIos, "unknown": cUnknown, "all": cAll };
	  }
	}
	return self.where(:created_at => { '$gte' => dataOd, '$lte' => dataDo } ).map_reduce(map, reduce).out(inline: true).sort_by { "_id" }.reverse
  end

  # szczegoly activities dla konkretnego dnia
  def self.activitiesDetails(dateInput, webAddress)
	# generowanie poprawnej skladniowo daty dla wyciagniecie szczegolow konkretnego dnia 
	dateInput = dateInput
	year = (dateInput[0,4]).to_i
	month = (dateInput[5,2]).to_i
	day = (dateInput[8,2]).to_i

	date = DateTime.new(year,month,day)
	# ---------------------------------

	# pobranie tablicy aktywnosci
	activityModelInput = Activity.activityDayDetails(date, date + 23.hours + 59.minutes + 59.seconds )
	# -----------------------------

	# tworzenie prototypow tablic dla aktywnosci
	activitiesArray = Array.new()
	activity = Array.new()
	# ---------------------------

	activityModelInput.each do |ami|
	
		# sprawdzanie danych aktywnosci
		if (ami.repeat==nil)
			repeat = "false"
		else
			repeat = "true"
		end
		
		# wyciaganie danych Usera
		id = ami.author_id.to_s
		uam = User.findUsrById(id)
		email = " - "
		type = " - "
		fanPageName = " - "		
	
		if ( uam._id.to_s == id )
			if ( uam._type.to_s == "User" )				
				type = "U"				
				email = uam.email
			else
				type = "F"			
			end
		end	
		# tworzenie tablicy z aktywnosciami dla widoku
		activity = Array({
			:time => (ami.created_at.to_s)[11,8],
			:link => webAddress+"/activities/"+ami._id+"",
			:discipline => ami.discipline,
			:author_info => ami.author_info["name"],
			:client => ami.client,
			:enrolled => ami.enrolled_users.size-1,
			:repeat => repeat,
			:email => email,
			:type => type,
			:fanPageName => fanPageName,
			:state => ami.state
		})
		activitiesArray.push(activity)
		# -----------------------------------
	end
	return activitiesArray
  end


  def self.activityDayDetails( dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now   )	
	return where(:created_at => { '$gt' => dataOd, '$lt' => dataDo } ).desc(:created_at)	
  end 

end
