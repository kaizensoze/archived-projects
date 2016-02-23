module Matrix
  class DepositAttachmentsController < MatrixBaseController
    before_action :set_deposit_attachment, only: [:show, :edit, :update, :destroy]

    def create
      @deposit = Deposit.find(params[:deposit_id])
      @document = @deposit.documents.build(deposit_attachment_params)

      if @document.save
        redirect_to matrix_deposit_path(@deposit), flash: { success: "Voucher Attachment successfully uploaded." }
      else
        flash[:error] = 'Attachment was not able to be uploaded.'
        redirect_to @deposit
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_deposit_attachment
        @deposit_attachment = DepositAttachment.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def deposit_attachment_params
        params.require(:deposit_attachment).permit(:agent_id, :deposit_id, :attachment)
      end
  end
end
