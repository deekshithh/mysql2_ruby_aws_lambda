
## Using Ruby to build AWS lambda along with mysql2

AWS added Ruby to the list of supported languages for AWS Lambda at the end of the year 2018. The official document does a good job of explaining how to get started with it. However, it doesn't cover how to include gems that have dependencies on native extensions, like mysql2.

The scope of the post is to demonstrate how to make mysql2 gem work with Lambda. And, it uses RDS to achieve this. It is assumed that the reader has prior experience with AWS services and the following topics will be excluded in the post.
* Creating an RDS instance.
* Configuring Lambda function to connect to RDS.

Lets get started.

1. Create a new folder and change the working directory to the same.
  ```
  mkDir sample_ruby_lambda
  cd sample_ruby_lambda
  ```
2. Install  [RVM](http://install/), Ruby, and Bundler.
  ```
    rvm install ruby-2.5.0
    gem install bundler
  ```

3. Install  [Docker](https://docs.docker.com/docker-for-mac/install/).

4. Create a Docker file(Dockerfile).
   ```
    FROM lambci/lambda:build-ruby2.5RUN yum -y install mysql-devel
    RUN gem update bundlerCMD "/bin/bash"
   ```
5. Create a Docker image.
  ```
    docker build -t lambda-ruby2.5-sales-dashboard .
  ```
6. Create a ruby handler file(handler.rb)
  ```
    require 'mysql2'def main(event:, context:)
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
  ```
7. Create a Gemfile(Gemfile)
  ```
    source "[https://rubygems.org](https://rubygems.org/)"gem "mysql2"
  ```
8. Using RVM use the ruby-2.5.0(If not present instal it)
  ```
    rvm use ruby-2.5.0
  ```
9. Execute the following command to get inside the container:
  ```
    docker run --rm -it -v $PWD:/var/task -w /var/task lambda-ruby2.5-sales-dashboard
  ```
10. From inside the container, run;
  ```
    bundle config --local build.mysql2 --with-mysql2-config=/usr/lib64/mysql/mysql_config
    bundle config --local silence_root_warning true
    bundle install --path vendor/bundle --clean
    mkdir -p /var/task/lib
    cp -a /usr/lib64/mysql/*.so.* /var/task/lib/
  ```
11. Smoke test: Run the following inside the container.
  ```
    ruby -e "require 'handler'; puts main(event: nil, context: nil)"
  ```
12. You should get a response like this,
  ```
    { test: "0.5.2" }
  ```
13. Package to Zip.
  ```
    rm -f deploy.zip
    zip -q -r deploy.zip .
  ```
14. Exit the container bash and simulate the lambda instance.
  ```
    docker run --rm -v "$PWD":/var/task lambci/lambda:ruby2.5 handler.main
  ```
    You can expect the following result
    ```
    START RequestId: 52fdfc07-2182-154f-163f-5f0f9a621d72 Version: $LATEST
    END RequestId: 52fdfc07-2182-154f-163f-5f0f9a621d72
    REPORT RequestId: 52fdfc07-2182-154f-163f-5f0f9a621d72
    Duration: 7.85 ms Billed Duration: 100 ms Memory Size: 1536 MB Max Memory Used: 21 MB
    {"test":"0.5.2"}
    ```

15. Deploy to the AWS Lambda using the console, or command line
16. Go to AWS lambda console and test the code.