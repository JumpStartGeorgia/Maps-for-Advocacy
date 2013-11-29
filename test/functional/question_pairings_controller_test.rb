require 'test_helper'

class QuestionPairingsControllerTest < ActionController::TestCase
  setup do
    @question_pairing = question_pairings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:question_pairings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create question_pairing" do
    assert_difference('QuestionPairing.count') do
      post :create, question_pairing: @question_pairing.attributes
    end

    assert_redirected_to question_pairing_path(assigns(:question_pairing))
  end

  test "should show question_pairing" do
    get :show, id: @question_pairing.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @question_pairing.to_param
    assert_response :success
  end

  test "should update question_pairing" do
    put :update, id: @question_pairing.to_param, question_pairing: @question_pairing.attributes
    assert_redirected_to question_pairing_path(assigns(:question_pairing))
  end

  test "should destroy question_pairing" do
    assert_difference('QuestionPairing.count', -1) do
      delete :destroy, id: @question_pairing.to_param
    end

    assert_redirected_to question_pairings_path
  end
end
