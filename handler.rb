require 'mysql2'

def main(event:, context:)
  # client = Mysql2::Client.new(
  #   :host => "******.us-east-*.rds.amazonaws.com",
  #   :username => "********",
  #   :database=> "*******",
  #   :password=> "**********",
  #   :port => 3306)
  # results = client.query("SELECT COUNT(*) FROM employees;").to_a
  {
    test: Mysql2::VERSION
  }
end