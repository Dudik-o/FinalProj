
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ops-project.id
  tags = {
    "Name" = "Public RTB"
  }
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route_table" "private" {
  count  = var.number_of_privsubnets
  vpc_id = aws_vpc.ops-project.id
  tags = {
    "Name" = "Private RTB ${count.index + 1}"
  }
}
resource "aws_route" "private" {
  count                  = var.number_of_privsubnets
  route_table_id         = aws_route_table.private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.*.id[count.index]
}

resource "aws_route_table_association" "public-association" {
  count          = var.number_of_pubsubnets
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-association" {
  count          = var.number_of_privsubnets
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}