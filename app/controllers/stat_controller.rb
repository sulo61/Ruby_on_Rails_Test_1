class StatController < ApplicationController
  before_filter :auth, :except => [ :login, :logout ]

  $daysBack = 30
  

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
	now = DateTime.now

	if !params[:last]
		@activities = Activity.countActivities(now-$daysBack, now)
	end

	if params[:last]			
		@activities = Activity.countActivities(now-params[:numberOfDays].to_i, now)
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





  def eventlogMain
	now = DateTime.now
	if !params[:last]		
		usrsByDate = EventLog.countUsrsByDate(now-$daysBack, now)
	end
	if params[:last]		
		usrsByDate = EventLog.countUsrsByDate(now-params[:numberOfDays].to_i, now)
		
	end
	@usrsByDate = usrsByDate

	
	if ( params[:dateFrom].to_s!="" && params[:dateTo].to_s!="" )
		@datesRange = params[:dateFrom].to_s+" < --- > "+params[:dateTo].to_s+""
	else
		@datesRange = ""
	end



  end

end
