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
	return self
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
		# ---------------------------


		usrModelInput.each do |umi|
			name = " - "
			id = " - " 
			email = " - "
			type = " - " 
			fanpages = " - "
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
						fanpages = ""
						fanpagesInput.each do |fi|
							#fanpages = fi
							fanpages += User.findById(fi).first.name+".\n "
						end
					end
				end

				# dla Fanpage
				if ( umi._type=="Fanpage" )
					type = "Fanpage"
					
					#wyszukiwanie adminow
					if (umi.admin_ids!=nil)
						adminsInput = umi.admin_ids
						fanpages = ""
						adminsInput.each do |ai|
							fanpages += User.findById(ai).first.name+".\n "
						end
					end
				end
			end

			# tworzenie tablicy dla widoku
			usr = Array({
				:name => name,
				:link => webAddress+"/users/"+umi._id+"",
				:email => email,
				:type => type,
				:fanpages => fanpages

			})
			
			usrsArray.push(usr)
		end

	  # wysylanie tablicy dla widoku	
	  return usrsArray
  end

end
