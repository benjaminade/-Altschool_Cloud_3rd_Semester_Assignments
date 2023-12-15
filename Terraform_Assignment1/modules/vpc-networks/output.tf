output "vpc_id" {
  value = aws_vpc.dev-vpc.id
}

output "subnet_id" {
  value = aws_subnet.dev-subnet[*].id
}

output "key_pair_id" {
  value = aws_key_pair.testkey.id
}