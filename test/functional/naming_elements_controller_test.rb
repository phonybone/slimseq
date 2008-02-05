require File.dirname(__FILE__) + '/../test_helper'
require 'naming_elements_controller'

# Re-raise errors caught by the controller.
class NamingElementsController; def rescue_action(e) raise e end; end

class NamingElementsControllerTest < Test::Unit::TestCase
  fixtures :naming_schemes, :naming_elements, :naming_terms

  def setup
    @controller = NamingElementsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    # test as admin
    login_as_admin
  end

  def test_list_for_naming_scheme_with_naming_scheme_param
    get :list_for_naming_scheme, :naming_scheme_id => 1

    assert_response :success
    assert_template 'list_for_naming_scheme'

    assert_not_nil assigns(:naming_elements)
  end

  def test_list_for_naming_scheme_with_naming_scheme_in_session
    # use to set session[:naming_scheme_id]
    get :list_for_naming_scheme, :naming_scheme_id => 1

    get :list_for_naming_scheme

    assert_response :success
    assert_template 'list_for_naming_scheme'

    assert_not_nil assigns(:naming_elements)
  end

  def test_list_for_naming_scheme_without_naming_scheme
    get :list_for_naming_scheme

    assert_response :redirect
    assert_redirected_to :controller => 'naming_schemes', :action => 'list'
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:naming_element)
    assert_not_nil assigns(:naming_element_list)
  end

  def test_create
    num_naming_elements = NamingElement.count

    post :create, :naming_element => {:name => "My Element"}

    assert_response :redirect
    assert_redirected_to :action => 'list_for_naming_scheme'

    assert_equal num_naming_elements + 1, NamingElement.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:naming_element)
    assert_not_nil assigns(:naming_element_list)
  end

  def test_update
    post :update, :id => 1

    assert_response :redirect
    assert_redirected_to :action => 'list_for_naming_scheme'
  end

  def test_destroy
    assert_not_nil NamingElement.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list_for_naming_scheme'
    
    assert_raise(ActiveRecord::RecordNotFound) {
      NamingElement.find(1)
    }
  end
end