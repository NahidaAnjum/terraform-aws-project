#!/bin/bash
sudo apt update -y
sudo apt install -y nginx
echo "<h1>Hi, Welcome to Anjum's Website! 🚀</h1>" | sudo tee /var/www/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx
