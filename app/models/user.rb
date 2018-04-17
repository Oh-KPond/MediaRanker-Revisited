class User < ApplicationRecord
  has_many :votes
  has_many :ranked_works, through: :votes, source: :work

  validates :username, uniqueness: true, presence: true

  def self.build_from_github(auth_data)
    return User.create(
      provider: auth_data[:provider],
      uid: auth_data[:uid],
      email: auth_data[:info][:email],
      username: auth_data[:info][:nickname]
    )
  end
end
