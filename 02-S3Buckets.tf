module "s3" {

    source = "</Users/christopher/Cloud_Ninjas_Pics_Gifs/Pics_Gifs>"

    bucket_name = "Pics_Gifs"       

}

resource "aws_s3_bucket" "buckets" {

    bucket = "${var.bucket_name}" 

    acl = "${var.acl_value}"   

}
