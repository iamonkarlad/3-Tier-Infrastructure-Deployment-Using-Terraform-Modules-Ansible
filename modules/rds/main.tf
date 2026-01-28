resource "aws_db_subnet_group" "db_subnet" {
  name = "db_subnet_group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "db_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  engine_version       = "8.0"
  username             = "admin"
  password             = "admin1234"
  db_name              = "mydatabase"
  skip_final_snapshot = true
  vpc_security_group_ids = [var.sg_id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
}