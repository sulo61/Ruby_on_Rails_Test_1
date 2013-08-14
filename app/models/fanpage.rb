class Fanpage < BaseUser

  has_and_belongs_to_many :admins, class_name: "User", inverse_of: :fanpages

  def generate_view_data
  {
    :name => name,
    :link => link,
    :email => '-',
    :type => 'F',
    :fanadmins => admins,
    :id => id,
    :cla => ['-'],
    :date => created_at
  }
  end
end