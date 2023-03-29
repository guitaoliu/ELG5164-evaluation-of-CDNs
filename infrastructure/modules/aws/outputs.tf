output "cloudfront_distribution_domain_name" {
  value = module.cdn.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_id" {
  value = module.cdn.cloudfront_distribution_id
}

output "s3_bucket_id" {
  value = module.s3_bucket.s3_bucket_id
}
