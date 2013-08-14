class User < BaseUser

  field :email,                    type: String

  field :last_seen,                type: Time
  field :last_seen_notifications,  type: Time, default: Time.at(0)
  field :last_active,              type: Time
  field :client_last_active,       type: Hash, default: {}

  embeds_one :dropsport_account

  has_and_belongs_to_many :fanpages, class_name: "Fanpage", inverse_of: :admins

  field :admin, type: Boolean, default: false

  has_many :bookmarks, inverse_of: :user, dependent: :destroy
  field :locale, type: String, default: "en"
  has_and_belongs_to_many :suggested_friends, class_name: "User", inverse_of: nil

  def generate_view_data
    {
    :name => name,
    :link => link,
    :email => email,
    :type => 'U',
    :fanadmins => fanpages,
    :id => id,
    :cla => client_last_active,
    :date => created_at
    }
  end

  def self.countUsrsByDate(dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
    map = %Q{
    function(){
    var date = (new Date(this.created_at)).toISOString();
    var dataKey = (date.substring(0,4)+"-"+date.substring(5,7)+"-"+date.substring(8,10));
    var key = {data: dataKey};
    emit (key, { "Created": 1, "Id": this._id} );

    }
    }

    reduce = %Q{
    function(key, values) {
    cCreated = 0;
    idArray = new Array()
    values.forEach(function(v) {
    cCreated += v.Created;
    idArray.push(v.Id);
    });
    return { "Created": cCreated, "Id": idArray };
    }
    }
    return self.where(:created_at => { '$gte' => dataOd, '$lte' => dataDo } ).map_reduce(map, reduce).out(inline: true).sort_by { "_id" }.reverse.to_a
  end

end 



