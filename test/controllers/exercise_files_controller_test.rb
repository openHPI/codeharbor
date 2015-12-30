require 'test_helper'

class ExerciseFilesControllerTest < ActionController::TestCase
  setup do
    @exercise_file = exercise_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exercise_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create exercise_file" do
    assert_difference('ExerciseFile.count') do
      post :create, exercise_file: { content: @exercise_file.content, exercise_id: @exercise_file.exercise_id, filetype: @exercise_file.filetype, main: @exercise_file.main, path: @exercise_file.path, solution: @exercise_file.solution }
    end

    assert_redirected_to exercise_file_path(assigns(:exercise_file))
  end

  test "should show exercise_file" do
    get :show, id: @exercise_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @exercise_file
    assert_response :success
  end

  test "should update exercise_file" do
    patch :update, id: @exercise_file, exercise_file: { content: @exercise_file.content, exercise_id: @exercise_file.exercise_id, filetype: @exercise_file.filetype, main: @exercise_file.main, path: @exercise_file.path, solution: @exercise_file.solution }
    assert_redirected_to exercise_file_path(assigns(:exercise_file))
  end

  test "should destroy exercise_file" do
    assert_difference('ExerciseFile.count', -1) do
      delete :destroy, id: @exercise_file
    end

    assert_redirected_to exercise_files_path
  end
end
