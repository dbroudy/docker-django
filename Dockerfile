FROM debian:jessie
MAINTAINER David Broudy <dave@broudy.net>

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    git \
    #libpython2.7 \
    nginx \
    python \
    python-dev \
    python-pip \
    python-pil \
    supervisor 
  #&& apt-get clean \
  #&& rm -rf /var/lib/apt/lists/*

RUN pip install uwsgi

RUN adduser --system --ingroup www-data --home /run/app django 

COPY conf/*.supervisor.conf /etc/supervisor/conf.d/
COPY conf/*.nginx.conf /etc/nginx/conf.d/
#COPY conf/*.site.conf /etc/nginx/sites-enabled/
COPY conf/uwsgi.ini /etc/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf && rm /etc/nginx/sites-enabled/default

RUN mkdir -p /srv/app
WORKDIR /srv/app

# copy requirements before rest of app to make own layer
ONBUILD COPY requirements.txt /srv/app/
ONBUILD RUN pip install -r requirements.txt

# clean space, but not worth it
# RUN apt-get remove --purge -y python-dev build-essential && apt-get autoremove -y

ONBUILD COPY . /srv/app/

EXPOSE 80

ENTRYPOINT [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]

#USER django
#ONBUILD RUN python /srv/app/manage.py migrate --noinput
#ONBUILD RUN python /srv/app/manage.py collectstatic --noinput
