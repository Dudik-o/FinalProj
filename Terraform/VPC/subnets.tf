
resource "aws_subnet" "public" {
  count                   = var.number_of_pubsubnets
  vpc_id                  = aws_vpc.ops-project.id
  availability_zone       = data.aws_availability_zones.zone.names[count.index]
  cidr_block              = "10.0.${10 + count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet , ${count.index + 1}"
  }
}


resource "aws_subnet" "private" {
  count             = var.number_of_privsubnets
  vpc_id            = aws_vpc.ops-project.id
  availability_zone = data.aws_availability_zones.zone.names[count.index]
  cidr_block        = "10.0.${100 + count.index}.0/24"
  tags = {
    Name = "PrivateSubnet ${count.index + 1}"
  }
}
