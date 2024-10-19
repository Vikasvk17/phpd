# Use Ubuntu as the base image
FROM ubuntu:20.04

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages including MySQL, Apache, and PHP
RUN apt-get update && \
    apt-get install -y mysql-server apache2 php libapache2-mod-php php-mysql git && \
    apt-get clean

# Remove the default html directory created by Apache (if it exists)
RUN rm -rf /var/www/html

# Clone the project from GitHub into /var/www/html/
RUN git clone --depth 1 https://github.com/Vikasvk17/lampphp.git /var/www/html

# Expose ports for Apache and MySQL
EXPOSE 80 3306

# Command to start MySQL, wait for it to be ready, set up the database and user, and start Apache
CMD service mysql start && \
    # Wait for MySQL to be ready
    until mysqladmin ping --silent; do \
        echo "Waiting for MySQL to start..."; \
        sleep 2; \
    done && \
    # Create a new user with full privileges
    mysql -u root -e "CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';" && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost' WITH GRANT OPTION;" && \
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS bookstore;" && \
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS moviedb;" && \
    mysql bookstore < /var/www/html/mySqlDB/bookDB.sql && \
    mysql moviedb < /var/www/html/mySqlDB/movieDB.sql && \
    service apache2 start && \
    tail -f /dev/null
