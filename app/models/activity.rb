class Activity

  autoload :ActivityNotification, "models/notifications/activity_notification.rb"

  include Mongoid::Document
  include Mongoid::Timestamps

  class Repeat
    include Mongoid::Document
    field :repeats, type: String
    field :occurence, type: Integer, default: 0
    attr_accessible :repeats
  end
  attr_accessible :discipline, :description, :time, :repeat

  belongs_to :author, class_name: "BaseUser", inverse_of: :activities

  embeds_one :author_info,  class_name: "UserInfo"
  before_create :set_author_info

  belongs_to :parent, class_name: "Activity", inverse_of: nil

  field :state, type: Symbol, default: :open

  field :time, type: TimeSpec

  field :repeat, type: Activity::Repeat

  field :discipline, type: String

  field :description, type: String

  has_and_belongs_to_many :enrolled, class_name: "BaseUser", inverse_of: :enrolled_in

  has_and_belongs_to_many :liked, class_name: "BaseUser", inverse_of: :liked_in

  embeds_many :enrolled_users, class_name: "UserInfo"

  embeds_many :liked_users, class_name: "UserInfo"

  field :client, type: String

  before_create :enroll_author
  after_create :notify_followers


  def self.webAddress()
	  return "https://my.dropsport.com"
  end

  # activities, zliczanie klientow, grupowanie po dniach
  def self.countActivities(dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
    map = %Q{
      function(){

        var date = (new Date(this.created_at)).toISOString();
        var dataKey = (date.substring(0,4)+"-"+date.substring(5,7)+"-"+date.substring(8,10));
        var key = {data: dataKey};
        var client = this.client
        switch(client){
          case "web":
            emit (key, { "web": 1, "Android": 0, "ios": 0, "unknown": 0, "all": 1} );
            break;
          case "Android":
            emit (key, { "web": 0, "Android": 1, "ios": 0, "unknown": 0, "all": 1} );
            break;
          case "ios":
            emit (key, { "web": 0, "Android": 0, "ios": 1, "unknown": 0, "all": 1} );
            break;
          case "unknown":
            emit (key, { "web": 0, "Android": 0, "ios": 0, "unknown": 1, "all": 1} );
            break;
        }
      }
    }

    reduce = %Q{
      function(key, values) {
        cWeb = 0, cAndroid = 0, cIos = 0, cUnknown = 0, cAll = 0;
        values.forEach(function(v) {
      cWeb += v.web;
      cAndroid += v.Android;
      cIos += v.ios;
      cUnknown += v.unknown;
      cAll += v.all;
        });
        return { "web": cWeb, "Android": cAndroid, "ios": cIos, "unknown": cUnknown, "all": cAll };
      }
    }
    return self.where(:created_at => { '$gte' => dataOd, '$lte' => dataDo } ).map_reduce(map, reduce).out(inline: true).sort_by { "_id" }.reverse
  end


  def self.activitiesDetails(dateInput)
    date = DateTime.new((dateInput[0,4]).to_i, (dateInput[5,2]).to_i,(dateInput[8,2]).to_i)
    # ---------------------------------

    # pobranie tablicy aktywnosci
    activityModelInput = Activity.activityDayDetails(date, date + 23.hours + 59.minutes + 59.seconds )
    # -----------------------------

    # tworzenie prototypow tablic dla aktywnosci
    activitiesArray = Array.new()
    activity = Array.new()
    # ---------------------------

    activityModelInput.each do |ami|

      # sprawdzanie danych aktywnosci
      if (ami.repeat==nil)
        repeat = "false"
      else
        repeat = "true"
      end

      # wyciaganie danych Usera
      id = ami.author_id.to_s
      uam = BaseUser.find_by("id" => id)
      email = " - "
      type = " - "
      fanPageName = " - "
      enrolledemails = ""
      if ( uam._id.to_s == id )
        if ( uam._type.to_s == "User" )
          type = "U"
          email = uam.email
          enrolledemails = email+", "
        else
          type = "F"
        end
      end

      enr_ids = ami.enrolled_ids

      enr_ids.each_with_index do |enr, i|
        if ( i>0 )
          enrolledemails +=(BaseUser.find_by("id" => enr).email).to_s
          if ( i!=enr_ids.size-1 )
            enrolledemails +=", "
          end
        end

      end
      # tworzenie tablicy z aktywnosciami dla widoku
      activity = {
        :time => (ami.created_at.to_s)[11,8],
        :link => webAddress()+"/activities/"+ami._id+"",
        :discipline => ami.discipline,
        :author_info => ami.author_info["name"],
        :client => ami.client,
        :enrolled => ami.enrolled_ids.size-1,
        :repeat => repeat,
        :email => email,
        :type => type,
        :fanPageName => fanPageName,
        :state => ami.state,
        :enrolledemails => enrolledemails
      }
      activitiesArray.push(activity)
      # -----------------------------------
    end

    return activitiesArray
  end


  def self.activityDayDetails( dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now   )
	  return where(:created_at => { '$gt' => dataOd, '$lt' => dataDo } ).desc(:created_at)
  end

end
