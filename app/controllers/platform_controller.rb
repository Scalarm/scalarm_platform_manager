require "yaml"
require "net/http"

require "information_service"

class PlatformController < ApplicationController
  before_filter :authenticate
  before_filter :load_config

  def index
    @node_managers = NodeManager.all.sort{|a,b| a.uri <=> b.uri}
    @status_information = platform_current_status
  end

  def synchronize_with_information_service
    @information_service.list_of_node_managers.each do |node_manager_desc|
      node_manager_desc = node_manager_desc.split("---")
      manager_uri = node_manager_desc[0]
      manager_registered_at = DateTime.strptime(node_manager_desc[1])

      next if not NodeManager.find_by_uri(manager_uri).nil?

      node_manager = NodeManager.new(:uri => manager_uri, :registered_at => manager_registered_at)
      node_manager.save
    end

    redirect_to :action => :index
  end

  def install_manager
    node_manager = NodeManager.find_by_uri(params[:manager_uri].gsub("_", ".").gsub("-", ":"))
    node_manager.install(params[:manager_type], @config)

    redirect_to :action => :index
  end

  def start_manager
    node_manager = NodeManager.find_by_uri(params[:manager_uri].gsub("_", ".").gsub("-", ":"))
    node_manager.start(params[:manager_type], params[:number], @config)

    redirect_to :action => :index
  end

  def stop_manager
    node_manager = NodeManager.find_by_uri(params[:manager_uri].gsub("_", ".").gsub("-", ":"))
    node_manager.stop(params[:manager_type], params[:number], @config)

    redirect_to :action => :index
  end

  def global_install_manager
    NodeManager.all.each do |node_manager|
      node_manager.install(params[:manager_type], @config)  
    end
    
    redirect_to :action => :index
  end

  def global_start_manager
    NodeManager.all.each do |node_manager|
      node_manager.start(params[:manager_type], params[:number], @config)  
    end
    
    redirect_to :action => :index
  end

  def global_stop_manager
    NodeManager.all.each do |node_manager|
      node_manager.stop(params[:manager_type], params[:number], @config)  
    end
    
    redirect_to :action => :index
  end

  def delete_manager
    node_manager = NodeManager.find_by_uri(params[:manager_uri].gsub("_", ".").gsub("-", ":"))
    node_manager.delete

    redirect_to :action => :index
  end


  private

  def load_config
    @config = YAML::load_file File.join(Rails.root, "config", "platform_manager_config.yml")
    @information_service = InformationService.new(@config)
  end

  def platform_current_status
    status_info = {}
    status_info["node_managers_size"] = @node_managers.size

    experiment_managers_installations = 0
    experiment_managers_instances = 0

    @node_managers.each do |node_manager|
      experiment_manager_status = node_manager.manager_status("experiment", 8, @config)
      if experiment_manager_status != "not running"
        experiment_managers_installations += 1
        experiment_managers_instances += experiment_manager_status.split(" ")[0].to_i
      end

      status_info[node_manager.uri] = experiment_manager_status
    end

    status_info["experiment_managers_installations"] = experiment_managers_installations
    status_info["experiment_managers_instances"] = experiment_managers_instances

    return status_info
  end

end
