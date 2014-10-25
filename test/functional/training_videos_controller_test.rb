require 'test_helper'

class TrainingVideosControllerTest < ActionController::TestCase
  setup do
    @training_video = training_videos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:training_videos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create training_video" do
    assert_difference('TrainingVideo.count') do
      post :create, training_video: @training_video.attributes
    end

    assert_redirected_to training_video_path(assigns(:training_video))
  end

  test "should show training_video" do
    get :show, id: @training_video.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @training_video.to_param
    assert_response :success
  end

  test "should update training_video" do
    put :update, id: @training_video.to_param, training_video: @training_video.attributes
    assert_redirected_to training_video_path(assigns(:training_video))
  end

  test "should destroy training_video" do
    assert_difference('TrainingVideo.count', -1) do
      delete :destroy, id: @training_video.to_param
    end

    assert_redirected_to training_videos_path
  end
end
