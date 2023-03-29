module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "elg5164-terraform-aws-s3-bucket"
  acl    = "public-read"

  force_destroy = true

  versioning = {
    enabled = true
  }
}

module "cdn" {
  source              = "terraform-aws-modules/cloudfront/aws"
  comment             = "My Awesome Cloudfront"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome cloudfront can access"
  }

  origin = {
    s3_bucket_one = {
      domain_name = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_bucket_one" # key in `origin` above
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = 5400
    min_ttl     = 3600
    max_ttl     = 7200

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = false
  }

  default_root_object = "index.html"
}


data "aws_iam_policy_document" "s3_policy" {
  version = "2012-10-17"
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
    principals {
      type        = "AWS"
      identifiers = module.cdn.cloudfront_origin_access_identity_iam_arns
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}
