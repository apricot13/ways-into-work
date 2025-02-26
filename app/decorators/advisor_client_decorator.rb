class AdvisorClientDecorator < ClientDecorator
  def client_profile_header
    "#{client.name}'s Profile"
  end

  def new_file_button(label)
    h.submit_tag label, href: h.advisor_client_path(client), class: 'button is-primary'
  end

  def post_file_to
    h.advisor_client_file_uploads_path(client)
  end

  def delete_file_button(file)
    h.button_to(
      I18n.t('clients.buttons.delete'),
      h.advisor_client_file_upload_path(client_id: id, id: file.id),
      class: 'button is-primary is-small',
      method: :delete,
      data: {
        confirm: 'Are you sure you want to delete this file?'
      }
    )
  end

  def decorate_meetings_action
    client.meetings.any? ? view_meetings : arrange_meeting
  end

  def decorate_action_plan_tasks
    action_plan_tasks.ongoing.map { |t| ActionPlanTaskDecorator.decorate(t) }
  end

  private

  def meetings_link(text, link)
    h.link_to text, link, method: :get, class: 'button is-primary is-small'
  end

  def view_meetings
    meetings_link I18n.t('clients.buttons.view_meetings'), h.advisor_client_meetings_path(client)
  end

  def arrange_meeting
    meetings_link I18n.t('clients.buttons.arrange_meeting'), h.new_advisor_client_meeting_path(client)
  end
end
