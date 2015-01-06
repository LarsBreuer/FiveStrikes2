class Club < ActiveRecord::Base

	has_many :teams

	def self.search(search)
		if search
			find(:all, :conditions => ['club_name LIKE ?', "%#{search}%"])
		else
    		find(:all)
  		end
	end

end