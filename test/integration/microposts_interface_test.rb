require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:test)
    @user2 = users(:roger)
  end
  
  test "micropost display" do
    get root_path
    assert_match "Welcome to the Sample App", response.body
    assert_no_match "Micropost feed", response.body
    log_in_as(@user)
    assert_redirected_to @user    
    follow_redirect!
    get root_path
    assert_no_match "Welcome to the Sample App", response.body    
    assert_match @user.name, response.body
    assert_match "#{@user.microposts.count} microposts", response.body
    assert_select "input[type=file]", 1
    #Invalid submission
    post microposts_path, micropost: { content:"" }
    assert_select 'div#error_explanation'
    #Valid Submission
    content = "This is a good content"    
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference "Micropost.count", 1 do
      post microposts_path, micropost: { content: content, picture: picture }      
    end
    #test if the picture was uploaded
    assert @user.microposts.first.picture?
    #Alternative
    micropost = assigns(:micropost)
    assert micropost.picture?
    ###
    assert_redirected_to root_path
    follow_redirect!
    assert_match content, response.body
    #Delete a post
    assert_select "a", "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path first_micropost   
    end
    #Visit different user
    get user_path @user2
    assert_select 'a', text: 'delete', count: 0    
    #login with a no microposts user    
    log_in_as @user2
    get root_path
    assert_match "0 microposts", response.body  
    @user2.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 micropost", response.body  
  end  
  
  
end
