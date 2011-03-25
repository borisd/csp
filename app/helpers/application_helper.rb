module ApplicationHelper
  def random_string
    secret_chars = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
    secret = (0..20).map{ secret_chars[rand(secret_chars.length)] }.join;
  end

  def with_error
    render :text => 'Incorrect call'
  end
end

