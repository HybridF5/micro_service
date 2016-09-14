FROM centos
MAINTAINER nkapotoxin nkapotoxin@gmail.com
RUN yum -y install \
        centos-release-openstack-mitaka \
        python-openstackclient \
	python-pbr \
	git \
	python-devel \
	python-setuptools \
	python-pip \
	gcc \
	libxml2-python \
	libxslt-python \
	python-lxml \
	sqlite \
	python-repoze-lru  \
	crudini \
	yum-utils \
        python-osprofiler \
        python-cinderclient

# This pulls in all the dependencies of the python-nova package
# without actually installing python-nova (because now the dependencies of
# jacket are the same as python-nova).
RUN yum -y install $(repoquery --requires python-nova | awk '{print $1}')
RUN yum -y install $(repoquery --requires python-cinder | awk '{print $1}')

# Download and install jacket from source.
WORKDIR /opt
RUN git clone https://github.com/HybridF5/jacket.git
