class Gallery::Photo < ActiveRecord::Base

  self.table_name = :gallery_photos

  upload_options = (ComfyGallery.config.upload_options || {}).merge(
    :styles => lambda { |image|
      g = image.instance.gallery
      f_settings = "#{g.full_width}x#{g.full_height}#{g.force_ratio_full?? '#' : '>'}"
      t_settings = "#{g.thumb_width}x#{g.thumb_height}#{g.force_ratio_thumb?? '#' : '>'}"
      {
        :full         => { :geometry => f_settings, :processors => [:full_cropper] },
        :thumb        => { :geometry => t_settings, :processors => [:thumb_cropper] },
        :admin_full   => '800x600>',
        :admin_thumb  => '40x30#'
      }
    },
    :path => ':rails_root/paperclip/galleries/:gallery_id/:id_partition/:style/:filename',
    :url => '/system/paperclip/galleries/:gallery_id/:id_partition/:style/:filename',
  )
  has_attached_file :image, upload_options

  attr_accessor :thumb_crop_x, :thumb_crop_y, :thumb_crop_w, :thumb_crop_h,
                :full_crop_x, :full_crop_y, :full_crop_w, :full_crop_h

  # -- Relationships --------------------------------------------------------
  belongs_to :gallery

  # -- Callbacks ------------------------------------------------------------
  before_create :assign_position
  after_update :reprocess_image, :if => :cropping?

  # -- Validations ----------------------------------------------------------
  validates :gallery_id,
    :presence => true
  validates_attachment_presence :image,
    :message      => 'There was no file uploaded!'
  validates_attachment_content_type :image,
    :content_type => %w(image/jpeg image/pjpeg image/gif image/png image/x-png),
    :message      => 'Please only upload .jpg, .jpeg, .gif or .png files.'
  validates_attachment_size :image,
    :less_than    => 20.megabytes

  attr_accessible :gallery, :title, :description, :image, :embed_code

  # -- Scopes ---------------------------------------------------------------
  default_scope order('gallery_photos.position')

  # -- Instance Methods -----------------------------------------------------
  def image_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(image.path(style))
  end

  def force_aspect?
    self.gallery.force_ratio_full? || self.gallery.force_ratio_thumb?
  end

  def cropping?
    cropping_thumb? || cropping_full?
  end

  def cropping_thumb?
    !thumb_crop_x.blank? && !thumb_crop_y.blank? && !thumb_crop_w.blank? && !thumb_crop_h.blank?
  end

  def cropping_full?
    !full_crop_x.blank? && !full_crop_y.blank? && !full_crop_w.blank? && !full_crop_h.blank?
  end

  def has_media?
    self.embed_code.present?
  end

private

  def assign_position
    max = self.gallery.photos.maximum(:position)
    self.position = max ? max + 1 : 0
  end

  def reprocess_image
    image.reprocess!
  end

  # interpolate in paperclip
  Paperclip.interpolates :gallery_id do |attachment, style|
    return super() if attachment.nil?

    attachment.instance.gallery.id.to_s
  end
end