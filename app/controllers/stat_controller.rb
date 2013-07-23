class StatController < ApplicationController

  $daysBack = 30
 
  def panel
	
	
	now = DateTime.now
	if !params[:last]
		@activities = Activity.showResults(now-$daysBack, now)
	end
	if params[:all]		
		@activities = Activity.showResults()
	end
	if params[:last]			
		@activities = Activity.showResults(now-params[:numberOfDays].to_i, now)
	end
	
  end

  def results
	
  end

  def details
	if params[:back]
		redirect_to :action => "panel"
	end
	
	dateInput = params[:date].to_s
	year = (dateInput[0,4]).to_i
	month = (dateInput[5,2]).to_i
	day = (dateInput[8,2]).to_i
	
	date = DateTime.new(year,month,day)
	@showdate = dateInput
	@details = Activity.showDay(date, date + 23.hours + 59.minutes + 59.seconds )
	
  end
end
