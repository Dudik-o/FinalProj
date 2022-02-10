resource "aws_vpc" "ops-project" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ops-project"
  }
}
