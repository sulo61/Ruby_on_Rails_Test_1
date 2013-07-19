class StatController < ApplicationController

  $daysBack = 30
 
  def panel
	@activities = Activity.showTable(Date.today-$daysBack)
	if params[:all]		
		@activities = Activity.showTable()
	end
	if params[:last]			
		@activities = Activity.showTable(Date.today-params[:numberOfDays].to_i)
		
		
	end
	
  end

  def results
	
  end

  def details
  end
end
