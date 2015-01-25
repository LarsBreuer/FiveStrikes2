class Club < ActiveRecord::Base

	has_many :teams

	def self.search(club_name, club_id)
		if club_name
			find(:all, :conditions => ['club_name LIKE ?', "%#{club_name}%"])
		else
			if club_id
				find(:all, :conditions => ['id = ?', club_id])
			else
    			find(:all)
    		end
  		end
	end

end
