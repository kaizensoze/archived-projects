class LocationPhotosController < ApplicationController
  load_and_authorize_resource

  # GET /location_photos
  # GET /location_photos.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @location_photos.map{|upload| upload.to_jq_upload } }
    end
  end

  # GET /location_photos/1
  # GET /location_photos/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /location_photos/1/edit
  def edit
  end

  # POST /location_photos
  # POST /location_photos.json
  def create
    @location = Location.find(params[:location_photo][:location_id])
    @location_photo = @location.photos.create(location_photo_params)

    respond_to do |format|
      if @location_photo.save
        format.html {
          render json: [@location_photo.to_jq_upload].to_json,
          content_type: 'text/html',
          layout: false
        }
        format.json { render json: {files: [@location_photo.to_jq_upload]}, status: :created, location: @location_photo }
      else
        format.html { render action: "new" }
        format.json { render json: @location_photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /location_photos/1
  # PUT /location_photos/1.json
  def update
    respond_to do |format|
      if @location_photo.update_attributes(photo_params)
        format.html { redirect_to @location_photo, notice: 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @location_photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /location_photos/1
  # DELETE /location_photos/1.json
  def destroy
    @location_photo.destroy

    respond_to do |format|
      format.html { redirect_to manage_photos_listing_path(@location_photo.listing) }
      format.json { head :no_content }
    end
  end

  private

  def location_photo_params
    params.require(:location_photo).permit(:image, :location_id)
  end
end
