class District < ActiveRecord::Base
  
  has_many :clubs

  # Import CSV-File
	def self.import(file)

   	CSV.foreach(file.path, headers: true, encoding:'iso-8859-1:utf-8') do |row|
   		district_hash = row.to_hash
   		district_hash.keys.each do |k|
			district_hash[k] = district_hash[k].encode("iso-8859-1").force_encoding("utf-8") if district_hash[k]
		end
     	District.create!(district_hash)
   	end
  end

end
