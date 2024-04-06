variable "objects" {
  type = map(string)
}



resource "aws_dynamodb_table_item" "upload" {
  table_name = aws_dynamodb_table.dynamodb_table.name
  hash_key   = aws_dynamodb_table.dynamodb_table.hash_key
  item       = <<EOF
 {
  "Artist": {"S": "Miles_Davis"},
  "AlbumTitle": {"S": "Kind_Of_Blue"},
  "Year": {"N": "1959"},
  "Pressing": {"S": "QRP"}
  "RepressYear": {"N": "2022"},
  "MediaCondition": {"S": "Mint"}
  "SleeveCondition": {"S": "Mint"},
  "MedianValue": {"N": "130"}  
}
EOF
}
