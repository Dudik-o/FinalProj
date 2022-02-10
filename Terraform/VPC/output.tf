output "public_subnets_id" {
    value = aws_subnet.public.*.id
}

output "private_subnets_id" {
    value = aws_subnet.private.*.id
}

output "vpc_id" {
    value = aws_vpc.ops-project.id
}

