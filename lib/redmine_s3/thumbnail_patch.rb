module RedmineS3
  module ThumbnailPatch
    # Generates a thumbnail for the source image to target
    def self.generate_s3_thumb(source, target, size, update_thumb = false)
      target_folder = RedmineS3::Connection.thumb_folder
      if update_thumb
        return unless defined?(MiniMagick)
        require 'open-uri'
        img = MiniMagick::Image.open(RedmineS3::Connection.object_url(source))
        img.resize("#{size}x#{size}>")

        RedmineS3::Connection.put(target, File.basename(target), img.to_blob, img.mime_type, target_folder)
      end
      RedmineS3::Connection.object_url(target, target_folder)
    end
  end
end
