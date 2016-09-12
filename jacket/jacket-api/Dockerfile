FROM jacket/jacket-base
MAINTAINER nkapotoxin nkapotoxin@gmail.com

# Install jacket
WORKDIR /opt/jacket
RUN python setup.py install

# Install the sample configuration files.
RUN mkdir -p /etc/jacket
ADD install-config.sh /opt/jacket/install-config.sh
RUN sh /opt/jacket/install-config.sh

# Add jacket.sql
ADD jacket.sql /opt/jacket/jacket.sql

# Add bootstrap script and make it executable
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh && chmod 744 /etc/bootstrap.sh

#ENTRYPOINT ["/etc/bootstrap.sh"]
