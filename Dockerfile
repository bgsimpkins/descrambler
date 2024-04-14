FROM python:3.9-slim-buster
ENV TZ="America/Chicago"

#fixme: this seems stupid to install all of tidyverse, but there are issues with compiling the 'lexicon' package otherwise
RUN apt-get -y update && apt-get install -y --no-install-recommends r-base r-base-dev r-cran-tidyverse

ADD requirements.txt .
RUN python -m pip install -r requirements.txt

##Install R packages
RUN mkdir ~/R
RUN mkdir ~/R/lib

RUN R_LIBS_USER=~/R/lib Rscript -e "install.packages('lexicon')"
RUN R_LIBS_USER=~/R/lib Rscript -e "install.packages('gtools')"
RUN R_LIBS_USER=~/R/lib Rscript -e "install.packages('stringi')"
RUN R_LIBS_USER=~/R/lib Rscript -e "install.packages('jsonlite')"

WORKDIR /app
ADD . /app

CMD ["python", "app.py"]