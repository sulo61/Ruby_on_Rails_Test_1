class User
  include Mongoid::Document

  field :username, type: String
  field :password, type: String
  field :email, type: String
  field :register_date, type: Date
end
