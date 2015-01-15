require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
    @user1 = users(:test)
    @user2 = users(:roger)
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 256
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[dfer@rrifj.com USER@foo.fr A_FR_U-4-f@foo.bar.org]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"    
    end
  end
  
  test "email validation reject invalid addresses" do
    invalid_addresses = %w[user@example,com user.fr user@name@foo.bar.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid? "#{invalid_address.inspect} should be valid"
    end    
  end
  
  test "email should be unqiue" do
    duplicate_user = @user.dup
    duplicate_user.email =@user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with a nil digest"  do
    assert_not @user.authenticated?(:remember,'')
  end
  
  test "microposts should be deleted when user is deleted" do
    @user.save
    micropost = @user.microposts.create!(content: "lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  
  test "should follow and unfollow a user" do
    assert_not @user1.following?(@user2)
    @user1.follow(@user2)
    assert @user1.following?(@user2)
    assert @user2.followed_by?(@user1)
    @user1.unfollow(@user2)
    assert_not @user1.following?(@user2)
    assert_not @user2.followed_by?(@user1)
  end
  
end

