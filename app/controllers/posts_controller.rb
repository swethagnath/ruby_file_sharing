class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy shorturl private_shorturl]
  before_action :authenticate_user!

  # GET /posts or /posts.json
  def index
    @posts = Post.where(user_id: current_user.id)
    @user = User.new
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    @post
  end

  # POST /posts or /posts.json
  def create
      @post = Post.new(post_params)
      @post.user_id = current_user.id.to_s
      if file_Check(post_params["image"])
        respond_to do |format|
          flash[:notice] = 'file size should be between 1mb and 1gb.'
          format.html { render :new, notice: "Error while creating." }
        end
      else
        @post.file_name = post_params["image"].original_filename
        cloudinary = set_cloudinary
        @post["cloudinary_id"] = cloudinary["secure_url"]
        @post.image = post_params["image"].tempfile.path
        @post.save
        respond_to do |format|
          if @post.save
            format.html { redirect_to posts_url, notice: "Post was successfully created." }
            format.json { render :show, status: :created, location: @post }
          else
            format.html { render :new, status: :unprocessable_entity }
          end
        end
      end  
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    if file_Check(post_params["image"])
      flash[:notice] = 'Error while updating.'
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
    else
      if post_params["image"].original_filename != @post.file_name
        post_params["file_name"] = post_params["image"].original_filename
        cloudinary = set_cloudinary
        @post["cloudinary_id"] = cloudinary["secure_url"]
        @post.image = post_params["image"].tempfile.path
      end
      respond_to do |format|
        if @post.update(post_params)
          format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end
  end
    
    

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def shorturl
    baseUrl = "http://localhost:8080"
    url = SecureRandom.hex(5)
    shortUrl = baseUrl + "/" + url
    @post.urlcode = url
    @post.shorturl = shortUrl
    @post.public_access = true
    respond_to do |format|
      if @post.save()
        format.html { redirect_to posts_url, notice: "Short url created successfully." }
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def private_shorturl
    if  params[:user].nil?
      @post.public_access = true
      @post.private_users = []
    elsif params["user"]["email"][1..-1].length() > 0 
      @post.public_access = false
      @post.private_users = params["user"]["email"][1..-1]
    end
    @post.save
    @posts = Post.where(user_id: current_user.id)
    respond_to do |format|
      format.html { render :index, status: :unprocessable_entity }
    end
  end

  def getshorturl
    id = params[:shorturl]
    @post = Post.find_by({urlcode: id})
    access = false
    if (@post.private_users.length() > 0)  && (@post.private_users.include? current_user.id.to_s)
      access = true
    elsif @post.private_users.length() <= 0 && @post.public_access
      access = true
    end
    if access
      redirect_to @post.cloudinary_id
    else
      @posts = Post.where(user_id: current_user.id)
      respond_to do |format|
        flash[:notice] = 'no permission to access'
        format.html { redirect_to posts_url, notice: "no permission to access" }
      end
    end 
  end

  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :description, :image)
    end

    def file_Check(image)
      !(image.size >= 1.megabytes && image.size <= 1.gigabytes)
    end

    def set_cloudinary
      mime = post_params["image"].content_type.split("/")[0]
      if mime != "image" && mime != "video"
        mime = "raw"
      end
      cloudinary = Cloudinary::Uploader.upload(post_params["image"].tempfile.path, :use_filename => true, :folder => "file_Sharing/cache", :quality => "auto", :resource_type => mime)
    end
    
end


