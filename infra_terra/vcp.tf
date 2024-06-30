# Create a VPC in 10.0.0.0/24 cidr
resource "aws_vpc" "vpc" {
  cidr_block           = "10.99.0.0/18"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

# Create 2 public subnets, each in a different AZ
resource "aws_subnet" "public-subnets" {
  count                   = length(var.public_subnets_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnets_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.project}-public-subnet-${count.index + 1}"
  }
}


# Create a Internet Gateway for the public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Create an Elastic IP for the NAT Gateway to get access to Internet
resource "aws_eip" "nat_eip" {
  count  = 2
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project}-nat-eip"
  }
}

# Create a NAT gateway to get outbound internet connectivity (provides outgoing internet access, and does not allow incoming connections)
resource "aws_nat_gateway" "nat_igw" {
  count         = length(var.public_subnets_cidrs)
  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project}-NAT-gateway-${count.index + 1}"
  }
}

########### PUBLIC SUBNETS ##################

# Create a first Route Table to route traffic for Public Subnets
resource "aws_route_table" "rt_public_subnet" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-rt_pub_subnet"
  }
}

# Route the Public subnets traffic through the IGW
resource "aws_route" "pub_subnet_internet_access" {
  route_table_id         = aws_route_table.rt_public_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [aws_route_table.rt_public_subnet]
}

# Associate the Public subnets to the first RT
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnets_cidrs)
  subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  route_table_id = aws_route_table.rt_public_subnet.id
}


########### PRIVATE SUBNETS ##################

resource "aws_subnet" "private-subnets" {
  count                   = length(var.private_subnets_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.private_subnets_cidrs, count.index)
  map_public_ip_on_launch = false
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.project}-private-subnet-${count.index + 1}"
  }
}

# Create a second Route Table to route traffic for Private Subnets
# Each subnet should have its own route table as the NAT gateway lives in an availability zone
resource "aws_route_table" "rt_private_subnet" {
  count  = length(var.private_subnets_cidrs)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-rt_priv_subnet-${count.index + 1}"
  }
}

# Route for Private Subnets to get to the NAT gateway
resource "aws_route" "private_nat_gateway" {
  count                  = length(aws_route_table.rt_private_subnet)
  route_table_id         = element(aws_route_table.rt_private_subnet.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_igw.*.id, count.index)

  depends_on = [aws_route_table.rt_private_subnet]
}

# Associate the Private subnets to second the RT and isolate it
resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(var.private_subnets_cidrs)
  subnet_id      = element(aws_subnet.private-subnets.*.id, count.index)
  route_table_id = element(aws_route_table.rt_private_subnet.*.id, count.index)
}

