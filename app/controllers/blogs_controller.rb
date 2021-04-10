class BlogsController < ApplicationController
  before_action :set_blog, only: %i[show edit update destroy publish]

  layout 'user'

  # GET /blogs or /blogs.json
  def index
    @blogs = current_user.profile.blogs.all
  end

  # GET /blogs/1 or /blogs/1.json
  def show; end

  # GET /blogs/new
  def new
    @blog = Blog.new(profile: current_user.profile)
  end

  # GET /blogs/1/edit
  def edit; end

  # POST /blogs or /blogs.json
  def create
    blog_params_obj = blog_params.merge(profile: current_user.profile)
    cover_image = blog_params_obj.delete(:cover_image)

    @blog = Blog.new(blog_params_obj)

    @blog.upload_cover_image(cover_image) unless cover_image.nil?

    respond_to do |format|
      if @blog.save
        format.html do
          redirect_to @blog, notice: 'Blog was successfully created.'
        end
        format.json { render :show, status: :created, location: @blog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blogs/1 or /blogs/1.json
  def update
    blog_params_obj = blog_params
    cover_image = blog_params_obj.delete(:cover_image)
    @blog.upload_cover_image(cover_image) unless cover_image.nil?

    respond_to do |format|
      if @blog.update(blog_params_obj)
        format.html do
          redirect_to edit_blog_path(@blog),
                      notice: 'Blog was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @blog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blogs/1 or /blogs/1.json
  def destroy
    @blog.destroy
    respond_to do |format|
      format.html do
        redirect_to blogs_url, notice: 'Blog was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /blogs/1/publish or /blogs/1/publish.json
  def publish
    respond_to do |format|
      if @blog.publish
        format.html do
          redirect_to @blog, notice: 'Blog was successfully published.'
        end
        format.json { render :show, status: :ok, location: @blog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_blog
    @blog = current_user.profile.blogs.friendly.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def blog_params
    params.require(:blog).permit(:title, :description, :cover_image,
                                 :body_markdown)
  end
end
