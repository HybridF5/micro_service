CREATE DATABASE jacket;
CREATE DATABASE jacket_api;

GRANT ALL PRIVILEGES ON jacket_api.* TO 'jacket'@'localhost' \
  IDENTIFIED BY 'PASSWORD';
GRANT ALL PRIVILEGES ON jacket_api.* TO 'jacket'@'%' \
  IDENTIFIED BY 'PASSWORD';
GRANT ALL PRIVILEGES ON jacket.* TO 'jacket'@'localhost' \
  IDENTIFIED BY 'PASSWORD';
GRANT ALL PRIVILEGES ON jacket.* TO 'jacket'@'%' \
  IDENTIFIED BY 'PASSWORD';

