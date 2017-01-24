class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_msg, :set_msg, :clear_msg, :is_msg?


  private

  def after_sign_out_path_for(resource_or_scope)
    home_path
  end

  def check_access_level(role)
    redirect_to home_path unless current_user.role_access?(role)
  end

  def after_omniauth_failure_path_for(resource)
    home_path
  end

  def after_inactive_sign_up_path_for(resource)
    home_path
  end

  # for passing around flash messages to/from js.erb
  def current_msg
    return session[:msg] if defined?(session[:msg])
    return ''
  end
  def set_msg str
    session[:msg] = str
  end
  def clear_msg
    session[:msg] = ''
  end
  def is_msg?
    return true if session[:msg] && session[:msg].length > 0
  end

  def log_sign_in(user = current_user)
    if user
      filename = Rails.root.join('log', 'login_history.log')
      sign_in_time = user.current_sign_in_at ? user.current_sign_in_at : Time.now
      File.open(filename, 'a') { |f| f.write("#{sign_in_time.strftime("%Y-%m-%dT%H:%M:%S%Z")} #{user.current_sign_in_ip} #{user.name} #{user.email if user.email}\n") }
    end
  end

  def current_cart
    unless (cart = Cart.where(id: session[:cart_id]).first)
      cart = Cart.create
      session[:cart_id] = cart.id
      logger.debug("New cart created: #{session[:cart_id]}")
    end
    cart
  end

  def setup_last_games_in_cart
    @last_games = Game.limit(10).order('created_at ASC').all
    if @last_games.any?
      cart = current_cart
      unless current_cart.line_items.any?
        @last_games.each {|game| cart.line_items.create(game: game)}
      end
      @line_items = cart.line_items.limit(100).all
      if @line_items.first.game and @last_games.first
        @game = @last_games.first
        @game_overview = @game.get_game_main_stat()
        @ticker_activities = @game.ticker_activities
      end
    end
  end

  def js_error_message(message)
    "$('#error_message').html('#{message}'); $('#error_explanation').show();"
  end
end
