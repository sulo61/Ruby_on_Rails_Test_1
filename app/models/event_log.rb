class EventLog

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :user, inverse_of: nil
  field :action, type: String
  belongs_to :activity, inverse_of: nil
  field :client, type: String

  def self.findById(id)
	return find_by(:id => id)
  end

  def self.countUsrsByDate(dataOd=DateTime.new(2000,01,01), dataDo=DateTime.now )
	eventLogUsrs = User.countUsrsByDate(dataOd, dataDo)

	eventLogUsrs.map do |u|
		{ 
			:date => u["_id"]["data"],
			:count => u["value"]["Created"],
			:id => u["value"]["Id"].flatten
		}
		
	end

  end

end


