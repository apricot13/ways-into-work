class Advisor::CourseApplicationsController < Advisor::BaseController
  include CourseApplicationHelper

  before_action :set_course_application, only: [:show, :update]
  before_action :get_intake_and_course, only: [:show, :update]

  def index
    @course_applications = CourseApplication.all

    intake_ids = @course_applications.map{ |application| application.intake_id }
    response = HTTParty.get("https://hackney-works-staging.hackney.gov.uk/wp-json/wp/v2/intake?per_page=100&include=#{intake_ids.join(",")}")
    @intakes = response.parsed_response

    @filter_options = @intakes.group_by { |intake| intake["acf"]["parent_course"]["post_title"] }

    @course_applications_awaiting_review = CourseApplication.awaiting_review
    @course_applications_reviewed = CourseApplication.reviewed

    if params[:course_intake_select].present?
      @course_applications_awaiting_review = CourseApplication.awaiting_review.where(intake_id: params[:course_intake_select])
      @course_applications_reviewed = CourseApplication.reviewed.where(intake_id: params[:course_intake_select])
    end

  end

  def show
  end

  def update
    previous_status = @course_application.status
    if @course_application.update_attributes(course_application_params)
      flash[:success] = "Course application updated"

      if (@course_application.status == "accepted") && (previous_status == nil)
        CourseApplicationMailer.course_application_accepted(@course_application).deliver_now
      elsif (@course_application.status == "unsuccessful") && (previous_status == nil)
        CourseApplicationMailer.course_application_unsuccessful(@course_application).deliver_now
      end
      redirect_to advisor_course_applications_path
    else
      render 'show'
    end
  end

  def set_course_application
    @course_application = CourseApplication.find(params[:id])
  end

  def get_intake_and_course
    response = HTTParty.get("https://hackney-works-staging.hackney.gov.uk/wp-json/wp/v2/intake/#{@course_application.intake_id}")
    @intake = response.parsed_response
    @course = @intake["acf"]["parent_course"]
  end

  def course_application_params
    params.require(:course_application).permit(
      :first_name, 
      :last_name, 
      :phone_number, 
      :email, 
      :intake_id, 
      :status, 
      :feedback
    )
  end
end