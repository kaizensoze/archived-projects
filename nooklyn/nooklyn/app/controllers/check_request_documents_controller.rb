class CheckRequestDocumentsController < ApplicationController

  def create
    @check_request = CheckRequest.find(params[:check_request_id])
    @document = @check_request.documents.build(check_request_document_params)

    if @document.save
      redirect_to @check_request, flash: { success: "Voucher Attachment successfully uploaded." }
    else
      flash[:error] = 'Attachment was not able to be uploaded.'
      redirect_to @check_request
    end
  end

  private

  def check_request_document_params
    params.require(:check_request_document)
          .permit(:attachment)
  end


end
