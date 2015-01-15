require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  def setup
    @user = users(:test)
    @user2 = users(:roger)
    @user3 = users(:michael)
  end
  
  
  test "should get new" do
    get :new
    assert_response :success
    assert_select "title", "Sign up | Ruby on Rails Tutorial Sample App"
  end
  
  test "should redirect index when not logged_in" do
    get :index
    assert_redirected_to login_url
  end
  
  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_redirected_to login_url
  end
  
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@user2)
    get :edit, id: @user
    assert_redirected_to root_url
  end
  
  test "should redirect update when logged in as wrong user" do
    log_in_as(@user2)
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_redirected_to root_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in as admin" do
    log_in_as(@user2)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user3
    end    
    assert_redirected_to root_url
  end
  
  test "should redirect destroy when admin try to delete itself" do
    log_in_as(@user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end
  
  test "destroy should be successfull when logged as an admin user" do
    log_in_as(@user)
    assert_difference 'User.count', -1 do
      delete :destroy, id: @user3
    end
    assert_redirected_to users_url
  end
  
  test "should redirect following when not logged_in" do
    get :following, id: @user
    assert_redirected_to login_url
  end
  
  test "should redirect followers when logged_in" do
    get :followers, id: @user
    assert_redirected_to login_url
  end
 
end
