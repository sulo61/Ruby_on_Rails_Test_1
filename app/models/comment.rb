class Comment

  include Mongoid::Document
  include Mongoid::Timestamps

  store_in session: "writeable"

  attr_accessible :text, :date

  field :text, type: String
  field :date, type: DateTime




end