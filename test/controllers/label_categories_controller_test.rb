require 'test_helper'

class LabelCategoriesControllerTest < ActionController::TestCase
  setup do
    @label_category = label_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:label_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create label_category" do
    assert_difference('LabelCategory.count') do
      post :create, label_category: { name: @label_category.name }
    end

    assert_redirected_to label_category_path(assigns(:label_category))
  end

  test "should show label_category" do
    get :show, id: @label_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @label_category
    assert_response :success
  end

  test "should update label_category" do
    patch :update, id: @label_category, label_category: { name: @label_category.name }
    assert_redirected_to label_category_path(assigns(:label_category))
  end

  test "should destroy label_category" do
    assert_difference('LabelCategory.count', -1) do
      delete :destroy, id: @label_category
    end

    assert_redirected_to label_categories_path
  end
end
