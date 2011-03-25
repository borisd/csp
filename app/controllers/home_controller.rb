class HomeController < ApplicationController
  include ApplicationHelper

  def index
    @session_key = random_string

    policy  = "allow 'self' #{@session_key}.session.key;"
    #policy += "options inline-script eval-script;"
    policy += "report-uri /violations"

    response.headers["X-Content-Security-Policy"] = policy
  end

  def set_violations
    report   = params["csp-report"]
    violated = report["violated-directive"]
    key      = violated.include?('session.key') ? violated.split(' ')[-1].split('.')[0] : nil

    message = "Got violation: #{report["blocked-uri"]} - (#{violated})"

    REDIS.lpush key, message if key

    render :text => 'All is good'
  end

  def get_violations
    key = params[:key] or return
    data = REDIS.lrange key, 0, -1
    REDIS.ltrim key, 1, 0 # Clear the list
    render :json => { :update_rate => 5000, :messages => data }.to_json
  end
end
