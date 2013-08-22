class StatController < ApplicationController
    before_filter :auth, :except => [ :login, :logout ]

    DAYS_BACK = 14
    EVENT_DAYS_BACK = 7
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
          @nod = DAYS_BACK
        end

        if params[:last]
          @activities = Activity.countActivities(DT_NOW-params[:numberOfDays].to_i, DT_NOW)
          @nod = params[:numberOfDays].to_i
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
          @usrs = BaseUser.showUsrsByDate
        end
        if params[:find]
          @showByDate = false
          @usrs = BaseUser.usrDetailsByName(params[:name])

        end

    end

    def usrsDetails
        if params[:back]
          redirect_to :action => "usrsMain"
        end
        date = params[:date].to_s
        @showdate = date[0,10]
        # udostepnianie widokowi tablicy aktywnosci
        @usrsDetails = BaseUser.usrsDayDetails(date)
        # ------------------------------------------
    end


    @@EL_LAST = EVENT_DAYS_BACK
    @@EL_XDAY = EVENT_DAYS_BACK
    @@EL_XYDAYSX =  EVENT_DAYS_BACK
    @@EL_XYDAYSY =  EVENT_DAYS_BACK
    tmp_date_now = Date.new(DT_NOW.year, DT_NOW.month, DT_NOW.day)
    @@EL_DT = (tmp_date_now.to_s)[8,2]+"-"+(tmp_date_now.to_s)[5,2]+"-"+(tmp_date_now.to_s)[0,4]
    @@EL_DF = ((tmp_date_now-@@EL_XDAY.days).to_s)[8,2]+"-"+((tmp_date_now-@@EL_XDAY.days).to_s)[5,2]+"-"+((tmp_date_now-@@EL_XDAY.days).to_s)[0,4]

    def eventlogMain
        @@EL_LAST = params[:numberOfDays].to_i if ( params[:numberOfDays]!="" && params[:last] )

        @usrsByDate = EventLog.countUsrsByDate(DT_NOW-@@EL_LAST.days, DT_NOW)

        @last = @@EL_LAST
        @xdays = @@EL_XDAY
        @adf = @@EL_DF
        @adt = @@EL_DT
        @startAfterX =  @@EL_XYDAYSX
        @startAfterY =  @@EL_XYDAYSY
        @datesRange = "All"
    end


    def eventlogMainRange
        if ( params[:dateFrom]!="" && params[:dateTo]!="" )
          @@EL_DF = params[:dateFrom]
          @@EL_DT = params[:dateTo]
        end

        @usrsByDate = EventLog.countUsrsByDate(DT_NOW-@@EL_LAST.days, DT_NOW, @@EL_DF, ((DateTime.new((@@EL_DT[6,10]).to_i,(@@EL_DT[3,2]).to_i,(@@EL_DT[0,2]).to_i)) + 23.hours + 59.minutes + 59.seconds ))

        @last = @@EL_LAST
        @xdays = @@EL_XDAY
        @adf = @@EL_DF
        @adt = @@EL_DT
        @startAfterX =  @@EL_XYDAYSX
        @startAfterY =  @@EL_XYDAYSY
        @datesRange = "between: "+@adf+" and: "+@adt
        render "eventlogMain"
    end


    def eventlogMainXday
        if ( params[:numberOfXDays]!="" )
          @@EL_XDAY = params[:numberOfXDays]

        end

        @usrsByDate = EventLog.countUsrsByDate(DT_NOW-@@EL_LAST.days, DT_NOW, nil, nil, @@EL_XDAY )

        @last = @@EL_LAST
        @xdays = @@EL_XDAY
        @adf = @@EL_DF
        @adt = @@EL_DT
        @startAfterX =  @@EL_XYDAYSX
        @startAfterY =  @@EL_XYDAYSY
        @datesRange = "between: User creation date, and: "+@xdays+" days after the creation of user"
        render "eventlogMain"
    end


    def eventlogMainXYdays
      if ( params[:startAfterX]!="" && params[:startAfterY]!="" )
        @@EL_XYDAYSX = params[:startAfterX]
        @@EL_XYDAYSY = params[:startAfterY]
      end

      @usrsByDate = EventLog.countUsrsByDate(DT_NOW-@@EL_LAST.days, DT_NOW, nil, nil, @@EL_XYDAYSX, @@EL_XYDAYSY )

      @last = @@EL_LAST
      @xdays = @@EL_XDAY
      @adf = @@EL_DF
      @adt = @@EL_DT
      @startAfterX =  @@EL_XYDAYSX
      @startAfterY =  @@EL_XYDAYSY
      @datesRange = "between: "+@startAfterX+" days after the creation of user, and: "+@startAfterY+" days forward"
      render "eventlogMain"
    end

    def com_add
      d = params['d'][:index]
      to_send = "<td class=\"comment_"+d+"\"><textarea class=\"form-control\" rows=\"3\" cols=\"3\" val=\""+d+"\"></textarea><br><button class=\"btn btn-mini\", com_save=\"true\", remote=\"true\", val=\""+d+"\">Save</button></td>"
      respond_to do |format|
        format.json  { render :json => { :to_send => to_send, :index => d }}

      end
    end

    def com_edit_save

      c = params['d'][:com]
      d = params['d'][:date].to_s
      Comment.where("date" => DateTime.new((d[0,4]).to_i, (d[5,2]).to_i, (d[8,2]).to_i)).update_all("text" => c.to_s)

      respond_to do |format|
        format.json  { render :json => { :to_send => c }}

      end
    end

    def com_del

      d = params['d'][:date]
      i = params['d'][:index]

      to_del = Comment.where("date" => DateTime.new((d[0,4]).to_i, (d[5,2]).to_i, (d[8,2]).to_i))
      to_del.delete

      respond_to do |format|
        format.json  { render :json => { :to_send => "gut" }}

      end
    end

    #def com_show
    #  d = params['d'][:index]
    #  c = params['d'][:com]
    #  to_send = "<td class=\"comment_"+d+"\">"+c+"</td>"
    #  respond_to do |format|
    #    format.json  { render :json => { :to_send => to_send, :index => d }}
    #
    #  end
    #end
    #
    #def com_hide
    #  d = params['d'][:index]
    #  c = params['d'][:com]
    #
    #  to_send = "<td class=\"comment_"+d+"\"><button class=\"btn btn-mini\", com_show=\"true\", remote=\"true\", val=\""+d+"\", com=\""+c+"\" >Show</button></td>"
    #  respond_to do |format|
    #    format.json  { render :json => { :to_send => to_send, :index => d }}
    #
    #  end
    #end

    def del

      respond_to do |format|
        # format.html { redirect_to(posts_url) }
        format.json  { render :json => {  :lol => "om nom nom" }}
      end
    end



end
