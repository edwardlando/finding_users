
class UsersController < ApplicationController
  # GET /users
  # GET /users.json

  def index
    
  #  configure
    arr = ["wanelo","thefancy"]
    @users = search_terms(arr).sort {|a,b| b.influence<=>a.influence}

  #  @facebook = fb_search(arr)


    @klout = klout_search

    #@linked_in = linkedin_search

    #tumblr_search

    @users = search_terms(arr)

  #  @klout = klout_search

   # @linked_in = linkedin_search


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
    users.each.with_index do |user,ind|
      #puts user.name
      if (user_list.has_key?(user.name))
        user_list[user.name].influence+=user.followers_count
      else
        u = User.new
        u.name = (user.name)
        u.description = user.description
        u.image = user.profile_background_image_url
        u.influence = user.followers_count
        u.contact = 'twitter.com/'+callback.results[ind].from_user
        user_list[u.name]= u
      end
    end
  end
  puts user_list.values
  user_list.values
end


  def fb_search(terms)
    @graph = Koala::Facebook::API.new
    user_list = {}
    ids = []
    terms.each do |t|
      res = @graph.search(t)
      #puts res
      temp_ids = res.map {|r| r['from']['id']}
      ids.push(temp_ids)
    end
    ids.flatten!
    users = @graph.get_objects(ids)
    #puts users
    users = users.values
    users.each do |user|
      u = User.new
      u.influence = 0
      u.name = user['name']
      if !user['description'].nil?
        u.description = user['description']
        u.influence += 5000
        u.image = user['cover']['source']
      end
      u.contact = user['link']
      u.influence += 5000
      user_list[u.name]=u
    end
    user_list.values
 #   render :json => users
  end

def linkedin_search
  @api_key = '9u62uu7fluz1'
  @secret_key = 'QnhL3SzveFxUt4R9'
  @oauth_user_token = '57caf870-d04a-46ff-a1f4-2d39d0d2e04e'
  @oauth_user_secret = '89fb2b42-13f5-4f4f-bbf8-eb2e5dab8d09'

  client = LinkedIn::Client.new(@api_key, @secret_key)

  rtoken = client.request_token.token
  rsecret = client.request_token.secret

  #p "**********************************"
  #p client.request_token.authorize_url

  pin = '18360'

  client.authorize_from_request(rtoken, rsecret, pin)

  p client

  client.profile
end


def klout_search
 # require 'klout'
 # Klout.api_key = ENV['klout_api_key']

  api_key='qyj6z8v63bx29wp4nmf4ej56'
  conn = Faraday.new(:url => "http://api.klout.com/v2/identity.json")
  response = conn.get "/twitter?key="+api_key+"&screenName=edwardlando"
  p "******************************************************************************"
  puts response.body

#  klout_id = Klout::Identity.find_by_screen_name('edwardlando')
#  puts klout_id['id']
#  user = Klout::User.new(klout_id['id'])
#  puts user
end

def tumblr_search
  oauth_consumer_key = 'sXgmq0oQlMAGWKH5tTIk8ls0HEr0OyNW6gf8YssYidumIZt6n7'
  secret_key = 'ajXT4SYKQy6bjQO3kKwrBNQdGrwzvS8fwEHsg5L7L5NNpf65xj'

  user = OAuth::Consumer.new(oauth_consumer_key, secret_key, :site => "http://www.tumblr.com/")

  token_hash = {:oauth_token => user.access_token_path,:oauth_token_secret => access_token_path}

  #access_token = OAuth::AccessToken.from_hash(consumer, token_hash )

  p "77777777777777777777777"
  p user


=begin
  Tumblr.configure do |config|
    config.consumer_key = oauth_consumer_key
    config.consumer_secret = secret_key
    config.oauth_token = access_token.token
    config.oauth_token_secret = access_token.secret
  end
=end


end




def search_terms(terms)
  users = fb_search(terms)+twitter_search(terms)
  users.sort {|b,a| a.influence <=> b.influence }
end


def configure
  twitter_config
end
end
