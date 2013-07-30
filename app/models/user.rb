class User
  include Mongoid::Document
  
  
  field :email, type: String
  field :name, type: String
  field :_type, type: String
  field :fanpage_ids, type: Array
  field :admin_ids, type: Array

  
  # wyszukiwanie uzytkownika po ID
  def self.findById(id="")
	return where("_id" => id )
  end 

  # wyszukanie wszystkich uzytkownikow
  def self.findAllUsrs()
	return self.desc(:created_at).limit(30)
  end

  # wyszukiwanie uzytkownika bo jego nazwie
  def self.findUsr(name)
	return where("name" => name)
  end

  # generowanie listy uzytkownikow
  def self.generateUsers(find, name, webAddress)
	if (!find || name=="")
		
		# pobranie tablicy uzytkownikow
		usrModelInput = User.findAllUsrs()
		# -----------------------------
	else

	#if params[:find]
		
		# pobranie uzytkownika
		usrModelInput = User.findUsr(name)
		# -----------------------------
	end
		# tworzenie prototypow dla aktywnosci
		usrsArray = Array.new()
		usr = Array.new()

		fanadminArray = Array.new()
		fanadmin = Array.new()
		
		
		fanpagesArray = Array.new()
		fanpages = Array.new()
		# ---------------------------


		usrModelInput.each do |umi|
			name = " - "
			id = " - " 
			email = " - "
			type = " - " 
			date = umi.created_at
			fanpages = Array(nil)
			fanpagesArray = Array(nil)
			id = umi._id
			if ( umi.name!=nil )
				name = umi.name
			end
			if ( umi._type!=nil )

				#dla Usera					
				if ( umi._type=="User" )
					type = "User"
					email = umi.email

					# wyszukiwanie fanpagow
					if (umi.fanpage_ids!=nil)
						fanpagesInput = umi.fanpage_ids
						#fanpages = ""
						fanpages.clear
						fanpagesInput.each do |fi|
							#fanpages = fi
							#fanpages += User.findById(fi).first.name+".\n "
							u = User.findById(fi).first
							fanpages = Array({
								u.name => webAddress+"/users/"+u.id
							})
							fanpagesArray.push(fanpages)
						end
					end
				end

				# dla Fanpage
				if ( umi._type=="Fanpage" )
					type = "Fanpage"
					
					#wyszukiwanie adminow
					if (umi.admin_ids!=nil)
						adminsInput = umi.admin_ids
						#fanpages = ""
						
						adminsInput.each do |ai|
							#fanpages += User.findById(ai).first.name+".\n "
							u = User.findById(ai).first
							fanpages = Array({ 
								u.name => webAddress+"/users/"+u.id
							})
							fanpagesArray.push(fanpages)
						end
					end
				end
			end
			#if ( fanpages==Array(nil) )
			#	fanpages.to_s
			#	fanpages = ""
			#end
			# tworzenie tablicy dla widoku
			usr = Array({
				:name => name,
				:link => webAddress+"/users/"+umi._id+"",
				:email => email,
				:type => type,
				:fanpages => fanpagesArray,
				:id => id,
				:date => date

			})
			
			usrsArray.push(usr)
		end

	  # wysylanie tablicy dla widoku	
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

  def self.generateDetails(dateInput, webAddress)
		# generowanie poprawnej skladniowo daty dla wyciagniecie szczegolow konkretnego dnia 
		dateInput = dateInput
		year = (dateInput[0,4]).to_i
		month = (dateInput[5,2]).to_i
		day = (dateInput[8,2]).to_i
	
		date = DateTime.new(year,month,day)
		# ---------------------------------

		# pobranie tablicy aktywnosci
		usrModelInput = User.showDay(date, date + 23.hours + 59.minutes + 59.seconds )
		# -----------------------------

		# tworzenie prototypow dla aktywnosci
		usrsArray = Array.new()
		usr = Array.new()
		# ---------------------------


		usrModelInput.each do |umi|

		name = " - "
		id = " - " 
		email = " - "
		type = " - " 
		fanpages = Array(nil)
		fanpagesArray = Array(nil)
		id = umi._id
		if ( umi.name!=nil )
			name = umi.name
		end
		if ( umi._type!=nil )

			#dla Usera					
			if ( umi._type=="User" )
				type = "User"
				email = umi.email

				# wyszukiwanie fanpagow
				if (umi.fanpage_ids!=nil)
					fanpagesInput = umi.fanpage_ids
					#fanpages = ""
					fanpages.clear
					fanpagesInput.each do |fi|
						#fanpages = fi
						#fanpages += User.findById(fi).first.name+".\n "
						u = User.findById(fi).first
						fanpages = Array({
							u.name => webAddress+"/users/"+u.id
						})
						fanpagesArray.push(fanpages)
					end
				end
			end

			# dla Fanpage
			if ( umi._type=="Fanpage" )
				type = "Fanpage"
				
				#wyszukiwanie adminow
				if (umi.admin_ids!=nil)
					adminsInput = umi.admin_ids
					#fanpages = ""
					
					adminsInput.each do |ai|
						#fanpages += User.findById(ai).first.name+".\n "
						u = User.findById(ai).first
						fanpages = Array({ 
							u.name => webAddress+"/users/"+u.id
						})
						fanpagesArray.push(fanpages)
					end
				end
			end
		end
				
		# tworzenie tablicy z aktywnosciami dla widoku
		usr = Array({
			:name => umi.name,
			:date => umi.created_at,
			:link => webAddress+"/users/"+umi._id,
			:email => email,
			:type => umi._type,
			:fanpages => fanpagesArray
		})
		usrsArray.push(usr)
		# -----------------------------------
		end
		return usrsArray
  end


  def self.showDay( dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now   )
	
	return where(:created_at => { '$gt' => dataOd, '$lt' => dataDo } ).desc(:created_at)
	
  end 


end
