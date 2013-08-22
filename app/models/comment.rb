class Comment

  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :text, :date

  field :text, type: String
  field :date, type: DateTime




end