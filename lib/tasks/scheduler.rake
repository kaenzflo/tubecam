require 'net/ftp'
require 'mini_magick'
require 'mini_exiftool_vendored'
require 'digest'

# Folder name prefix; Leave blank if not testing FTP server
TEST_PREFIX = ''

# Regular expression to validate media elements on FTP server
regex_string = '(?=^/Tubecam_SN[\d]{5}.*I[\d]{2}\.[a-zA-Z]{3}$)'
VALIDATION_REGEX = regex_string.insert(5, TEST_PREFIX)

# Initializes FTP service
def init_ftp_service
  ftp = Net::FTP.new(ENV['FTP_HOST_NAME'])
  ftp.login(ENV['FTP_USER_NAME'], ENV['FTP_PASSWORD'])
  ftp.passive = true
  ftp
end

# Initializes S3 service
def init_s3_service
  S3.host = ENV['S3_HOST_NAME']
  s3service = S3::Service.new(access_key_id: ENV['S3_ACCESS_KEY'],
                              secret_access_key: ENV['S3_SECRET_KEY'],
                              use_ssl: true)
  upload_bucket = s3service.buckets.find(ENV['S3_BUCKET_NAME'])
end

# Lists already imported media files
def list_already_imported_media
  media = Medium.all
  imported_files = []
  media.each do |medium|
    imported_files.append(medium.original_path + medium.original_filename)
  end
  imported_files
end

# Lists remote media files
def fetch_remote_file_listing
  begin
    ftp = init_ftp_service
    remote_files = ftp.nlst('/*/*/*/*')
  rescue => e
    ftp.close
    Rails.logger.error e.message
  end
  ftp.close
  remote_files
end

# Validates remote media files listing
def validate_remote_media(remote_files)
  validated_remote_files = []
  remote_files.each do |line|
    if line =~ /#{VALIDATION_REGEX}/
      validated_remote_files.append(line)
    end
  end
  validated_remote_files
end

# New remote files to be imported
def new_remote_media_files(imported_files, validated_remote_files)
  new_remote_files = validated_remote_files - imported_files
  puts "#{new_remote_files.size.to_s} new, #{validated_remote_files.size.to_s} validated and #{imported_files.size.to_s} already existing elements"
  new_remote_files
end

# Extracts exif data from new medium
def extract_exif_data(file_url, new_medium)
  original_filename = file_url[(TEST_PREFIX.length + 28)..-1]
  original_path = file_url[0..(27 + TEST_PREFIX.length)]
  new_medium_exif = MiniExiftool.new(StringIO.new(new_medium), numerical: true)
  json_data = new_medium_exif.to_json
  exif_json = ActiveSupport::JSON.decode(json_data)
  filename_hash = Digest::SHA256.hexdigest original_filename
  filename_hash += '.' + original_filename.gsub(/.*\./, '')
  mediatype = exif_json['MIMEType']
  tubecam_sn = exif_json['SerialNumber']
  datetime = exif_json['DateTimeOriginal']
  longitude = exif_json['GPSLongitude']
  latitude = exif_json['GPSLatitude']
  sequence_no = original_filename[29..32]
  frame = original_filename[34..35]
  return datetime, filename_hash, frame, json_data, latitude,
      longitude, mediatype, original_filename, original_path,
      sequence_no, tubecam_sn
end

# Updates tubecam data
def update_tubecam_data(ch1903Coordinates, datetime, geodetic_datum, tubecam_device)
  if tubecam_device.last_activity.nil? || tubecam_device.last_activity < datetime
    tubecam_device.geodetic_datum = geodetic_datum
    tubecam_device.longitude = ch1903Coordinates['longitude']
    tubecam_device.latitude = ch1903Coordinates['latitude']
    tubecam_device.last_activity = datetime
    tubecam_device.save
  end
end

