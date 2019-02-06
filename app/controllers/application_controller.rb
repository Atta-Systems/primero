# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

class ApplicationController < ActionController::Base
  before_filter :authorize_profiler

  helper :all
  helper_method :current_user_name, :current_user, :current_user_full_name, :current_session, :logged_in?

  include AgencyLogos
  include Security::Authentication

  before_filter :extend_session_lifetime
  before_filter :check_authentication
  before_filter :set_locale

  before_action :forms_path_menu

  rescue_from( AuthenticationFailure ) { |e| handle_authentication_failure(e) }
  rescue_from( AuthorizationFailure ) { |e| handle_authorization_failure(e) }
  rescue_from( ErrorResponse ) { |e| render_error_response(e) }
  rescue_from CanCan::AccessDenied do |exception|
    if request.format == "application/json"
      render :json => "unauthorized", :status => 403
    else
      render :file => "#{Rails.root}/public/403", :status => 403, :layout => false, :formats => [:html]
    end
  end

  def extend_session_lifetime
    request.env[Rack::Session::Abstract::ENV_SESSION_OPTIONS_KEY][:expire_after] = 1.week if request.format.json?
  end

  def authorize_profiler
    Rack::MiniProfiler.authorize_request if ENV['PROFILE']
  end

  def handle_authentication_failure(auth_failure)
    respond_to do |format|
      format.html { redirect_to(:login) }
      format.any(:xml,:json) { render_error_response ErrorResponse.unauthorized(I18n.t("session.invalid_token")) }
    end
  end

  def handle_authorization_failure(authorization_failure)
    respond_to do |format|
      format.any { render_error_response ErrorResponse.new(403, authorization_failure.message) }
    end
  end

  def handle_device_blacklisted(session)
    render(:status => 403, :json => session.imei)
  end

  def render_error_response(ex)
    respond_to do |format|
      format.html do
        render :template => "shared/error_response",:status => ex.status_code, :locals => { :exception => ex }
      end
      format.any(:xml,:json) do
        render :text => nil, :status => ex.status_code
      end
    end
  end

  def name
    self.class.to_s.gsub("Controller", "")
  end

  def set_locale
    if logged_in?
      I18n.locale = (current_user.locale || I18n.default_locale)
      Primero::Translations.set_fallbacks
    end
  end

  def clean_params(param)
    param.reject{|value| value.blank?}
  end

  def encrypt_data_to_zip(data, data_filename, password)
    #TODO: The encrypted zipfile is corrupt when data is "". Fix it.
    enc_filename = CleansingTmpDir.temp_file_name

    ZipRuby::Archive.open(enc_filename, ZipRuby::CREATE) do |ar|
      ar.add_or_replace_buffer data_filename, data
      if password
        ar.encrypt password
      end
    end

    send_file enc_filename, :filename => "#{data_filename}.zip", :disposition => "inline", :type => 'application/zip'
  end

  def filter_params_array_duplicates
    controller = params["controller"].singularize
    if params[controller]
      params[controller].each do |key, value|
        if value.kind_of?(Array)
          params[controller][key] = value.uniq
        end
      end
    end
    params
  end

  def redirect_back_or_default(default = root_path, options = {})
    redirect_to (request.referer.present? ? :back : default), options
  end

  def forms_path_menu
    @forms_path_menu = if can? :manage, FormSection
                         form_sections_path
                       elsif can? :manage, Lookup
                         lookups_path
                       elsif can? :manage, Location
                         locations_path
                       else
                         nil
                       end

  end
  class << self
    attr_accessor :model_class
  end

  def model_class
    self.class.model_class
  end
end
