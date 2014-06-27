require 'test_helper'

class ConventionCategoriesControllerTest < ActionController::TestCase
  setup do
    @convention_category = convention_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:convention_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create convention_category" do
    assert_difference('ConventionCategory.count') do
      post :create, convention_category: @convention_category.attributes
    end

    assert_redirected_to convention_category_path(assigns(:convention_category))
  end

  test "should show convention_category" do
    get :show, id: @convention_category.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @convention_category.to_param
    assert_response :success
  end

  test "should update convention_category" do
    put :update, id: @convention_category.to_param, convention_category: @convention_category.attributes
    assert_redirected_to convention_category_path(assigns(:convention_category))
  end

  test "should destroy convention_category" do
    assert_difference('ConventionCategory.count', -1) do
      delete :destroy, id: @convention_category.to_param
    end

    assert_redirected_to convention_categories_path
  end
end
