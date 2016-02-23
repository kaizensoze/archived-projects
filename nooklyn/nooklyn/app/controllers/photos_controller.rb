class PhotosController < ApplicationController
  load_and_authorize_resource

  # GET /photos
  # GET /photos.json
  def index
    @photos = LocationPhoto.page(params[:page]).per(24)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @photos.map{|upload| upload.to_jq_upload } }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    @listing = Listing.find(params[:photo][:listing_id])
    # @photo = @listing.photos.create(photos_param)

    respond_to do |format|
      if @photo.save
        format.html {
          render json: [@photo.to_jq_upload].to_json,
          content_type: 'text/html',
          layout: false
        }
        format.json { render json: {files: [@photo.to_jq_upload]}, status: :created, location: @photo }
      else
        format.html { render action: "new" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update_attributes(photo_params)
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

    def mark_as_featured
      @photo = Photo.find(params[:id])
      @photo.featured = true
      @photo.save
      respond_to do |format|
        format.html { redirect_to photos_path, notice: 'Photo is now featured.' }
      end
    end

    def mark_as_not_featured
      @photo = Photo.find(params[:id])
      @photo.featured = false
      @photo.save
      respond_to do |format|
        format.html { redirect_to photos_path, notice: 'Photo is no longer featured.' }
      end
    end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to manage_photos_listing_path(@photo.listing) }
      format.json { head :no_content }
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:image, :listing_id)
  end
end
