require 'aws-sdk-s3'

Aws.config = { ssl_verify_peer: false }

module RedmineS3
  class Connection
    @@conn = nil
    @@s3_options = {
      :access_key_id => nil,
      :secret_access_key => nil,
      :bucket => nil,
      :folder => '',
      :endpoint => nil,
      :private => false,
      :expires => nil,
      :proxy => false,
      :thumb_folder => 'tmp',
      :region => nil
    }

    class << self
      def load_options
        file = ERB.new(File.read(File.join(Rails.root, 'config', 's3.yml'))).result
        YAML::load(file)[Rails.env].each do |key, value|
          @@s3_options[key.to_sym] = value
        end
      end

      def establish_connection
        load_options unless @@s3_options[:access_key_id] && @@s3_options[:secret_access_key]
        options = {
          :access_key_id => @@s3_options[:access_key_id],
          :secret_access_key => @@s3_options[:secret_access_key]
        }
        options[:endpoint] = self.endpoint unless self.endpoint.nil?
        options[:region] = self.region unless self.region.nil?
        @conn = Aws::S3::Resource.new(options)
      end

      def conn
        @@conn || establish_connection
      end

      def bucket
        load_options unless @@s3_options[:bucket]
        @@s3_options[:bucket]
      end

      def create_bucket
        bucket = self.conn.bucket(self.bucket)
        self.conn.bucket.create(self.bucket) unless bucket.exists?
      end

      def folder
        str = @@s3_options[:folder]
        if str.present?
          str.match(/\S+\//) ? str : "#{str}/"
        else
          ''
        end
      end

      def endpoint
        @@s3_options[:endpoint]
      end

      def expires
        @@s3_options[:expires]
      end

      def private?
        @@s3_options[:private]
      end

      def proxy?
        @@s3_options[:proxy]
      end

      def region
        @@s3_options[:region]
      end

      def thumb_folder
        str = @@s3_options[:thumb_folder]
        if str.present?
          str.match(/\S+\//) ? str : "#{str}/"
        else
          'tmp/'
        end
      end

      def object(filename, target_folder = self.folder)
        bucket = self.conn.bucket(self.bucket)
        bucket.object(target_folder + filename)
      end

      def put(disk_filename, original_filename, data, content_type = 'application/octet-stream', target_folder = self.folder)
        object = self.object(disk_filename, target_folder)
        options = {}
        options[:body] = data
        options[:acl] = :public_read unless self.private?
        options[:content_type] = content_type if content_type
        options[:content_disposition] = "inline; filename=#{ERB::Util.url_encode(original_filename)}"
        object.put(options)
      end

      def delete(filename, target_folder = self.folder)
        object = self.object(filename, target_folder)
        object.delete
      end

      def object_url(filename, target_folder = self.folder)
        object = self.object(filename, target_folder)
        if self.private?
          options = {}
          options[:expires_in] = self.expires unless self.expires.nil?
          object.presigned_url(:get, **options).to_s
        else
          object.public_url.to_s
        end
      end

      def get(filename, target_folder = self.folder)
        object = self.object(filename, target_folder)
        object.read
      end
    end
  end
end
