require 'net/ftp'
require 'mini_magick'
require 'mini_exiftool'
require 'digest'

# Test prefix
TEST_PREFIX = 'TEST_'

namespace :heroku do
  desc 'Heroku scheduler add-on'
  task crawlftp: :environment do


    # List already imported media files
    media = Medium.all
    imported_files = []
    media.each do |medium|
      imported_files.append(medium.original_path + medium.original_filename)
    end
    p 'Imported files:'
    p imported_files.inspect
    p imported_files.size.inspect

    # Get remote media files listing
    begin
      p 'Connect to FTP-Server'
      ftp = Net::FTP.new(ENV['FTP_HOST_NAME'])
      ftp.login(ENV['FTP_USER_NAME'], ENV['FTP_PASSWORD'])
      remote_files = ftp.nlst('/TEST_Tubecam0001*/*/*/*')
    rescue => e
      ftp.close
      p 'Error reading file listing:'
      p e.message
      Rails.logger.error e.message
    end
    ftp.close

    p 'Remote files:'
    p remote_files.inspect
    # Validate remote media files listing
    validated_remote_files = []
    remote_files.each do |line|
      if line =~ %r{(?=^/TEST_Tubecam_SN[\d]{5}.*I[\d]{2}\.[a-zA-Z]{3}$)}
        validated_remote_files.append(line)
      end
    end

    p validated_remote_files.inspect

    # New remote files to be imported
    new_remote_files = validated_remote_files - imported_files
    puts new_remote_files.size.to_s + ' new, ' +
             validated_remote_files.size.to_s +
             ' validated and ' + imported_files.size.to_s +
             ' already existing elements'

    begin
      # Initialize FTP and S3 services
      ftp = Net::FTP.new(ENV['FTP_HOST_NAME'])
      ftp.login(ENV['FTP_USER_NAME'], ENV['FTP_PASSWORD'])
      # S3.host = ENV['S3_HOST_NAME']
      # s3service = S3::Service.new(access_key_id: ENV['S3_ACCESS_KEY'],
      #                             secret_access_key: ENV['S3_SECRET_KEY'],
      #                             use_ssl: true)
      # upload_bucket = s3service.buckets.find(ENV['S3_BUCKET_NAME'])
      #
      new_remote_files.each do |file_url|
      #
      p 'Processing ' + file_url + '...'
      #   # Get medium from FTP
      #   new_medium = ftp.getbinaryfile(file_url, nil, 1024)

        # # Persist medium details
        # original_filename = file_url[(TEST_PREFIX.length + 28)..-1]
        # original_path = file_url[0..(27 + TEST_PREFIX.length)]
        # new_medium_exif = MiniExiftool.new(StringIO.new(new_medium), numerical: true)
        # json_data = new_medium_exif.to_json
        # exif_json = ActiveSupport::JSON.decode(json_data)
        # filename_hash = Digest::SHA256.hexdigest original_filename
        # filename_hash += '.' + original_filename.gsub(/.*\./, '')
        # mediatype = exif_json['MIMEType']
        # tubecam_sn = exif_json['SerialNumber']
        # datetime = exif_json['DateTimeOriginal']
        # longitude = exif_json['GPSLongitude']
        # latitude = exif_json['GPSLatitude']
        # sequence_no = original_filename[29..32]
        # frame = original_filename[34..35]
        # tubecam_device = TubecamDevice.find_by(serialnumber: tubecam_sn)
        # tubecam_device_id = tubecam_device.id
        #
        # @sequence = Sequence.where(tubecam_device_id: tubecam_device_id,
        #                            sequence_no: sequence_no).first_or_create
        # Medium.create(sequence_id: @sequence.id,
        #               original_path: original_path, original_filename: original_filename,
        #               filename_hash: filename_hash, mediatype: mediatype,
        #               datetime: datetime, longitude: longitude,
        #               latitude: latitude, frame: frame,
        #               exifdata: json_data, deleted: false)
        #
        # # Upload medium
        # new_object = upload_bucket.objects.build(filename_hash)
        # new_object.content = new_medium
        # new_object.acl = :public_read
        # new_object.save
        #
        # # Generate and upload thumbnail
        # resized_new_medium = MiniMagick::Image.read(new_medium)
        # resized_new_medium.resize('200x200')
        # new_object = upload_bucket.objects.build('thumbnails/' + filename_hash)
        # new_object.content = resized_new_medium.to_blob
        # new_object.acl = :public_read
        # new_object.save
       end
    rescue => e
      ftp.close
      Rails.logger.error e.message
    end
    ftp.close

  end

end
