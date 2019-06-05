class Token
  attr_reader :user_id, :payload

  def initialize token
    @payload = JWT.decode(token, ENV['JWT_SECRET'], ENV['JWT_ALGORITHM'])[0].with_indifferent_access
    @user_id = @payload[:user_id]
  end

  def valid?
    user_id.presence && Time.now < Time.at(@payload[:exp].to_i)
  end

  def self.encode user_id
    JWT.encode({ user_id: user_id, exp: (DateTime.now + 1.hour).to_i }, ENV['JWT_SECRET'], ENV['JWT_ALGORITHM'])
  end

end