require 'test_helper'

class QuestionPairingDisabilitiesControllerTest < ActionController::TestCase
  setup do
    @question_pairing_disability = question_pairing_disabilities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:question_pairing_disabilities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create question_pairing_disability" do
    assert_difference('QuestionPairingDisability.count') do
      post :create, question_pairing_disability: @question_pairing_disability.attributes
    end

    assert_redirected_to question_pairing_disability_path(assigns(:question_pairing_disability))
  end

  test "should show question_pairing_disability" do
    get :show, id: @question_pairing_disability.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @question_pairing_disability.to_param
    assert_response :success
  end

  test "should update question_pairing_disability" do
    put :update, id: @question_pairing_disability.to_param, question_pairing_disability: @question_pairing_disability.attributes
    assert_redirected_to question_pairing_disability_path(assigns(:question_pairing_disability))
  end

  test "should destroy question_pairing_disability" do
    assert_difference('QuestionPairingDisability.count', -1) do
      delete :destroy, id: @question_pairing_disability.to_param
    end

    assert_redirected_to question_pairing_disabilities_path
  end
end
