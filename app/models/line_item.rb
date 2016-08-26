class LineItem < ActiveRecord::Base

  belongs_to :cart
  belongs_to :game
  belongs_to :player
  belongs_to :team
  belongs_to :club
  belongs_to :user

  default_scope order('created_at DESC')

end
