resource "aws_vpc" "farmdirect" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "farmdirect-${var.environment}-vpc"
    Environment = var.environment
    Project     = "FarmDirect"
  }
}

resource "aws_internet_gateway" "farmdirect" {
  vpc_id = aws_vpc.farmdirect.id

  tags = {
    Name        = "farmdirect-${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.farmdirect.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "farmdirect-${var.environment}-public-${count.index + 1}"
    Tier        = "public"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id            = aws_vpc.farmdirect.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "farmdirect-${var.environment}-private-app-${count.index + 1}"
    Tier        = "private-app"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_database" {
  count = length(var.private_database_subnet_cidrs)

  vpc_id            = aws_vpc.farmdirect.id
  cidr_block        = var.private_database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "farmdirect-${var.environment}-private-db-${count.index + 1}"
    Tier        = "private-database"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.farmdirect.id

  tags = {
    Name = "farmdirect-${var.environment}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.farmdirect.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "farmdirect-${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "farmdirect" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "farmdirect-${var.environment}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.farmdirect]
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.farmdirect.id

  tags = {
    Name = "farmdirect-${var.environment}-private-app-rt"
  }
}

resource "aws_route" "private_app_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private_app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.farmdirect[0].id
}

resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.private_app)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}