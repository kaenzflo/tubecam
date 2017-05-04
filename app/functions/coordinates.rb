# TODO Insert here source of code (MIT license)

class Coordinates

  @round_value = 2

  # Convert WGS lat/long ( dec) to CH y
  def self.wgs_to_ch_y(lng, lat)

    # Convert decimal degrees to sexagesimal seconds
    lat = dec_to_sex(lat)
    lng = Coordinates.dec_to_sex(lng)

    # Auxiliary values (% Bern)
    lat_aux = (lat - 169028.66)/10000
    lng_aux = (lng - 26782.5)/10000

    # Process Y
    y  = 600072.37
    y += 211455.93 * lng_aux
    y -=  10938.51 * lng_aux * lat_aux
    y -=      0.36 * lng_aux * (lat_aux ** 2)
    y -=     44.54 * (lng_aux ** 3)

    return y.round(@round_value)

  end

  # Convert WGS lat/long ( dec) to CH x
  def self.wgs2_to_ch_x(lng, lat)

    # Convert decimal degrees to sexagesimal seconds
    lat = Coordinates.dec_to_sex(lat)
    lng = Coordinates.dec_to_sex(lng)

    # Auxiliary values (% Bern)
    lat_aux = (lat - 169028.66)/10000;
    lng_aux = (lng - 26782.5)/10000;

    # Process X
    x  = 200147.07
    x += 308807.95 * lat_aux
    x +=   3745.25 * (lng_aux ** 2)
    x +=     76.63 * (lat_aux ** 2)
    x -=    194.56 * (lng_aux ** 2) * lat_aux
    x +=    119.79 * (lat_aux ** 3)

    return x.round(@round_value)

  end

  # Convert CH y/x to WGS lat
  def self.ch_to_wgs_lat(y, x)

    # Converts military to civil and  to unit = 1000km
    # Auxiliary values (% Bern)
    y_aux = (y - 600000)/1000000
    x_aux = (x - 200000)/1000000

    # Process lat
    lat  = 16.9023892
    lat +=  3.238272 * x_aux
    lat -=  0.270978 * Math.pow(y_aux, 2)
    lat -=  0.002528 * Math.pow(x_aux, 2)
    lat -=  0.0447   * Math.pow(y_aux, 2) * x_aux
    lat -=  0.0140   * Math.pow(x_aux, 3)

    # Unit 10000" to 1 " and converts seconds to degrees (dec)
    lat = lat * 100 / 36

    return lat

  end

  # Convert CH y/x to WGS long
  def self.ch_to_wgs_lng(y, x)

    # Converts military to civil and  to unit = 1000km
    # Auxiliary values (% Bern)
    y_aux = (y - 600000) / 1000000
    x_aux = (x - 200000) / 1000000

    # Process long
    lng  = 2.6779094
    lng += 4.728982 * y_aux
    lng += 0.791484 * y_aux * x_aux
    lng += 0.1306   * y_aux * Math.pow(x_aux, 2)
    lng -= 0.0436   * Math.pow(y_aux, 3)

    # Unit 10000" to 1 " and converts seconds to degrees (dec)
    lng = lng * 100 / 36

    return lng

  end


  # Convert angle in decimal degrees to sexagesimal seconds

  def self.dec_to_sex(angle)
    # Extract DMS
    deg = angle
    min = ((angle-deg) * 60)
    sec = (((angle-deg) * 60) - min) * 60

    # Result sexagesimal seconds
    return sec + min * 60.0 + deg * 3600.0

  end
end