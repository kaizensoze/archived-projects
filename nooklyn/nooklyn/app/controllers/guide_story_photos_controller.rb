class GuideStoryPhotosController < ApplicationController
  load_and_authorize_resource

  # GET /guide_story_photos
  # GET /guide_story_photos.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guide_story_photos.map{|upload| upload.to_jq_upload } }
    end
  end

  # GET /guide_story_photos/1
  # GET /guide_story_photos/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @photo }
    end
  end

  # GET /guide_story_photos/1/edit
  def edit
  end

  # POST /guide_story_photos
  # POST /guide_story_photos.json
  def create
    @guide_story = GuideStory.find(params[:guide_story_photo][:guide_story_id])
    @guide_story_photo = @guide_story.photos.create(guide_story_photo_params)

    respond_to do |format|
      if @guide_story_photo.save
        format.html {
          render json: [@guide_story_photo.to_jq_upload].to_json,
          content_type: 'text/html',
          layout: false
        }
        format.json { render json: {files: [@guide_story_photo.to_jq_upload]}, status: :created, guide_story: @guide_story_photo }
      else
        format.html { render action: "new" }
        format.json { render json: @guide_story_photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /guide_story_photos/1
  # PUT /guide_story_photos/1.json
  def update
    respond_to do |format|
      if @guide_story_photo.update_attributes(guide_story_photo_params)
        format.html { redirect_to @guide_story_photo, notice: 'Photo was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @guide_story_photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guide_story_photos/1
  # DELETE /guide_story_photos/1.json
  def destroy
    @guide_story_photo.destroy

    respond_to do |format|
      format.html { redirect_to manage_photos_listing_path(@guide_story_photo.listing) }
      format.json { head :no_content }
    end
  end

  private

  def guide_story_photo_params
    params.require(:guide_story_photo).permit(:image, :guide_story_id, :caption)
  end
end
