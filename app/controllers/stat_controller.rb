class StatController < ApplicationController

  $daysBack = 30
  $webAddress = "https://my.dropsport.com"

	
  def login
	if session[:user_if]
		redirect_to :action => "panel"
	end

	if params["login"]
		if user = Admin.findByLogin(params[:login]).first
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
	date = params[:date].to_s
	@showdate = date[0,10]
	# udostepnianie widokowi tablicy aktywnosci	
	@activityDetails = Activity.generateDetails(date, $webAddress)
	# ------------------------------------------
  end



  def usrs
	redirect_to :action => "login" if !session[:user_id]
	# udostepnianie widokowi tablicy uzytkownikow
	#@usrs = User.generateUsers(params[:find], params[:name], $webAddress)
	if !params[:find]
		@showByDate = true
		@usrs = User.showUsrsByDate()
	end
	if params[:find]
		@showByDate = false
		@usrs = User.generateUsers(params[:find], params[:name], $webAddress)
	end
  end

end
