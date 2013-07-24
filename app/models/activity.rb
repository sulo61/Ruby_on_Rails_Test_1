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
  
  embeds_many :enrolled_users

  
  
  def self.showResults(dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
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

  def self.showDay( dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now   )
	
	return where(:created_at => { '$gt' => dataOd, '$lt' => dataDo } ).desc(:created_at)
	
  end 




end
