data "template_file" "userData" {
  template = file("./modules/ec2InstanceCreate/userData.sh")
  vars = {
    BUCKETNAME  = var.s3_bucket
    DB_USER     = var.username
    DB_PASSWORD = var.password
    DB_NAME     = var.db_name
    PORT        = var.app_port
    DB_HOST     = var.host_name
  }
}