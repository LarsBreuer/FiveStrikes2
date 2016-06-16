require 'test_helper'

class TickerEventsControllerTest < ActionController::TestCase
  setup do
    @ticker_event = ticker_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ticker_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ticker_event" do
    assert_difference('TickerEvent.count') do
      post :create, ticker_event: { game_id: @ticker_event.game_id, ticker_event_note: @ticker_event.ticker_event_note, time: @ticker_event.time }
    end

    assert_redirected_to ticker_event_path(assigns(:ticker_event))
  end

  test "should show ticker_event" do
    get :show, id: @ticker_event
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ticker_event
    assert_response :success
  end

  test "should update ticker_event" do
    put :update, id: @ticker_event, ticker_event: { game_id: @ticker_event.game_id, ticker_event_note: @ticker_event.ticker_event_note, time: @ticker_event.time }
    assert_redirected_to ticker_event_path(assigns(:ticker_event))
  end

  test "should destroy ticker_event" do
    assert_difference('TickerEvent.count', -1) do
      delete :destroy, id: @ticker_event
    end

    assert_redirected_to ticker_events_path
  end
end
