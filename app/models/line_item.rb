class LineItem < ActiveRecord::Base

  belongs_to :cart
  belongs_to :game
  belongs_to :player
  belongs_to :team

end
