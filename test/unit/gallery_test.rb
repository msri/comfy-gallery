require File.expand_path('../test_helper', File.dirname(__FILE__))

class GalleryTest < ActiveSupport::TestCase

  def test_fixtures_validity
    Gallery::Gallery.all.each do |gallery|
      assert gallery.valid?, gallery.errors.full_messages.to_s
    end
  end

  def test_validations
    gallery = Gallery::Gallery.new
    assert gallery.invalid?
    assert_has_errors_on gallery, [:title, :identifier]
  end

  def test_creation
    assert_difference 'Gallery::Gallery.count', 1 do
      gallery = Gallery::Gallery.create!(
        :title        => 'Test Gallery',
        :identifier   => 'test-gallery',
        :description  => 'Test Description'
      )
      assert_equal 'Test Gallery', gallery.title
      assert_equal 'test-gallery', gallery.identifier
      assert_equal 'Test Description', gallery.description
      assert_equal 1, gallery.position
    end
  end

  def test_destroy
    gallery = gallery_galleries(:default)
    assert_difference ['Gallery::Gallery.count', 'Gallery::Photo.count'], -1 do
      gallery.destroy
    end
  end

end
