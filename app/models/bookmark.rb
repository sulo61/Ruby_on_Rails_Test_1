class Bookmark

  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :rect, :disciplines, :name

  belongs_to :user, inverse_of: :bookmarks

  field :rect, type: Hash

  field :disciplines, type: Array

  field :name, type: String


  def self.findById(id="", dateFrom, dateTo )
    where("user_id" => Moped::BSON::ObjectId(id))
  end


end