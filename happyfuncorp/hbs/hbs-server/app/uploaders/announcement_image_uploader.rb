# encoding: utf-8

class AnnouncementImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  process :quality => 85
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
