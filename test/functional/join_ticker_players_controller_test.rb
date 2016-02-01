require 'test_helper'

class JoinTickerPlayersControllerTest < ActionController::TestCase
  setup do
    @join_ticker_player = join_ticker_players(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:join_ticker_players)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create join_ticker_player" do
    assert_difference('JoinTickerPlayer.count') do
      post :create, join_ticker_player: @join_ticker_player.attributes
    end

    assert_redirected_to join_ticker_player_path(assigns(:join_ticker_player))
  end

  test "should show join_ticker_player" do
    get :show, id: @join_ticker_player
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @join_ticker_player
    assert_response :success
  end

  test "should update join_ticker_player" do
    put :update, id: @join_ticker_player, join_ticker_player: @join_ticker_player.attributes
    assert_redirected_to join_ticker_player_path(assigns(:join_ticker_player))
  end

  test "should destroy join_ticker_player" do
    assert_difference('JoinTickerPlayer.count', -1) do
      delete :destroy, id: @join_ticker_player
    end

    assert_redirected_to join_ticker_players_path
  end
end
