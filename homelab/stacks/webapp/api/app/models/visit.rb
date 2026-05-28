require "net/http"
require "json"

class Visit < ApplicationRecord
  def fetch_geo!
    return if ip_address.blank?
    return if ip_address.start_with?("127.", "10.", "172.", "192.168.")

    uri = URI("http://ip-api.com/json/#{ip_address}?fields=country,regionName,city,org")
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      update_columns(
        country: data["country"],
        region:  data["regionName"],
        city:    data["city"],
        org:     data["org"]
      )
    end
  rescue => e
    Rails.logger.error "Geo lookup failed for #{ip_address}: #{e.message}"
  end
end
