require 'test_helper'

class WebsitesControllerTest < ActionController::TestCase
  setup do
    @website = websites(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:websites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create website" do
    assert_difference('Website.count') do
      post :create, website: { deploy_path: @website.deploy_path, domain: @website.domain, git_enabled: @website.git_enabled, name: @website.name, nginx_enabled: @website.nginx_enabled, nginx_path: @website.nginx_path, post_receive_path: @website.post_receive_path }
    end

    assert_redirected_to website_path(assigns(:website))
  end

  test "should show website" do
    get :show, id: @website
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @website
    assert_response :success
  end

  test "should update website" do
    put :update, id: @website, website: { deploy_path: @website.deploy_path, domain: @website.domain, git_enabled: @website.git_enabled, name: @website.name, nginx_enabled: @website.nginx_enabled, nginx_path: @website.nginx_path, post_receive_path: @website.post_receive_path }
    assert_redirected_to website_path(assigns(:website))
  end

  test "should destroy website" do
    assert_difference('Website.count', -1) do
      delete :destroy, id: @website
    end

    assert_redirected_to websites_path
  end
end
