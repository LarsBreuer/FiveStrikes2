class TickerEventsController < InheritedResources::Base



	# POST /ticker_events
  	# POST /ticker_events.json
  	def create
    
    	params["_json"].each do |params_hash|
      		puts params_hash.inspect
      		@ticker_event = TickerEvent.new(params_hash)
      		@ticker_event.save
    	end

    	#@ticker_event = TickerEvent.new(params[:ticker_event])

    	respond_to do |format|
      		if @ticker_event.save
        		format.html { redirect_to @ticker_event, notice: 'Ticker was successfully created.' }
        		format.json { render json: @ticker_event, status: :created, location: @ticker_event }
      		else
        		format.html { render action: "new" }
        		format.json { render json: @ticker_event.errors, status: :unprocessable_entity }
      		end
    	end
  	end

	# POST /multiple_ticker_events
	# POST /multiple_ticker_events.json
	def create_multiple
  		puts params

  		@ticker_events = params["_json"].map do |params_hash|
    		# ToDo => whitelisted_params einbauen. Siehe mein Beitrag bei stackoverflow unter http://stackoverflow.com/questions/35082478/handling-json-array-from-android-in-rails
    		ticker = TickerEvent.create!(params_hash)     
  		end

  		respond_to do |format|
    		# Check that all the ticker_activities are valid and can be saved
    		if @ticker_events.all? { |ticker_event| ticker_event.valid? }
      			# Now we know they are valid save each ticker_activity
      			@ticker_events.each do |ticker_event|
        			ticker_event.save
      			end

      			# Respond with the json versions of the saved ticker_activites
      			format.json { render json: @ticker_events, status: :created, location: multiple_ticker_event_locations_url }
    
    		else
      			# We can't save *all* the ticker_event so we
      			# respond with the corresponding validation errors for the ticker_events
      			@errors = @ticker_events.map { |ticker_event| ticker_event.errors }
      			format.json { render json: @errors, status: :unprocessable_entity }
    		end
  		end
	end
end
