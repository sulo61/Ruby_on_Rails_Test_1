class StatController < ApplicationController

  $searchType = 1
  $daysBack = 30
 
  def panel
	
	if params[:all]		
		$searchType = 1
		redirect_to :action => "results"
	end
	if params[:last]			
		$searchType = 2
		$daysBack = params[:numberOfDays].to_i
		redirect_to :action => "results"
		
	end
	
  end

  def results
	if $searchType == 1
		@activities = Activity.showTable()
	end
	if $searchType == 2
		@activities = Activity.showTable(Date.today-$daysBack)
	end
  end

  def details
  end
end
