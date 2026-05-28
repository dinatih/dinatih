class Api::VisitsController < ApplicationController
  def create
    ip = request.env["HTTP_CF_CONNECTING_IP"] || request.remote_ip

    visit = Visit.create!(
      ip_address:      ip,
      user_agent:      request.user_agent,
      referer:         request.referer,
      path:            params[:path] || "/",
      accept_language: request.env["HTTP_ACCEPT_LANGUAGE"],
      browser:         parse_browser(request.user_agent),
      os:              parse_os(request.user_agent),
      device_type:     parse_device(request.user_agent)
    )

    Thread.new { visit.fetch_geo! }

    render json: { ok: true }, status: :created
  end

  def stats
    token = request.env["HTTP_X_STATS_TOKEN"] || params[:token]
    return render json: { error: "unauthorized" }, status: :unauthorized unless token == ENV["STATS_TOKEN"]

    render json: {
      total:      Visit.count,
      today:      Visit.where("created_at > ?", Time.current.beginning_of_day).count,
      this_week:  Visit.where("created_at > ?", 1.week.ago).count,
      this_month: Visit.where("created_at > ?", 1.month.ago).count,
      by_country: Visit.group(:country).order("count_all desc").limit(15).count,
      by_city:    Visit.group(:city).order("count_all desc").limit(15).count,
      by_org:     Visit.group(:org).order("count_all desc").limit(20).count,
      by_browser: Visit.group(:browser).order("count_all desc").count,
      by_device:  Visit.group(:device_type).order("count_all desc").count,
      by_os:      Visit.group(:os).order("count_all desc").count,
      by_referer: Visit.where.not(referer: [ nil, "" ]).group(:referer).order("count_all desc").limit(20).count,
      recent:     Visit.order(created_at: :desc).limit(20).as_json(
                    only: %i[ip_address country city org browser os device_type referer accept_language created_at]
                  )
    }
  end

  private

  def parse_browser(ua)
    return "Other" if ua.blank?
    return "Edge"    if ua.include?("Edg/")
    return "Chrome"  if ua.include?("Chrome") && !ua.include?("Chromium")
    return "Firefox" if ua.include?("Firefox")
    return "Safari"  if ua.include?("Safari") && !ua.include?("Chrome")
    return "Opera"   if ua.include?("OPR") || ua.include?("Opera")
    "Other"
  end

  def parse_os(ua)
    return "Other"   if ua.blank?
    return "iOS"     if ua.include?("iPhone") || ua.include?("iPad")
    return "Android" if ua.include?("Android")
    return "Windows" if ua.include?("Windows")
    return "macOS"   if ua.include?("Macintosh")
    return "Linux"   if ua.include?("Linux")
    "Other"
  end

  def parse_device(ua)
    return "Other"   if ua.blank?
    return "Mobile"  if ua.include?("iPhone") || (ua.include?("Android") && ua.include?("Mobile"))
    return "Tablet"  if ua.include?("iPad")   || (ua.include?("Android") && !ua.include?("Mobile"))
    "Desktop"
  end
end
