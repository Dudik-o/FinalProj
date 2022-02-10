resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.ops-project.id
  tags = {
    Name = "Gateway"
  }
}

resource "aws_eip" "NAT-IP" {
  count = var.number_of_pubsubnets
  vpc   = true
}
resource "aws_nat_gateway" "nat" {
  count         = var.number_of_privsubnets
  subnet_id     = aws_subnet.public.*.id[count.index]
  allocation_id = aws_eip.NAT-IP.*.id[count.index]
  tags = {
    Name = "NAT ${count.index + 1}"
  }
}