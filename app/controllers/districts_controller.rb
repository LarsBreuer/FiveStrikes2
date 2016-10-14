class DistrictsController < InheritedResources::Base

	def import
    	begin
      		District.import(params[:file])
      		redirect_to home_path, notice: "Districts imported."
    	rescue
      		redirect_to home_path, notice: "Invalid CSV file format."
    	end
  	end

end

