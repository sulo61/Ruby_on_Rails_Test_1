class Activity
  include Mongoid::Document
  include Mongoid::Timestamps

  

  field :client, type: String
  field :description, type: String
  field :discipline, type: String
  field :created_at, type: DateTime

  
  def self.showResults(dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
	map = %Q{
		function(){
						
			var date = new Date(this.created_at);
			var dataKey = new Date(date.getFullYear()+","+(date.getMonth()+1)+","+date.getDate()+'');
			var key = {data: dataKey};
			if (this.client=="web")		{ emit (key, { web: 1, android: 0, ios: 0, unknown: 0, all: 0} ); }
			if (this.client=="Android")	{ emit (key, { web: 0, android: 1, ios: 0, unknown: 0, all: 0} ); }
			if (this.client=="ios")		{ emit (key, { web: 0, android: 0, ios: 1, unknown: 0, all: 0} ); }
			if (this.client=="unknown")	{ emit (key, { web: 0, android: 0, ios: 0, unknown: 1, all: 0} ); }
								  emit (key, { web: 0, android: 0, ios: 0, unknown: 0, all: 1} );
		}
	}
	
	reduce = %Q{
	  function(key, values) {
	    
	    cWeb = 0, cAndroid = 0, cIos = 0, cUnknown = 0, cAll = 0;
	    
	    values.forEach(function(v) {
		cWeb += v.web;
		cAndroid += v.android;
		cIos += v.ios;
		cUnknown += v.unknown;
		cAll += v.all;
	    });

	    return { web: cWeb, android: cAndroid, ios: cIos, unknown: cUnknown, all: cAll };
	  }
	}

	return self.where(:created_at => { '$gte' => dataOd, '$lte' => dataDo } ).map_reduce(map, reduce).out(inline: 1)

  end

  def self.showDay( dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now   )
	
	return where(:created_at => { '$gte' => dataOd, '$lte' => dataDo } )
  end 




end
