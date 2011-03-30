class HomeController < ApplicationController
  include ApplicationHelper

  def index
    @session_key = cookies[:session_key]

    unless @session_key 
      cookies[:session_key] = random_string
      redirect_to :action => 'index'
    else
      policy  = "allow 'self' *.google-analytics.com ;"
      #policy += "script-src 'self' http://*.google-analytics.com;"
      #policy += "options inline-script eval-script;"
      policy += "report-uri /violations"

      response.headers["X-Content-Security-Policy"] = policy
    end
  end

  def set_violations
    def add_message(message)
      REDIS.lpush @key, CGI::escapeHTML(message)
      puts "\nViolation: #{message}\n\n"
    end

    report   = params["csp-report"] or return with_error
    violated = report["violated-directive"]
    blocked  = report["blocked-uri"]
    @key     = report['request-headers'].match(/session_key=([a-zA-Z0-9]+)/) ? $1 : nil
    return with_error unless @key

    if blocked =~ /dinkevich.com\/csp_test.js/
      add_message "OK CSP test successful. Waiting for possible violations"

    elsif violated =~ /inline script base restriction/
      unless report['script-sample'] =~ /Bad\(\'Embedded Javascript is.../
        add_message "Unexpected inline javascript: ( #{report['script-sample']} )"
      end

    else
      add_message "Unexpected JavaScript: #{blocked}"

    end

    puts "\n\nViolation\n================\n#{params.to_yaml}\n\n"
    puts "Key = #{@key}\n\n"

    render :text => 'All is good'
  end

  def get_violations
    key = params[:key] or return with_error

    # Get list
    data = REDIS.lrange key, 0, -1

    # Clear list
    REDIS.ltrim key, 1, 0

    render :json => { :update_rate => 1000000, :messages => data }.to_json
  end
end
