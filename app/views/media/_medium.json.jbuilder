json.extract! medium, :id, :path, :filename, :mediatype, :datetime, :longitude, :latitude, :sequence, :frame, :tubecam_device_id, :exifdata, :deleted, :created_at, :updated_at
json.url medium_url(medium, format: :json)
