require 'test_helper'

class TestingFrameworksControllerTest < ActionController::TestCase
  setup do
    @testing_framework = testing_frameworks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:testing_frameworks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create testing_framework" do
    assert_difference('TestingFramework.count') do
      post :create, testing_framework: { name: @testing_framework.name }
    end

    assert_redirected_to testing_framework_path(assigns(:testing_framework))
  end

  test "should show testing_framework" do
    get :show, id: @testing_framework
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @testing_framework
    assert_response :success
  end

  test "should update testing_framework" do
    patch :update, id: @testing_framework, testing_framework: { name: @testing_framework.name }
    assert_redirected_to testing_framework_path(assigns(:testing_framework))
  end

  test "should destroy testing_framework" do
    assert_difference('TestingFramework.count', -1) do
      delete :destroy, id: @testing_framework
    end

    assert_redirected_to testing_frameworks_path
  end
end
