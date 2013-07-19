class Activity
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  

  field :client, type: String
  field :description, type: String
  field :discipline, type: String
  field :created_at, type: Date

  
  def self.showTable(dataOd=DateTime.new(2000,01,01), dataDo=Date.today )
	map = %Q{
		function(){
			var date = new Date(this.created_at);
			var dataKey = new Date(date.getFullYear()+","+(date.getMonth()+1)+","+date.getDate()+'');
			var key = {data: dataKey};
			if (this.client=="web"){ emit (key, { web: 1, android: 0, ios: 0, unknown: 0, all: 0} ); }
			if (this.client=="Android"){ emit (key, { web: 0, android: 1, ios: 0, unknown: 0, all: 0} ); }
			if (this.client=="ios"){ emit (key, { web: 0, android: 0, ios: 1, unknown: 0, all: 0} ); }
			if (this.client=="unknown"){ emit (key, { web: 0, android: 0, ios: 0, unknown: 1, all: 0} ); }
			emit (key,  { web: 0, android: 0, ios: 0, unknown: 0, all: 1} );
		}
	}
	
	reduce = %Q{
	  function(key, values) {
	    var sum = { web: 0, android: 0, ios: 0, unknown: 0, all: 0};
	    values.forEach(function(v) {
		sum.web += v.web;
		sum.android += v.android;
		sum.ios += v.ios;
		sum.unknown += v.unknown;
		sum.all += v.all;
	    });
	    return { count: sum };
	  }
	}
	
	return where(:created_at => { '$gte' => dataOd, '$lte' => dataDo } ).map_reduce(map, reduce).out(inline: true)
  end






end
