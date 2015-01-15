require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase

  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post :create
    end
    assert_redirected_to login_url
  end
  
  test 'destroy should require logged-in user' do
    assert_no_difference 'Relationship.count' do
      delete :destroy, id: relationships(:one)
    end
    assert_redirected_to login_url
  end
  
  test "follow should be impossible if user's already followed" do
    user = users(:michael)
    followed = users(:lana)
    log_in_as(user)
    assert_no_difference 'Relationship.count' do
      post :create, followed_id: followed
    end
  end

end
