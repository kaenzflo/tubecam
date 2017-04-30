require 'net/ftp'

namespace :heroku do
  desc "This task is called by the Heroku scheduler add-on"
  task crawlftp: :environment do
    # # path = 'Tubecam_SN00010/2016/02/09/'
    # # filename = 'SN00010_2016_02_09_17_17_31_S0001I05.jpg'
    path = 'Tubecam_SN00028/2017/02/28/'
    filename = 'SN00028_2017_02_28_18_26_44_S0031I19.jpg'
    resource_url = path + filename
    @image = nil
    ftp = Net::FTP.new(ENV['FTP_HOST_NAME'])
    begin
      ftp.login(ENV['FTP_USER_NAME'], ENV['FTP_PASSWORD'])
      @image = ftp.getbinaryfile(resource_url, nil, 1024)
    rescue => e
      ftp.close
      logger.error e.message
    end
    ftp.close

    return unless @image.nil?
    begin
      S3.host = ENV['S3_HOST_NAME']
      s3service = S3::Service.new(access_key_id: ENV['S3_ACCESS_KEY'],
                                  secret_access_key: ENV['S3_SECRET_KEY'],
                                  use_ssl: true)

      filename_hash = Digest::SHA256.hexdigest filename
      upload_bucket = s3service.buckets.find('tubecam')
      new_object = upload_bucket.objects.build(filename_hash + '.jpg')
      new_object.content = @image
      new_object.acl = :public_read
      new_object.save
    rescue => e
      logger.error e.message
    end

  end

end