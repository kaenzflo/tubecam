namespace :local_laptop do
  desc 'Heroku scheduler add-on'
  task imageproc: :environment do
    path = '/home/florian/Schreibtisch/images/'
    # resource_url = path + filename
    # image = File.new(path + 'image000001.jpg')
    ftp = Net::FTP.new(ENV['FTP_HOST_NAME'])
    ftp.login(ENV['FTP_USER_NAME'], ENV['FTP_PASSWORD'])
    remote_files = ftp.nlst('/*/*/*/*')
    media = Medium.all
    imported_files = []
    media.each do |medium|
          tubecam = TubecamDevice.find(medium.tubecam_device_id)
          serial_number = tubecam.serialnumber.tr(':', '')
          imported_files.append('TEST_Tubecam_' +
          serial_number + '/' +
          medium.original_path + '/' +
          medium.original_filename)
    end

    imported_files.append('/TEST_Tubecam_SN00010/2017/02/28/SN00010_2017_02_28_17_35_56_S0023I24.jpg')

    p imported_files



    # imported_files = ['SN00010_2017_02_28_17_35_56_S0023I24.jpg']

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

    new_remote_files = validated_remote_files - imported_files
    p new_remote_files.size

     # media.each do |medium|
    #   imported_files.add = media.original_filename
    # end

    # ftp = Net::FTP.new(ENV['FTP_HOST_NAME'])
    # begin
    #   ftp.login(ENV['FTP_USER_NAME'], ENV['FTP_PASSWORD'])
    #   files = ftp.nlst('/*/*/*/*')
    #   puts files[2].inspect
    #   file_url = files[2].inspect
    #   # files.each do |file_url|
    #   #   if file_url =~ %r{(?=^/Tubecam_SN[\d]{5}.*I[\d]{2}\.[a-zA-Z]{3}$)}
    #   #     puts file_url.inspect
    #   #   end
    #   # end
    #   @image = ftp.getbinaryfile(file_url, nil, 1024)
    # rescue => e
    #   ftp.close
    #   Rails.logger.error e.message
    # end
    # ftp.close

    # if @image.nil?
    # else
      # begin
      #   S3.host = ENV['S3_HOST_NAME']
      #   s3service = S3::Service.new(access_key_id: ENV['S3_ACCESS_KEY'],
      #                               secret_access_key: ENV['S3_SECRET_KEY'],
      #                               use_ssl: true)
      #
      #   filename_hash = Digest::SHA256.hexdigest filename
      #   upload_bucket = s3service.buckets.find('tubecam')
      #   new_object = upload_bucket.objects.build(filename_hash + '.jpg')
      #   new_object.content = @image
      #   new_object.acl = :public_read
      #   new_object.save
      #
      #   MiniMagick.logger.level = Logger::DEBUG
      #   mm_image = MiniMagick::Image.read(@image)
      #   mm_image.resize('100x100')
      #   new_object = upload_bucket.objects.build('thumbnails/' +
      #                                                filename_hash +
      #                                                '.jpg')
      #   new_object.content = mm_image.to_blob
      #   new_object.acl = :public_read
      #   new_object.save
      # rescue => e
      #   logger.error e.message
      # end
    # end

  end

end
