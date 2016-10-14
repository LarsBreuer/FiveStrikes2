class Club < ActiveRecord::Base

	has_many :teams
	has_many :line_items
	belongs_to :district

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

	# Import CSV-File
	def self.import(file)
   		CSV.foreach(file.path, headers: true, encoding:'iso-8859-1:utf-8') do |row|
   			club_hash = row.to_hash
   			club_hash.keys.each do |k|
			club_hash[k] = club_hash[k].encode("iso-8859-1").force_encoding("utf-8") if club_hash[k]
		end
     	Club.create!(club_hash)
   	end

  end

end
