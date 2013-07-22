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
	
	date = Date.new(params[:date])
	dataKey = DateTime.new(date.getFullYear()+","+(date.getMonth()+1)+","+date.getDate()+'')
	
	@showdate = data.to_s[0,10]
	@details = Activity.showDay(date, date + 23.hours + 59.minutes)
  end
end
