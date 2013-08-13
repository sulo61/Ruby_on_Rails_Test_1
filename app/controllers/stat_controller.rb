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


    @@EL_LAST = EVENT_DAYS_BACK
    @@EL_XDAY = EVENT_DAYS_BACK
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
        @datesRange = @adf+" <-> "+@adt
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
        @datesRange = @xdays+" days after user created"
        render "eventlogMain"
    end


end
