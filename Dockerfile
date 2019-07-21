FROM lambci/lambda:build-ruby2.5

RUN yum -y install mysql-devel
RUN gem update bundler

CMD "/bin/bash"
