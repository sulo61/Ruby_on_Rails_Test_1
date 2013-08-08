class StatController < ApplicationController
  before_filter :auth, :except => [ :login, :logout ]

  DAYS_BACK = 14
  DT_NOW = DateTime.now

  def auth
	redirect_to :action => "login" if !session[:user_id]
  end

	
  def login
	if session[:user_if]
		redirect_to :action => "mainActivity"
	end

	if params["login"]
		if user = Admin.findByLogin(params[:login]).first
			password = Digest::SHA2.hexdigest(params[:pass])
			if password == user.pass
				session[:user_id] = user.id
				redirect_to :action => "activityMain"
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

  def activityMain
	

	if !params[:last]
		@activities = Activity.countActivities(DT_NOW-DAYS_BACK, DT_NOW)
	end

	if params[:last]			
		@activities = Activity.countActivities(DT_NOW-params[:numberOfDays].to_i, DT_NOW)
	end
  end



  def activityDetails
	if params[:back]
		redirect_to :action => "activityMain"
	end
	date = params[:date].to_s
	@showdate = date[0,10]
	# udostepnianie widokowi tablicy aktywnosci	
	@activityDetails = Activity.activitiesDetails(date)
	# ------------------------------------------
  end



  def usrsMain
	# udostepnianie widokowi tablicy uzytkownikow
	
	if !params[:find]
		@showByDate = true
		@usrs = User.showUsrsByDate()
	end
	if params[:find]
		@showByDate = false
		@usrs = User.usrDetailsByName(params[:name])
		
	end
	
  end

  def usrsDetails
	if params[:back]
		redirect_to :action => "usrsMain"
	end
	date = params[:date].to_s
	@showdate = date[0,10]
	# udostepnianie widokowi tablicy aktywnosci	
	@usrsDetails = User.usrsDayDetails(date)
	# ------------------------------------------
  end

  def eventlogMain()
	
	
	def checkLastDays(df=DateTime.new(2013-07-30), dt=DT_NOW)
		
		if !params[:last]		
			@@usrsByDate = EventLog.countUsrsByDate(DT_NOW-DAYS_BACK, DT_NOW, df, dt)
			@last = DAYS_BACK
		end
		if params[:last]		
			@@usrsByDate = EventLog.countUsrsByDate(DT_NOW-params[:numberOfDays].to_i, DT_NOW, df, dt)
			@last = params[:numberOfDays].to_i
		end
	end
	
	dateFrom = params[:dateFrom].to_s
	dateTo = params[:dateTo].to_s
	

	if ( dateFrom!="" && dateTo!="" )
		@datesRange = dateFrom+" < - > "+dateTo+""
		dateTo = ((DateTime.new((dateTo[6,10]).to_i,(dateTo[3,2]).to_i,(dateTo[0,2]).to_i)) + 23.hours + 59.minutes + 59.seconds )
		checkLastDays(dateFrom,dateTo)
	else
		@datesRange = "Ever"
		checkLastDays()
	end
	@usrsByDate = @@usrsByDate

  end

end
