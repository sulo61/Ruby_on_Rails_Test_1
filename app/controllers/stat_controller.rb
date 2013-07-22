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
	
	data = DateTime.parse(params[:date]) 
	@showdate = data.to_s[0,10]
	@details = Activity.showDay(data, data+ 23.hours + 59.minutes + 59.seconds )
  end
end
