require 'tempfile'
require 'zip'
require 'securerandom'

module ListingCommands
  class ArchiveGallery

    AVAILABLE_SIZES = %w(large original square thumb)

    def initialize(listing, options = {})
      @cached_photos = Hash.new
      @listing = listing
      @subscribers = Hash.new { |h, k| h[k] = [] }
      @image_size = options.fetch(:image_size) { :original }

      unless AVAILABLE_SIZES.include?(@image_size)
        raise ArgumentError.new("image_size must be one of the following types: #{AVAILABLE_SIZES.join(', ')}")
      end
    end

    def on(event, &callback)
      subscribers[event] << callback
    end

    def execute
      cache_photos_locally
      zip_cached_photos
      run_callbacks(:success, zip_data)
    rescue
      run_callbacks(:failure)
    ensure
      cleanup_cache
    end

    private

    def cache_photos_locally
      listing.photos.each_with_index do |photo, index|
        tempfile = Tempfile.new(SecureRandom.uuid)
        photo.image.copy_to_local_file(image_size, tempfile.path)

        filename = photo.image_file_name
        pretty_index = index.to_s.rjust(3, '0')
        indexed_filename = [pretty_index, filename].join('_')

        cached_photos[indexed_filename] = tempfile
      end
    end

    def cleanup_cache
      cached_photos.each do |_, file|
        file.close
        file.unlink
      end

      # If zip file has been created
      if zip_file
        zip_file.close
        zip_file.unlink
      end
    end

    def run_callbacks(event, *args)
      subscribers[event].each { |callback| callback.call(*args) }
    end

    def zip_cached_photos
      self.zip_file = Tempfile.new(SecureRandom.uuid)

      # Hack to convert tempfile to .zip
      Zip::OutputStream.open(zip_file) { |zos| }

      Zip::File.open(zip_file.path, Zip::File::CREATE) do |zip|
        cached_photos.each do |filename, file|
          zip.add(filename, file.path)
        end
      end
    end

    def zip_data
      File.read(zip_file.path)
    end

    attr_accessor :zip_file
    attr_reader :cached_photos, :image_size, :listing, :subscribers
  end
end
