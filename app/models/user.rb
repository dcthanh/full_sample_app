class User < ActiveRecord::Base
  #Model relations
  has_many :microposts, dependent: :destroy
  
  has_many :active_relationships, class_name:   "Relationship",         # Définition du lien entre la classe user et la classe relationships qui récupère l'id de l'user dans follower_id 
                                  foreign_key:  "follower_id",          # Le user actuel est un follower d'une autre user
                                  dependent:    :destroy                # Ce lien est créé quand le user actuel clique 'follow'
  has_many :following, through: :active_relationships, source: :followed    #Ici on parcourt la relation dans l'autre sens >> on récupère tous les users followed par l'user actuel
  
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  has_many :followers, through: :passive_relationships, source: :follower
  
  #attributes definition (not recorded)
  attr_accessor :remember_token, :activation_token, :reset_token
  
  #Callbacks
  before_save   :downcase_email
  before_create :create_activation_digest
  
  #name
  validates :name,  presence: true, 
                    length: { maximum: 50 }
  
  #email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true, 
                    length:     { maximum: 255 }, 
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  #password
  has_secure_password  
  validates :password, length:  { minimum: 6 }, allow_blank: true
  
  #returns the hash digest of the given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)   
  end
  
  #Returns a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  #Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest") #send : Méthode magic pour appeler une méthode par son nom littéral
    #digest = self.send("#{attribute}_digest") >> identique à au-dessus, le 'self' est implicite
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  #Forgets users by removing remember_token
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  #Activates an account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  #Sends activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end    
   
  #Sets the password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token), 
                   reset_sent_at: Time.zone.now)
  end
  
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  def feed
    Micropost.where('user_id = ?', id) #id <=> self.id
  end
  
  #Follows a user
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)    
  end
  
  #Unfollows a user
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  #Returns true if the other_user is followed
  def following?(other_user)
    following.include?(other_user)
  end  
  
  #Returns true if the user is followed by an other user
  def followed_by?(other_user)
    followers.include?(other_user)
  end
        
  private 
    def downcase_email
      self.email = email.downcase
    end  
    
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
  
  
end
