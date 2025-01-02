#!/bin/bash

source .env

# First create draft with both attachments
echo "Creating draft..."
JSON_PAYLOAD=$(cat <<EOF
{
    "subject": "Test inline vs regular attachments",
    "body": "<html><body>Testing inline vs regular attachments. No attachments yet.</body></html>",
    "to": [{
      "email": "$TO_EMAIL"
    }]
}
EOF)

DRAFT_RESPONSE=$(curl --request POST \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "content-type: application/json" \
  -d "$JSON_PAYLOAD"
)

# Extract draft ID from response
DRAFT_ID=$(echo $DRAFT_RESPONSE | jq -r '.data.id')
echo "Created draft with ID: $DRAFT_ID"


echo "Updating draft to add attachments:"

JSON_PAYLOAD=$(cat <<EOF
{
    "subject": "Test inline vs regular attachments (CURL)",
    "body": "<html><body>Testing inline vs regular attachments<br><img src=\"cid:halipng\"><br>And here is a PDF</body></html>",
    "to": [{
      "email": "$TO_EMAIL"
    }]
}
EOF)

curl --request PATCH \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts/$DRAFT_ID" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "content-type: multipart/form-data" \
  --form "message=$JSON_PAYLOAD" \
  --form "halipng=@hali.png" \
  --form "toaster_oven=@toaster oven.pdf" | jq


# Get the draft to show how Nylas marks both as inline
echo "Getting draft to show attachment status:"
curl -s -X GET \
  "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts/$DRAFT_ID" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $NYLAS_API_KEY" | jq

# Send the draft
echo "Sending draft..."
curl --request POST \
  --url "https://api.us.nylas.com/v3/grants/$NYLAS_GRANT_ID/drafts/$DRAFT_ID" \
  --header "Accept: application/json" \
  --header "Authorization: Bearer $NYLAS_API_KEY" \
  --header "Content-Type: application/json" | jq