# Saves sequence data
def save_sequence(ch1903Coordinates, datetime, geodetic_datum, sequence_no, tubecam_device_id)
  sequence = Sequence.where(tubecam_device_id: tubecam_device_id,
                            sequence_no: sequence_no).first_or_create
  sequence.datetime = datetime
  sequence.longitude = ch1903Coordinates['longitude']
  sequence.latitude = ch1903Coordinates['latitude']
  sequence.geodetic_datum = geodetic_datum
  sequence.save
  sequence
end

# Saves medium data
def save_medium(ch1903Coordinates, datetime, filename_hash, frame, geodetic_datum, json_data,
                mediatype, original_filename, original_path, sequence)
  Medium.create(sequence_id: sequence.id,
                original_path: original_path, original_filename: original_filename,
                filename_hash: filename_hash, mediatype: mediatype,
                datetime: datetime, longitude: ch1903Coordinates['longitude'],
                latitude: ch1903Coordinates['latitude'], geodetic_datum: geodetic_datum,
                frame: frame, exifdata: json_data, deleted: false)
end

# Uploads medium to S3 object storage
def upload_medium_to_s3(filename_hash, new_medium, upload_bucket)
  new_object = upload_bucket.objects.build(filename_hash)
  new_object.content = new_medium
  new_object.acl = :public_read
  new_object.save
end

# Generates thumbnail
def generate_thumbnail(new_medium)
  resized_new_medium = MiniMagick::Image.read(new_medium)
  resized_new_medium.resize('200x200')
  resized_new_medium
end

# Converts geodetic datum from WGS-84 to CH1903
def convert_wgs84_to_ch1903(latitude, longitude)
  ch1903Coordinates = Coordinates.wgs_to_ch(longitude, latitude)
  geodetic_datum = 'CH1903'
  return ch1903Coordinates, geodetic_datum
end

# Fetches new remote medium and upload medium to S3 object storage
def fetch_and_upload_new_medium(file_url, ftp, upload_bucket)
  new_medium = ftp.getbinaryfile(file_url, nil, 1024)
  datetime, filename_hash, frame, json_data, latitude,
      longitude, mediatype, original_filename, original_path,
      sequence_no, tubecam_sn = extract_exif_data(file_url, new_medium)

  tubecam_device = TubecamDevice.find_by(serialnumber: tubecam_sn)
  if tubecam_device.nil?
    puts "Skip import of #{file_url}: Tubecam #{tubecam_sn} doesn't exist"
  else
    puts "Processing #{file_url}..."
    tubecam_device_id = tubecam_device.id
    ch1903Coordinates, geodetic_datum = convert_wgs84_to_ch1903(latitude, longitude)

    update_tubecam_data(ch1903Coordinates, datetime, geodetic_datum, tubecam_device)
    sequence = save_sequence(ch1903Coordinates, datetime, geodetic_datum,
                             sequence_no, tubecam_device_id)
    save_medium(ch1903Coordinates, datetime, filename_hash, frame, geodetic_datum,
                json_data, mediatype, original_filename, original_path, sequence)

    upload_medium_to_s3(filename_hash, new_medium, upload_bucket)
    resized_new_medium = generate_thumbnail(new_medium)
    upload_medium_to_s3('thumbnails/' + filename_hash,
                        resized_new_medium.to_blob, upload_bucket)
  end
end

namespace :heroku do
  desc 'Heroku scheduler add-on'
  task crawlftp: :environment do
    imported_files = list_already_imported_media
    remote_files = fetch_remote_file_listing
    validated_remote_files = validate_remote_media(remote_files)
    new_remote_files = new_remote_media_files(imported_files, validated_remote_files)
    begin
      ftp = init_ftp_service
      upload_bucket = init_s3_service
      new_remote_files.each do |file_url|
        fetch_and_upload_new_medium(file_url, ftp, upload_bucket)
      end
    rescue => e
      ftp.close
      Rails.logger.error e.message
    end
    ftp.close
  end

end
