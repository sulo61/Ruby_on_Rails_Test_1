class Comment

  include Mongoid::Document

  attr_accessible :text, :date

  field :text, type: String
  field :date, type: DateTime




end