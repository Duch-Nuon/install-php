#!/bin/bash

# Update package list
sudo apt update

# Install PHP 8.2
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-xml php8.2-mbstring php8.2-curl php8.2-zip php8.2-bcmath php8.2-json php8.2-gd

# Install MySQL Server
sudo apt install -y mysql-server

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Check MySQL service status
sudo service mysql status

# Secure MySQL Installation
sudo mysql_secure_installation

# MySQL root user configuration
MYSQL_ROOT_PASSWORD="123456@Abc" # Set your MySQL root password

# Log in to MySQL as root and apply configurations
sudo mysql -u root -e "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

echo "MySQL root user has been configured with native password authentication."

# Install Nginx
sudo apt install -y nginx

# Start and enable Nginx and PHP-FPM services
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start php8.2-fpm
sudo systemctl enable php8.2-fpm

# Configure Nginx to use PHP
cat <<EOL | sudo tee /etc/nginx/sites-available/laravel
server {
    listen 80;
    server_name your_domain_or_IP; # Change to your domain or IP

    root /var/www/laravel/public; # Change to your Laravel project's public directory
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

# Enable the Nginx site configuration
sudo ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Install Composer using wget (specific version)
cd /usr/local/bin
sudo wget https://getcomposer.org/download/2.8.1/composer.phar

# Make Composer executable
sudo chmod +x composer.phar
sudo ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Output success message
echo "PHP 8.2, MySQL (root user configured), Nginx, and Composer (version 2.8.1) have been installed and configured successfully!"
