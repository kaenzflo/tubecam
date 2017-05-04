require 'mini_magick'
require 'mini_exiftool'
require 'digest'

TEST_PREFIX = 'TEST_'

namespace :local_laptop do
  desc 'Heroku scheduler add-on'
  task imageproc: :environment do

    # List already imported media files
    media = Medium.all
    imported_files = []
    media.each do |medium|
      tubecam = TubecamDevice.find(medium.tubecam_device_id)
      serial_number = tubecam.serialnumber.tr(':', '')
      imported_files.append('/' + TEST_PREFIX + 'Tubecam_' +
                                serial_number + '/' +
                                medium.original_path + '/' +
                                medium.original_filename)
    end

    imported_files.append('/' + TEST_PREFIX + 'Tubecam_SN00010/2017/02/28/SN00010_2017_02_28_17_35_56_S0023I24.jpg')
    p imported_files

    # Get remote media files listing
    begin
      ftp = Net::FTP.new(ENV['FTP_HOST_NAME'])
      ftp.login(ENV['FTP_USER_NAME'], ENV['FTP_PASSWORD'])
      remote_files = ftp.nlst('/*/*/*/*')
    rescue => e
      ftp.close
      Rails.logger.error e.message
    end
    ftp.close

    # Validate remote media files listing
    validated_remote_files = []
    remote_files.each do |line|
      if line =~ %r{(?=^/TEST_Tubecam_SN[\d]{5}.*I[\d]{2}\.[a-zA-Z]{3}$)}
        validated_remote_files.append(line)
      end
    end

    size = validated_remote_files.size
    p size
    p validated_remote_files[size - 1].eql?('/TEST_Tubecam_SN00010/2017/02/28/SN00010_2017_02_28_17_35_56_S0023I24.jpg')
    p validated_remote_files[size - 1]
    p validated_remote_files[size - 1].length
    p validated_remote_files[size - 1].inspect
    p validated_remote_files[size - 1].inspect.length

    p validated_remote_files.instance_of? Fixnum
    p validated_remote_files.instance_of? String
    p validated_remote_files.instance_of? Array
    p validated_remote_files[size - 1].instance_of? String

    p validated_remote_files.size
    p imported_files.size

    # New remote files to be imported
    new_remote_files = validated_remote_files - imported_files
    p new_remote_files.size

    # p new_remote_files

    begin
      p 'Entering download stage...'
      ftp = Net::FTP.new(ENV['FTP_HOST_NAME'])
      ftp.login(ENV['FTP_USER_NAME'], ENV['FTP_PASSWORD'])
      S3.host = ENV['S3_HOST_NAME']
      # s3service = S3::Service.new(access_key_id: ENV['S3_ACCESS_KEY'],
      #                             secret_access_key: ENV['S3_SECRET_KEY'],
      #                             use_ssl: true)
      #
      # filename_hash = Digest::SHA256.hexdigest filename
      # upload_bucket = s3service.buckets.find(ENV['S3_BUCKET_NAME'])
      # new_remote_files.each do |file_url|
      file_url = new_remote_files[0]
      p 'Iterate...'
      new_medium = ftp.getbinaryfile(file_url, nil, 1024)
      original_filename = file_url[(TEST_PREFIX.length + 28)..-1]
      original_path = file_url[0..(27 + TEST_PREFIX.length)]
      p file_url
      p original_filename
      p original_path
      p new_medium.size

      new_medium_exif = MiniExiftool.new(StringIO.new(new_medium), numerical: true)
      json_data = new_medium_exif.to_json
      exif_json = ActiveSupport::JSON.decode(json_data)
      # p new_medium_exif.to_json
      filename_hash = Digest::SHA256.hexdigest original_filename
      filename_hash += '.' + original_filename.gsub(/.*\./, '')
      mediatype = exif_json['MIMEType']
      tubecam_sn = exif_json['SerialNumber'].tr(':', '')
      datetime = exif_json['DateTimeOriginal']
      longitude = exif_json['GPSLongitude']
      latitude = exif_json['GPSLatitude']
      sequence = original_filename[29..32]
      frame = original_filename[34..35]
      tubecam_device = TubecamDevice.find_by(serialnumber: tubecam_sn)
      tubecam_device_id = tubecam_device.id

      p filename_hash.inspect
      p mediatype.inspect
      p tubecam_sn
      p datetime
      p longitude
      p latitude
      p sequence
      p frame
      p tubecam_device_id


      # Medium.create(original_path, original_filename, filename_hash, 'image', )

        # if new_medium.nil?
        # else
        #   begin
        #     new_object = upload_bucket.objects.build(filename_hash + '.jpg')
        #     new_object.content = new_medium
        #     new_object.acl = :public_read
        #     new_object.save
        #
        #     MiniMagick.logger.level = Logger::DEBUG
        #     resized_new_medium = MiniMagick::Image.read(new_media)
        #     resized_new_medium.resize('200x200')
        #     new_object = upload_bucket.objects.build('thumbnails/' +
        #                                                  filename_hash +
        #                                                  '.jpg')
        #     new_object.content = resized_new_medium.to_blob
        #     new_object.acl = :public_read
        #     new_object.save
        #   rescue => e
        #     Rails.logger.error e.message
        #   end
        # end
        # end
    rescue => e
      ftp.close
      Rails.logger.error e.message
    end
    ftp.close

  end

end
