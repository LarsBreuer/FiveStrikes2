module ApplicationHelper
	def spinner_tag id
    	#Assuming spinner image is called "spinner.gif"
    	image_tag("spinner.gif", :id => id, :alt => t(:loading, :scope => 'myinfo.buttons'), :style => "display:none")
  	end  
end
