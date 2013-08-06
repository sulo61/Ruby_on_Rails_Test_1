class User
  include Mongoid::Document  
  
  field :email, type: String
  field :name, type: String
  field :_type, type: String
  field :fanpage_ids, type: Array
  field :admin_ids, type: Array

  def self.webAddress()
	return "https://my.dropsport.com"
  end  
  # wyszukiwanie uzytkownika po ID
  def self.findUsrById(id="")
	return find_by("_id" => id )
  end

  # wyszukiwanie uzytkownika bo jego nazwie
  def self.findUsrByName(name)
	return where("name" => name)
  end

  # generowanie listy uzytkownikow
  def self.usrDetailsByName(name)
	usrsArray = Array(nil)
	User.findUsrByName(name).each do |usbn|
		usrsArray.push(User.genPerson(usbn))
	end
	return usrsArray
  end

  #funkcja na strone glowna usrs, grupujaca usrs po dacie
  def self.showUsrsByDate()
	map = %Q{
		function(){						
			var date = (new Date(this.created_at)).toISOString();
			var dataKey = (date.substring(0,4)+"-"+date.substring(5,7)+"-"+date.substring(8,10));
			var key = {data: dataKey};
			var type = this._type
			switch(type){
				case "User":
					emit (key, { "User": 1, "Fanpage": 0, "all": 1} );
					break;
				case "Fanpage":
					emit (key, { "User": 0, "Fanpage": 1, "all": 1} );
					break;
				default:
					emit (key, { "User": 0, "Fanpage": 0, "all": 1} );				
			}			
		}
	}
	
	reduce = %Q{
	  function(key, values) {	    
	    cUser = 0, cFanpage = 0, cAll = 0;	    
	    values.forEach(function(v) {
		cUser += v.User;
		cFanpage += v.Fanpage;
		cAll += v.all;
	    });
	    return { "User": cUser, "Fanpage": cFanpage, "all": cAll };
	  }
	}
	return self.map_reduce(map, reduce).out(inline: true).sort_by { "_id" }.reverse
  end

  def self.usrsDayDetails(dateInput)
	# generowanie poprawnej skladniowo daty dla wyciagniecie szczegolow konkretnego dnia 
	dateInput = dateInput
	year = (dateInput[0,4]).to_i
	month = (dateInput[5,2]).to_i
	day = (dateInput[8,2]).to_i	
	date = DateTime.new(year,month,day)
	# ---------------------------------
	# pobranie tablicy aktywnosci
	usrModelInput = User.showDay(date, date + 23.hours + 59.minutes + 59.seconds )
	# tworzenie prototypow dla aktywnosci
	usrsArray = Array.new()
	usr = Array.new()
	# ---------------------------

	usrModelInput.each do |umi|
		usr = User.genPerson(umi)
		usrsArray.push(usr)
		# -----------------------------------
	end
	return usrsArray
  end

  def self.showDay( dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now   )	
	return where(:created_at => { '$gt' => dataOd, '$lt' => dataDo } ).desc(:created_at)	
  end 

  def self.genPerson(usr)
	# pobranie uzytkownika
	umi = usr
	# -----------------------------
	# tworzenie prototypow dla aktywnosci	
	usr = Array.new()		
	fanadmins = Array(nil)
	fanadminArray = Array(nil)
	# client last active
	cla = Array(nil)
	fanadminsInput = Array(nil)	
	# ---------------------------		
	id = " - " 
	email = " - "
	type = " - " 
	date = umi.created_at	
	id = umi._id
	if ( umi.name!=nil )
		name = umi.name
	else
		name = " - "
	end

	if ( umi._type!=nil )		
		#dla Usera					
		if ( umi._type=="User" )
			type = "User"
			email = umi.email
			cla = umi.client_last_active.to_a
			# wyszukiwanie fanpagow
			if (umi.fanpage_ids!=nil)
				fanadminsInput = umi.fanpage_ids			
			end
		end
		# dla Fanpage
		if ( umi._type=="Fanpage" )
			type = "Fanpage"			
			#wyszukiwanie adminow
			if (umi.admin_ids!=nil)
				fanadminsInput = umi.admin_ids
			end
		end
		fanadminsInput.each do |fai|					
			u = User.findUsrById(fai)
			fanadmins = Array({
				u.name => webAddress()+"/users/"+u.id
			})
			fanadminArray.push(fanadmins)
		end
	end
	
	usr = Array({
		:name => name,
		:link => webAddress()+"/users/"+umi._id+"",
		:email => email,
		:type => type,
		:fanadmins => fanadminArray,
		:id => id,
		:date => date,
		:cla => cla,
		:date => umi.created_at,

	})	
	# wysylanie tablicy dla widoku	
	return usr
  end

end
