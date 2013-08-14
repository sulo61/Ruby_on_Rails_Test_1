class UserInfo
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  field :_id,         type: String, default: nil
  field :name,        type: String
  field :facebook_id, type: String
  field :avatar,      type: String
  field :commercial,  type: Boolean, default: false
  belongs_to :user
  
  embedded_in :notification
  embedded_in :activity
  embedded_in :comment
  embedded_in :place
end
