class BaseUser

  autoload :FollowNotification, "models/notifications/follow_notification.rb"
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: "users"

  field :name,        type: String

  field :description, type: String

  field :commercial, type: Boolean, default: false

  has_and_belongs_to_many :followers, class_name: "BaseUser", inverse_of: :following
  has_and_belongs_to_many :following, class_name: "BaseUser", inverse_of: :followers

  has_many :activities, inverse_of: :author, dependent: :destroy

  has_and_belongs_to_many :enrolled_in, class_name: "Activity", inverse_of: :enrolled
  has_and_belongs_to_many :liked_in, class_name: "Activity", inverse_of: :liked

  def self.usrDetailsByName(name)
    where(:name => name).map { |u| u.generate_view_data }
  end

  def self.webAddress
    "https://my.dropsport.com"
  end

  def link
    "#{BaseUser.webAddress}/users/#{id}"
  end

  def self.showUsrsByDate
    map = %Q{
    function(){
    var date = (new Date(this.created_at)).toISOString();
    var dataKey = (date.substring(0,4)+"-"+date.substring(5,7)+"-"+date.substring(8,10));
    var key = {data: dataKey};
    var type = this._type
    switch(type){
    case "User":
    emit (key, { "User": 1, "Fanpage": 0, "all": 1} );
    break;
    case "Fanpage":
    emit (key, { "User": 0, "Fanpage": 1, "all": 1} );
    break;
    default:
    emit (key, { "User": 0, "Fanpage": 0, "all": 1} );
    }
    }
    }
    reduce = %Q{
    function(key, values) {
    cUser = 0, cFanpage = 0, cAll = 0;
    values.forEach(function(v) {
    cUser += v.User;
    cFanpage += v.Fanpage;
    cAll += v.all;
    });
    return { "User": cUser, "Fanpage": cFanpage, "all": cAll };
    }
    }
    map_reduce(map, reduce).out(inline: true).sort_by { "_id" }.reverse.map do |m|
      d = m["_id"]["data"]
      comment = Comment.where("date" => DateTime.new((d[0,4]).to_i, (d[5,2]).to_i, (d[8,2]).to_i)).map  { |m| m.text }
      {
          :date => m["_id"]["data"],
          :user => m["value"]["User"],
          :fanpage => m["value"]["Fanpage"],
          :all => m["value"]["all"],
          :comment => comment[0]

      }
    end
  end

  def self.usrsDayDetails(dateInput)
    date = DateTime.new((dateInput[0,4]).to_i, (dateInput[5,2]).to_i, (dateInput[8,2]).to_i)
    BaseUser.showDay(date, date + 23.hours + 59.minutes + 59.seconds ).map  { |u| u.generate_view_data }
  end

  def self.showDay( dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
    where(:created_at => { '$gt' => dataOd, '$lt' => dataDo } ).desc(:created_at)
  end

end