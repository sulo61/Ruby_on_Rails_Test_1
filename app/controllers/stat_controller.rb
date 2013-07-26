class StatController < ApplicationController

  $daysBack = 30
  $access = false
	#user = Admin.findByLogin(login).first
  def login
	if session[:user_if]
		redirect_to :action => "panel"
	end

	if params["login"]
		if user = Admin.findByLogin(params[:login]).first
			#password = params[:pass]
			password = Digest::SHA2.hexdigest(params[:pass])
			if password == user.pass
				session[:user_id] = user.id
				redirect_to :action => "panel"
			end
		end
	end

  end
 
  def logout
	if session[:user_id]
		session[:user_id] = nil
		redirect_to :action => "login"
	else
	redirect_to :action => "login"
	end
  end

  def panel
	
	redirect_to :action => "login" if !session[:user_id]
		now = DateTime.now
		if !params[:last]
			@activities = Activity.showResults(now-$daysBack, now)
		end
	
		if params[:last]			
			@activities = Activity.showResults(now-params[:numberOfDays].to_i, now)
		end
	

  end



  def details
	
	redirect_to :action => "login" if !session[:user_id]

		if params[:back]
			redirect_to :action => "panel"
		end
	
		# generowanie poprawnej skladniowo daty dla wyciagniecie szczegolow konkretnego dnia 
		dateInput = params[:date].to_s
		year = (dateInput[0,4]).to_i
		month = (dateInput[5,2]).to_i
		day = (dateInput[8,2]).to_i
	
		date = DateTime.new(year,month,day)
		# ---------------------------------

		# pobranie tablicy aktywnosci
		activityModelInput = Activity.showDay(date, date + 23.hours + 59.minutes + 59.seconds )
		# -----------------------------

		# tworzenie prototypow dla aktywnosci
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
			@showdate = (ami.created_at.to_s)[0,10]
			# -------------------------------		
		
			# wyciaganie danych Usera
			id = ami.author_id.to_s
			userModelInput = User.findById(id)
			email = " - "
			type = " - "
			fanPageName = " - "
		
			userModelInput.each do |uam|
				if ( uam._id.to_s == id )
					if ( uam._type.to_s == "User" )				
						type = "U"				
						email = uam.email
					else
						type = "F"
					
					end
				end
			end
			# --------------------------------
		
			# tworzenie tablicy z aktywnosciami dla widoku
			activity = Array({
				:time => (ami.created_at.to_s)[11,8],
				:link => "https://my.dropsport.com/activities/"+ami._id+"",
				:discipline => ami.discipline,
				:author_info => ami.author_info["name"],
				:client => ami.client,
				:enrolled => ami.enrolled_users.size,
				:repeat => repeat,
				:email => email,
				:type => type,
				:fanPageName => fanPageName
			})
			activitiesArray.push(activity)
			# -----------------------------------
		end
	
		# udostepnianie widokowi tablicy aktywnosci	
		@activityDetails = activitiesArray
		# ------------------------------------------
	
	
  end



  def usrs
	
	redirect_to :action => "login" if !session[:user_id]

		if (!params[:find] || params[:name]=="")
			
			# pobranie tablicy uzytkownikow
			usrModelInput = User.findAllUsrs()
			# -----------------------------
		else

		#if params[:find]
			
			# pobranie uzytkownika
			usrModelInput = User.findUsr(params[:name])
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
								fanpages += User.findById(fi).first.name+" . "
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
								fanpages += User.findById(ai).first.name+" . "
							end
						end
					end
				end

				# tworzenie tablicy dla widoku
				usr = Array({
					:name => name,
					:link => "https://my.dropsport.com/users/"+umi._id+"",
					:email => email,
					:type => type,
					:fanpages => fanpages

				})
				
				usrsArray.push(usr)
			end

	  # wysylanie tablicy dla widoku	
	  @usrs = usrsArray
	  end

	
end
