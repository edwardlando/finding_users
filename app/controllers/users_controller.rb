

class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    
  #  configure
    arr = ["thefancy","wanelo"]
    @users = search_terms(arr).sort {|a,b| b.influence<=>a.influence}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end



def twitter_config
  Twitter.configure do |config|
    config.consumer_key = @consumer_key
    config.consumer_secret = @consumer_secret
    config.oauth_token = @access_token
    config.oauth_token_secret = @access_secret
  end
end

def twitter_search(terms)
  users = []
  text = []
  user_list = {}
  @consumer_key = '0o6WVeAsAE7KpFKAEcWT8Q'
@consumer_secret = 'BdFwoO7wzDmIeHDTW6cWnSWPBDEfpOchhihygbo3wds'
@access_token = '307469831-baPCizmKBOYTyXKyqtaEWhAZM1EkElSSCqKHmfOY'
@access_secret = 'KDzS1sMjZ1zTjrCO85SOAwEV4LEqJEK7UQ6hw4Gbc'
@conn = ''
  Twitter.configure do |config|
    config.consumer_key = @consumer_key
    config.consumer_secret = @consumer_secret
    config.oauth_token = @access_token
    config.oauth_token_secret = @access_secret
  end
  terms.each do |t|
    callback = Twitter.search(t,:count => 100, :lang => "en")
    users = callback.results.map {|res| res.user} 
    users.each do |user|
      puts user.name
      if (user_list.has_key?(user.name))
        user_list[user.name].influence+=user.followers_count
      else
        u = User.new
        u.name = (user.name)
        u.description = user.description
        u.image = user.profile_background_image_url
        u.influence = user.followers_count
        u.contact = user.url
        user_list[u.name]=u
      end
    end
  end
  puts user_list.values
  user_list.values
end


def search_terms(terms)
  twitter_search(terms)
end

def configure
  twitter_config
end
end
