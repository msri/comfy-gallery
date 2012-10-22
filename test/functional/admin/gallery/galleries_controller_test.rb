require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Admin::Gallery::GalleriesControllerTest < ActionController::TestCase

  def test_get_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_get_new
    get :new
    assert_response :success
    assert_template 'new'
    assert assigns(:gallery)
    assert_select "form[action='/admin/gallery/galleries']"
  end

  def test_creation
    assert_difference 'Gallery::Gallery.count', 1 do
      post :create, :gallery => {
        :title        => 'Test Gallery',
        :identifier   => 'test-gallery',
        :description  => 'Test Description'
      }
    end
    assert_equal 'Gallery created', flash[:notice]
    assert_redirected_to :action => :index
  end


  def test_creation_failure
    assert_no_difference 'Gallery::Gallery.count' do
      post :create, :gallery => { }
    end
    assert_response :success
    assert_template 'new'
    assert_equal 'Failed to create Gallery', flash[:error]
  end

  def test_get_edit
    gallery = gallery_galleries(:default)
    get :edit, :id => gallery
    assert_response :success
    assert_template 'edit'
    assert assigns(:gallery)
    assert_select "form[action='/admin/gallery/galleries/#{gallery.id}']"
  end

  def test_get_edit_failure
    get :edit, :id => 'invalid'
    assert_response :redirect
    assert_redirected_to :action => :index
    assert_equal 'Gallery not found', flash[:error]
  end

  def test_update
    gallery = gallery_galleries(:default)
    put :update, :id => gallery, :gallery => {
      :title => 'New Title'
    }
    gallery.reload
    assert_equal 'New Title', gallery.title
    assert_equal 'Gallery updated', flash[:notice]
    assert_redirected_to :action => :index
  end

  def test_update_failure
    gallery = gallery_galleries(:default)
    put :update, :id => gallery, :gallery => {
      :title => ''
    }
    assert_response :success
    assert_template 'edit'
    assert_equal 'Failed to update Gallery', flash[:error]
    gallery.reload
    assert_not_equal '', gallery.title
  end

  def test_destroy
    assert_difference 'Gallery::Gallery.count', -1 do
      delete :destroy, :id => gallery_galleries(:default)
    end
    assert_equal 'Gallery deleted', flash[:notice]
    assert_redirected_to :action => :index
  end

  def test_reorder
    gallery_one = gallery_galleries(:default)
    gallery_two = Gallery::Gallery.create!(
        :title        => 'Test Gallery 2',
        :identifier   => 'test-gallery2',
        :description  => 'Test Description'
      )
    assert_equal 0, gallery_one.position
    assert_equal 1, gallery_two.position

    post :reorder, :gallery_gallery => [gallery_two.id, gallery_one.id]
    assert_response :success
    gallery_one.reload
    gallery_two.reload

    assert_equal 1, gallery_one.position
    assert_equal 0, gallery_two.position
  end

end
