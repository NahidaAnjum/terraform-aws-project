#create VPC
resource "aws_vpc" "dev-vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "dev-vpc"
  }
}

#create Public subnet
resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "web-subnet"
  }
}

#create private subnet
resource "aws_subnet" "db-subnet" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "db-subnet"
  }
}

#create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "igw"
  }
}

#create route table
resource "aws_route_table" "web-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "dev-route-table"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "web-subnet-association" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.web-route-table.id
}

# Create Security Group for Web Server
resource "aws_security_group" "web-sg" {
  vpc_id = aws_vpc.dev-vpc.id
  name   = "web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "WebSG" }
}

# Create Security Group for Database Server
resource "aws_security_group" "db-sg" {
  vpc_id = aws_vpc.dev-vpc.id
  name   = "db-sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Allow traffic from Public Subnet instead of Web SG
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Allow DB to communicate only with Web Subnet
  }
  
  tags = { Name = "DBSG" }
}

# Create Web Server in Public Subnet
resource "aws_instance" "web-server" {
  ami             = "ami-04b4f1a9cf54c11d0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.web-subnet.id
  security_groups = [aws_security_group.web-sg.id]
  tags            = { Name = "WebServer" }
  user_data       = file("userdata.sh")

}

# Create DB Server in Private Subnet
resource "aws_instance" "db-server" {
  ami             = "ami-04b4f1a9cf54c11d0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.db-subnet.id
  security_groups = [aws_security_group.db-sg.id]
  tags            = { Name = "DBServer" }
}

