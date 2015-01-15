require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test "layout links" do    
    delete logout_path
    get root_path
    assert_template 'static_pages/home' # teste si la page générée est bien la page home
    assert_select "a[href=?]", root_path, count:2 # teste si la page contient 2 fois un attribut href, d'une balise <a> contient le lien vers root_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", signup_path, count:1
  end
end
