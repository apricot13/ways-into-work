class CourseApplicationMailer < ApplicationMailer
  include CourseApplicationHelper

  def confirm_application(course_application)
    @course_application = course_application

    @intake = HTTParty.get("#{ENV['WORDPRESS_DOMAIN']}/wp-json/wp/v2/intake/#{@course_application.intake_id}").parsed_response

    mail(
      to: @course_application.email,
      subject: I18n.t('course_applications.mail.subject.confirm_course_application')
    )
  end

  def course_application_accepted(course_application)
    @course_application = course_application

    @intake = HTTParty.get("#{ENV['WORDPRESS_DOMAIN']}/wp-json/wp/v2/intake/#{@course_application.intake_id}").parsed_response

    mail(
      to: @course_application.email,
      subject: I18n.t('course_applications.mail.subject.course_application_accepted')
    )
  end

  def course_application_unsuccessful(course_application)
    @course_application = course_application

    @intake = HTTParty.get("#{ENV['WORDPRESS_DOMAIN']}/wp-json/wp/v2/intake/#{@course_application.intake_id}").parsed_response

    mail(
      to: @course_application.email,
      subject: I18n.t('course_applications.mail.subject.course_application_unsuccessful')
    )
  end
end
