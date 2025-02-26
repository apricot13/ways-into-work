  require 'wordpress_api.rb'

class Advisor::ApplicationsController < Advisor::BaseController
  include CourseApplicationHelper
  include WordpressApi

  before_action :set_application, only: [:show, :dismiss]
  before_action :get_wordpress_object, only: [:show]

  def index
    params[:type] ||= "course" # default to course applications

    if params[:type] == "course"
      @applications = CourseApplication.all

      intake_ids = @applications.map{ |application| application.wordpress_object_id }
      if intake_ids.any?
        @intakes = get_intakes(intake_ids)
        @filter_options = @intakes.group_by { |intake| intake_course_title(intake) }
      end

      @applications_awaiting_review = CourseApplication.awaiting_review
      @applications_reviewed = CourseApplication.reviewed
      @applications_reviewed_page = @applications_reviewed.page params[:page]
    elsif params[:type] == "vacancy"
      @applications = VacancyApplication.all

      vacancy_ids = @applications.map{ |application| application.wordpress_object_id }
      if vacancy_ids.any?
        @vacancies = get_vacancies(vacancy_ids)
        @filter_options = @vacancies.group_by { |vacancy| vacancy["title"]["rendered"] }
      end

      @applications_awaiting_review = VacancyApplication.awaiting_review
      @applications_reviewed = VacancyApplication.reviewed
      @applications_reviewed_page = @applications_reviewed.page params[:page]
    end

    if params[:course_intake_select].present?
      @applications_awaiting_review = CourseApplication.awaiting_review.where(wordpress_object_id: params[:course_intake_select])
      @applications_reviewed = CourseApplication.reviewed.where(wordpress_object_id: params[:course_intake_select])
      @applications_reviewed_page = @applications_reviewed.page params[:page]
    elsif params[:vacancy_select].present?
      @vacancy =  @vacancies.select{|vacancy| vacancy["id"] == params[:vacancy_select].to_i }.try(:first)
      @applications_awaiting_review = VacancyApplication.awaiting_review.where(wordpress_object_id: params[:vacancy_select])
      @applications_reviewed = VacancyApplication.reviewed.where(wordpress_object_id: params[:vacancy_select])
      @applications_reviewed_page = @applications_reviewed.page params[:page]
    end

    respond_to do |format|
      format.html
      if params[:type] == "course"
        format.csv { send_data @applications.to_csv(@intakes), filename: "coure-applications-#{Date.today}.csv" }
      elsif params[:type] == "vacancy"
        format.csv { send_data @applications.to_csv(@vacancies), filename: "vacancy-applications-#{Date.today}.csv" }
      end
    end

  end

  def show
    session[:return_to] = request.referrer
    @possible_client = Client.with_email(@application.email).first
    @file_upload = FileUpload.find_by(id: @application.file_upload_id)
  end

  def dismiss
    @application.dismissed = true
    @application.save
    flash[:success] = "Application dismissed"
    redirect_to advisor_applications_path(type: @application.type_as_parameter)
  end

  def dismiss_all
    if params[:type] == "course"
      if params[:wordpress_object_id]
        CourseApplication.where(wordpress_object_id: params[:wordpress_object_id]).awaiting_review.update_all(dismissed: true)
      else
        CourseApplication.awaiting_review.update_all(dismissed: true)
      end
    elsif params[:type] == "vacancy"
      if params[:wordpress_object_id]
        VacancyApplication.where(wordpress_object_id: params[:wordpress_object_id]).awaiting_review.update_all(dismissed: true)
      else
        VacancyApplication.awaiting_review.update_all(dismissed: true)
      end
    end
    flash[:notice] = "All applications have been dismissed"
    redirect_to advisor_applications_path(type: params[:type])
  end

  def for_client
    @client = Client.find(params[:client_id])
    @applications = Application.where(email: @client.email)
    intake_ids = @applications.where(type: 'CourseApplication').pluck(:wordpress_object_id)
    if intake_ids.size > 0
      @intakes = get_intakes(intake_ids)
    end
    vacancy_ids = @applications.where(type: 'VacancyApplication').pluck(:wordpress_object_id)
    if vacancy_ids.size > 0
      @vacancies = get_vacancies(vacancy_ids)
    end
    render 'for_client'
  end

  def set_application
    @application = Application.find(params[:id])
  end

  def get_wordpress_object
    if @application.type == 'CourseApplication'
      @intake = get_object_by_id('CourseApplication', @application.wordpress_object_id)
    elsif @application.type == 'VacancyApplication'
      @vacancy = get_object_by_id('VacancyApplication', @application.wordpress_object_id)
    end
  end

end
