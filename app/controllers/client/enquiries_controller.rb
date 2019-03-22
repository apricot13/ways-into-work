class Client::EnquiriesController < Client::BaseController

  def new
    @enquiry = Enquiry.new
    @enquiry.opportunity_id = params[:opportunity_id]
    @enquiry.opportunity_type = params[:opportunity_type]
  end

  def create
    @enquiry = Enquiry.new(enquiry_params)
    @enquiry.client_id = current_client.id
    if @enquiry.save
      flash[:alert] = 'Your enquiry was sent successfully'
      redirect_to client_enquiry_confirm_path
    else
      render 'new'
    end
  end

  def enquiry_params
    params.require(:enquiry).permit(:client_id, :opportunity_id, :opportunity_type, :supporting_statement)
  end

end
