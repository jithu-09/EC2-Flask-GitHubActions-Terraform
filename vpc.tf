resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "${var.prefix}-vpc"
    }
}

resource "aws_subnet" "pub_subnet" {
   vpc_id = aws_vpc.vpc.id
   cidr_block = var.vpc_cidr[0]
   availability_zone = "${var.region}a"
   map_public_ip_on_launch = true
   tags = {
       Name = "${var.prefix}-pub-subnet"
   }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    
    tags = {
        Name = "${var.prefix}-igw"
    }
}

resource "aws_route_table" "pub_rt" {
   vpc_id = aws_vpc.vpc.id
   tags = {
       Name = "${var.prefix}-pub-rt"
   }
}

resource "aws_route_table_association" "pub-rta" {
    subnet_id = aws_subnet.pub_subnet.id
    route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route" "pub_route" {
    route_table_id = aws_route_table.pub_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

#All of these reources are for creating a public subnet in the VPC
