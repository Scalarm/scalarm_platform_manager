require "yaml"

class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def authenticate
    config = YAML.load_file(File.join(Rails.root, "config", "platform_manager_config.yml"))

    authenticate_or_request_with_http_basic do |username, password|
      username == config["login"] && password == config["password"]
    end
  end
end
