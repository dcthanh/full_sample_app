require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  
  
  def setup
    @user = users(:test)
  end
    
  test "microposts of the user should be display with pagination" do
    log_in_as(@user)
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_match @user.name, response.body
    assert_select 'img.gravatar'
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1, :per_page => 30).each do |micropost|   
      assert_select "li#micropost-#{micropost.id}", 1
      assert_match micropost.content, response.body
    end
    @user.microposts.paginate(page: 2).each do |micropost|
      assert_select "li#micropost-#{micropost.id}", 0
    end
    assert_match @user.microposts.count.to_s, response.body
  end
  
end
